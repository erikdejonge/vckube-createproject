#!/bin/sh
echo "add keys"
ssh-add ./keys/secure/vagrantsecure
ssh-add ./keys/insecure/vagrant

echo 'restart vmware network'
if [ "$(uname)" == "Darwin" ]; then
    sudo vmnet-cli --stop
    sleep 1
    sudo vmnet-cli --start
    sleep 2
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    sudo /usr/bin/vmware-networks --stop
    sleep 1
    sudo /usr/bin/vmware-networks --start
    sleep 2
fi

echo "localize"
vckube localizemachine

echo "start cluster"
vagrant up

while [ $? -ne 0 ]; do
    echo "start cluster, retry"
    vagrant up
done
echo "done"
