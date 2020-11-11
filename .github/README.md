# Torrific Ssh
[heading__top]:
  #torrific-ssh
  "&#x2B06; Scripts to configure SSH hidden service and client connections"


Scripts to configure SSH hidden service and client connections

## [![Byte size of Torrific Ssh][badge__master__torrific_ssh__source_code]][torrific_ssh__master__source_code] [![Open Issues][badge__issues__torrific_ssh]][issues__torrific_ssh] [![Open Pull Requests][badge__pull_requests__torrific_ssh]][pull_requests__torrific_ssh] [![Latest commits][badge__commits__torrific_ssh__master]][commits__torrific_ssh__master]

------


- [:arrow_up: Top of Document][heading__top]

- [:building_construction: Requirements][heading__requirements]

- [:zap: Quick Start][heading__quick_start]

- [&#x1F5D2; Notes][heading__notes]

- [:card_index: Attribution][heading__attribution]

- [:balance_scale: Licensing][heading__license]


------


## Requirements
[heading__requirements]:
  #requirements
  "&#x1F3D7; Prerequisites and/or dependencies that this project needs to function properly"


The Tor service must be installed prior to utilizing this project on both server and client devices, eg. for Debian based distributions installation may be a easy as...


```Bash
sudo apt-get install tor
```


------


Client devices should also install `socat` to proxy connections over Tor Socks port


```Bash
sudo apt-get install socat
```


------


This repository makes use of Git Submodules to track script run-time dependencies, to avoid incomplete downloads clone with the `--recurse-submodules` option...


```Bash
git clone --recurse-submodules git@github.com:paranoid-linux/torrific-ssh.git
```


To update tracked Git Submodules issue the following commands...


```Bash
git pull

git submodule update --init --merge --recursive
```


To force upgrade of Git Submodules...


```Bash
git submodule update --init --merge --recursive --remote
```


> Note, forcing and update of Git Submodule tracked dependencies may cause instabilities and/or merge conflicts; if however everything operates as expected after an update please consider submitting a Pull Request.


___


## Quick Start
[heading__quick_start]:
  #quick-start
  "&#9889; Perhaps as easy as one, 2.0,..."


Clone this project and the submodules that it depends upon...


```Bash
git clone --recurse-submodules git@github.com:paranoid-linux/torrific-ssh.git
```


Change current working directory...


```Bash
cd torrific-ssh
```


Use `-h` or `--help` option to list available command-line parameters...


```Bash
sudo ./torrific-ssh-server.sh --help
```


On the server configure Tor hidden service for SSH via `torrific-ssh-server.sh` script...


```Bash
sudo ./torrific-ssh-server.sh --client='pi'
```


> Note, setting up the server within a Docker container is now possible via...


```Bash
docker run --name torrific-ssh --client 'pi'
```


On each client device configure via `torrific-ssh-client.sh` script...


```Bash
sudo ./torrific-ssh-client.sh --host-name="yourgeneratedaddress.onion"\
                              --auth="S0meLet7er5AndNumbers"\
                              --identity-file='~/.ssh/id_rsa'\
                              'pi'
```


Test that connection can be established on each client device...


```Bash
ssh tor-pi
```


___


## Notes
[heading__notes]:
  #notes
  "&#x1F5D2; Additional things to keep in mind when developing"


Configurations for SSH server may be further customized via `torrific-ssh-server.sh` script, eg...


```Bash
sudo ./torrific-ssh-server.sh --torrc='/etc/tor/torrc'\
  --tor-lib-dir='/var/lib/tor'\
  --tor-port='2222'\
  --service-port='22'\
  --client-names='first-client,second-client,third-client'\
  ssh_server
```


... and via `torrific-ssh-client.sh` script there are additional optional configuration options, eg...


```Bash
sudo ./torrific-ssh-client.sh --host-name="yourgeneratedaddress.onion"\
  --auth="S0meLet7er5AndNumbers"\
  --torrc='/etc/tor/torrc'\
  --identity-file='~/.ssh/id_rsa'\
  --ssh-config='~/.ssh/config'\
  --ssh-host='tor-pi'\
  --port='2222'
  'pi'
```


------


Pull Requests are certainly welcomed if bugs are found or new features are wanted.


___


## Attribution
[heading__attribution]:
  #attribution
  "&#x1F4C7; Resources that where helpful in building this project so far."


- [GitHub -- `github-utilities/make-readme`](https://github.com/github-utilities/make-readme)

- [Reddit -- Creating an undiscoverable Tor hidden service](https://www.reddit.com/r/TOR/comments/549wuw/creating_an_undiscoverable_secure_tor_hidden/d81197p/)

- [Medium -- How to SSH over Tor Onion service](https://medium.com/@tzhenghao/how-to-ssh-over-tor-onion-service-c6d06194147)

- [Tor StackExchange -- How to use hidden service authentication](https://tor.stackexchange.com/questions/219)

- [Tor StackExchange -- using `hidservauth`](https://tor.stackexchange.com/questions/16366)

- [Tor Project Community -- Onion Services setup](https://community.torproject.org/onion-services/setup/)


___


## License
[heading__license]:
  #license
  "&#x2696; Legal side of Open Source"


```
Scripts to configure SSH hidden service and client connections
Copyright (C) 2020 S0AndS0

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```


For further details review full length version of [AGPL-3.0][branch__current__license] License.



[branch__current__license]:
  /LICENSE
  "&#x2696; Full length version of AGPL-3.0 License"


[badge__commits__torrific_ssh__master]:
  https://img.shields.io/github/last-commit/paranoid-linux/torrific-ssh/master.svg

[commits__torrific_ssh__master]:
  https://github.com/paranoid-linux/torrific-ssh/commits/master
  "&#x1F4DD; History of changes on this branch"


[torrific_ssh__community]:
  https://github.com/paranoid-linux/torrific-ssh/community
  "&#x1F331; Dedicated to functioning code"


[badge__issues__torrific_ssh]:
  https://img.shields.io/github/issues/paranoid-linux/torrific-ssh.svg

[issues__torrific_ssh]:
  https://github.com/paranoid-linux/torrific-ssh/issues
  "&#x2622; Search for and _bump_ existing issues or open new issues for project maintainer to address."


[badge__pull_requests__torrific_ssh]:
  https://img.shields.io/github/issues-pr/paranoid-linux/torrific-ssh.svg

[pull_requests__torrific_ssh]:
  https://github.com/paranoid-linux/torrific-ssh/pulls
  "&#x1F3D7; Pull Request friendly, though please check the Community guidelines"


[badge__master__torrific_ssh__source_code]:
  https://img.shields.io/github/repo-size/paranoid-linux/torrific-ssh

[torrific_ssh__master__source_code]:
  https://github.com/paranoid-linux/torrific-ssh/
  "&#x2328; Project source!"
