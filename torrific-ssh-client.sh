#!/usr/bin/env bash


## Exit if not running with root/level permissions
if [[ "${EUID}" != '0' ]]; then echo "Try: sudo ${0##*/} ${@:---help}"; exit 1; fi


_torrc_path='/etc/tor/torrc'
_onion_address=''
_service_auth=''
_ssh_config_path="${HOME}/.ssh/config"
_ssh_port='22'
_ssh_user_name=''
_ssh_private_key=''


## Find true directory this script resides in
__SOURCE__="${BASH_SOURCE[0]}"
while [[ -h "${__SOURCE__}" ]]; do
    __SOURCE__="$(find "${__SOURCE__}" -type l -ls | sed -n 's@^.* -> \(.*\)@\1@p')"
done
__DIR__="$(cd -P "$(dirname "${__SOURCE__}")" && pwd)"
__NAME__="${__SOURCE__##*/}"
__AUTHOR__='S0AndS0'
__DESCRIPTION__='Configures client connection to Tor hidden SSH service'


#
#    Source modules
#
## Provides: 'falure' <line-number> <command> exit-code
source "${__DIR__}/modules/trap-failure/failure.sh"
trap 'failure "LINENO" "BASH_LINENO" "${BASH_COMMAND}" "${?}"' ERR

## Provides:  'argument_parser <ref_to_allowed_args> <ref_to_user_supplied_args>'
source "${__DIR__}/modules/argument-parser/argument-parser.sh"


#
#    Functions that organize this script
#


license(){
    local _date="$(date +'%Y')"
    cat <<EOF
# ${__DESCRIPTION__}
# Copyright (C) ${_date:-2020}  ${__AUTHOR__}
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation; version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
EOF
}


usage(){
    cat <<EOF
${__DESCRIPTION__}

  -e    --examples
Prints example usage and exits

  -h    --help
Prints this message and exits

  -l    --license
Shows script or project license and exits

  --torrc-path        --torrc=${_torrc_path}
Path to torrc configuration file.
Linux default path is usually...
    /etc/tor/torrc
MacOS default path may be...
    /usr/local/etc/tor/torrc

  --service-auth      --auth="${_service_auth:-S0meLet7er5AndNumbers}"
Required, shared secret that Tor uses to authenticate hidden service connections

  --onion-address     --host-name="${_onion_address:-yourgeneratedaddress.onion}"
Required, the Onion domain/URL to connect to

  --ssh-host          --host="${_ssh_host:-tor-${_ssh_user_name:-ssh-user-name}}"
Host used in SSH connection commands, eg. ssh host ls ~/

  --ssh-config-path   --ssh-config="${_ssh_config_path}"
File path to SSH client configuration

  --ssh-private-key   --identity-file="${_ssh_private_key:-~/.ssh/id_rsa}"
Required, file path to SSH private key; note, server should have the corresponding public key

  --ssh-port          --port="${_ssh_port}"
Port number that Tor is listening on the server and forwarding to SSH service

  "${_ssh_user_name:-ssh-user-name}"
Required
EOF
}


examples(){
    cat <<EOL
sudo ./${__NAME__} --host-name="yourgeneratedaddress.onion"\\
  --auth="S0meLet7er5AndNumbers"\\
  --identity-file='~/.ssh/id_rsa'\\
  "pi"


## The above command will preform the following steps...


## 0. Add dot-onion address and generated auth-cookie to torrc file...
tee -a /etc/tor/torrc 1>/dev/null <<EOF
HidServAuth yourgeneratedaddress.onion S0meLet7er5AndNumbers
EOF


## 1. Restart Tor service on client device
sudo systemctl restart tor.service


## 2. Add SSH configuration block
tee -a ~/.ssh/config 1>/dev/null <<EOF
Host tor-pi
   IdentitiesOnly yes
   IdentityFile ~/.ssh/id_rsa
   ProxyCommand socat STDIO SOCKS4A:127.0.0.1:%h:%p,socksport=9050
   HostName yourgeneratedaddress.onion
   Port 22
   User pi
EOF


## After-which attempt a connection via...
ssh tor-pi


## Note 'ssh -vvv tor-pi' may be useful for debugging connection issues
EOL
}


#
#    Parse arguments and perhaps print messages
#


## Pass arrays by reference/name to the `argument_parser` function
_passed_args=("${@:?No arguments provided}")
_acceptable_args=(
    '--examples|-e:bool'
    '--help|-h:bool'
    '--license|-l:bool'
    '--notes|-n:bool'
    '--torrc-path|--torrc:path'
    '--onion-address|--host-name:print'
    '--service-auth|--auth:print'
    '--ssh-host|--host:alpha_numeric'
    '--ssh-config-path|--ssh-config:path'
    '--ssh-private-key|--identity-file:path'
    '--ssh-port|--port:alpha_numeric'
    '--ssh-user-name:posix-nil'
)
argument_parser '_passed_args' '_acceptable_args'
_exit_status="$?"


## Print documentation for the script and exit, or allow further execution
if ((_help)) || ((_exit_status)); then
    usage
    exit "${_exit_status:-0}"
elif ((_examples)); then
    examples
    exit "${_exit_status:-0}"
elif ((_license)); then
    license
    exit "${_exit_status:-0}"
elif ((_notes)); then
    notes
    exit "${_exit_status:-0}"
elif ! ((${#_ssh_user_name})) || ! ((${#_ssh_private_key})) || ! ((${#_onion_address})) || ! ((${#_service_auth})); then
  printf >&2 'Missing required parameter(s), please review usage before trying again...\n'
  usage
  exit "1"
fi


#
#    Do the things if exiting has not happened yet
#

[[ -f "${_torrc_path}" ]] || {
   printf >&2 'No torrc configuration file found at -> %s\n' "${_torrc_path}"
   exit 1
}


tee -a "${_torrc_path}" 1>/dev/null <<EOF
HidServAuth ${_onion_address} ${_service_auth}
EOF


systemctl restart tor.service || {
    printf >&2 'Cannot restart Tor service\n'
    exit ${?:-1}
}


[[ -d "${_ssh_config_path%/*}" ]] || {
  mkdir -vp "${_ssh_config_path%/*}"
}


tee -a "${_ssh_config_path}" 1>/dev/null <<EOF
Host ${_ssh_host:-tor-$_ssh_user_name}
   IdentitiesOnly yes
   IdentityFile ${_ssh_private_key}
   ProxyCommand socat STDIO SOCKS4A:127.0.0.1:%h:%p,socksport=9050
   HostName ${_onion_address}
   Port ${_ssh_port}
   User ${_ssh_user_name}
EOF
