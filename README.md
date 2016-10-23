# lhs-ansible
Ansible playbooks to configure my linux based router/nas/htpc/whatever box. The name lhs stands for libesz home server.
The machine's configuration is now represented by ansible playbooks.
### Current roles:
- PPPoE client.
- Router with 2 NIC. Ports and WLAN is realized with a gigabit switch and an access point on the lan side.
- DLNA server with minidlna.
- Rtorrent + webui for downloading stuff.
- Samba for a regular NAS.
- Git server for private repos.

### Prerequisites:
- Install minimal debian strech OS with ssh.
- The first user supposed to have sudo and UID 1000 (shall be configurable in the future).
- Suggested to correctly rename the semi-random network card names from like enp3s0 to lan0 and wan0 [with udev rules](http://www.cyberciti.biz/faq/howto-linux-rename-ethernet-devices-named-using-udev/).
- Add static IP address for the LAN side (as this is the router, nobody will add an IP address on DHCP).
- Prepare the main playbook file by filling the missing variables.

### Enjoy
After well prepared, create an inventory file with the static IP address and push the state with ansible like:
> ansible-playbook -v --ask-sudo-pass lhs.yml
