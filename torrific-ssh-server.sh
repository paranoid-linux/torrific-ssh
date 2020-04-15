#!/usr/bin/env bash


## Exit if not running with root/level permissions
if [[ "${EUID}" != '0' ]]; then echo "Try: sudo ${0##*/} ${@:---help}"; exit 1; fi


#
#    Set defaults for script variables; these maybe overwritten at run-time
#
_torrc_path='/etc/tor/torrc'
_tor_lib_dir='/var/lib/tor'
_tor_port='22'
_service_name='ssh_server'
_service_port='22'
_client_names=''


## Find true directory this script resides in
__SOURCE__="${BASH_SOURCE[0]}"
while [[ -h "${__SOURCE__}" ]]; do
    __SOURCE__="$(find "${__SOURCE__}" -type l -ls | sed -n 's@^.* -> \(.*\)@\1@p')"
done
__DIR__="$(cd -P "$(dirname "${__SOURCE__}")" && pwd)"
__NAME__="${__SOURCE__##*/}"
__AUTHOR__='S0AndS0'
__DESCRIPTION__='Configures Tor hidden service for SSH server'


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

  -n    --notes
Prints notes about Tor configurations and script options then exits

  -l    --license
Shows script or project license and exits

  --torrc-path    --torrc=${_torrc_path}
Path to torrc configuration file.
Linux default path is usually...
    /etc/tor/torrc
MacOS default path may be...
    /usr/local/etc/tor/torrc

  --tor-lib-dir    --tor-lib    --lib-dir=${_tor_lib_dir}
Path to Tor hidden services directory

  --tor-port    --virt-port=${_tor_port}
Port number Tor listens on and forwards to '--service-port'

  --service-port    --target-port=${_service_port}
Port service listens on and is forwarded to from '--tor-port'

  --client-names    --clients=${_client_names:-lamb,spam}
Required, comma seperated list of authorized clients

  ${_service_name}
Directory name for service under '--tor-lib-dir'
EOF
}


notes(){
    cat <<EOF
Note from 'man tor' regarding 'HiddenServicePort'
configured by '--tor-port' and '--service-port' options...

      Configure a virtual port VIRTPORT for a hidden service. You
      may use this option multiple times; each time applies to
      the service using the most recent HiddenServiceDir. By
      default, this option maps the virtual port to the same port
      on 127.0.0.1 over TCP. You may override the target port,
      address, or both by specifying a target of addr, port,
      addr:port, or unix:path. (You can specify an IPv6 target as
      [addr]:port. Unix paths may be quoted, and may use standard
      C escapes.) You may also have multiple lines with the same
      VIRTPORT: when a user connects to that VIRTPORT, one of the
      TARGETs from those lines will be chosen at random.


Note from 'man tor' regarding 'HiddenServiceAuthorizeClient'
configured by '--client-names' option...

      If configured, the hidden service is accessible for
      authorized clients only. The auth-type can either be
      'basic' for a general-purpose authorization protocol or
      'stealth' for a less scalable protocol that also hides
      service activity from unauthorized clients. Only clients
      that are listed here are authorized to access the hidden
      service. Valid client names are 1 to 16 characters long and
      only use characters in A-Za-z0-9+-_ (no spaces). If this
      option is set, the hidden service is not accessible for
      clients without authorization any more. Generated
      authorization data can be found in the hostname file.
      Clients need to put this authorization data in their
      configuration file using HidServAuth.
EOF
}


examples(){
    cat <<EOL
## 0. Run script to append configurations and restart service
sudo ${__NAME__} --torrc='/etc/tor/torrc'\\
  --tor-lib-dir='/var/lib/tor'\\
  --tor-port='2222'\\
  --service-port='22'\\
  --client-names='ssh-tor-client'\\
  ssh_server


##> Above appends following to '/etc/tor/torrc'...
HiddenServiceDir /var/lib/tor/ssh_server
HiddenServicePort 2222 127.0.0.1 22
HiddenServiceAuthorizeClient stealth ssh-tor-client


## 1. After Tor service restarts 'ssh-tor-client' may be found via...
grep 'ssh-tor-client' /var/lib/tor/ssh_server/hostname
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
    '--tor-lib-dir|--tor-lib|--lib-dir:path'
    '--tor-port|--virt-port:alpha_numeric'
    '--service-port|--target-port:alpha_numeric'
    '--client-names|--clients|--client:list'
    '--service-name:posix-nil'
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
elif ! ((${#_client_names})); then
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
HiddenServiceDir ${_tor_lib_dir}/${_service_name}
HiddenServicePort ${_tor_port} 127.0.0.1 ${_service_port}
HiddenServiceAuthorizeClient stealth ${_client_names}
EOF


systemctl restart tor.service || {
    printf >&2 'Cannot restart Tor service\n'
    exit ${?:-1}
}


[[ -f "${_tor_lib_dir}/${_service_name}/hostname" ]] && {
  awk -v _client_names="${_client_names}" '{
    split(_client_names, _names, ",")
    for (_key in _names) {
      if ($5 == _names[_key]) {
        print "HidServAuth", $1, $2, "#", $5
      } else {
        print "Cannot find", _names[_key], "within hidden service hostname file"
      }
    }
  }' "${_tor_lib_dir}/${_service_name}/hostname"
} || {
  printf >&2 'Cannot find hidden service hostname file -> %s/hostname\n' "${_tor_lib_dir}/${_service_name}"
  exit ${?:-1}
}
