#!/bin/sh
killall python; killall Python; redis-cli flushall;killall python; killall Python; killall pypy;
echo "Ensure pip directory"
vckube clustercommand "sudo mkdir /root/pypy&&sudo ln -s /home/core/bin /root/pypy/bin"

echo "Python and pip"
vckube ansibleplaybook all:./playbooks/ansiblebootstrap.yml
vckube ansibleplaybook all:./playbooks/testansible.yml

echo "Generate new keys"
cd keys/secure&&./genpair.sh&&cd ../..
ssh-add keys/secure/vagrantsecure

echo "Replace insecure keys with new keys"
vckube ansibleplaybook all:./playbooks/keyswap.yml

echo "Restart cluster with new token"
vckube replacecloudconfig

