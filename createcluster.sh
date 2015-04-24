#!/bin/sh
sudo date

function _killallpythonprocs() {
  killall python3 2> /dev/null;  killall Python 2> /dev/null;  killall python3 2> /dev/null;  killall Python 2> /dev/null;  killall pypy 2> /dev/null;  killall python3 2> /dev/null;  killall Python3 2> /dev/null;  killall python3 2> /dev/null;  killall Python3 2> /dev/null;  killall pypy3 2> /dev/null;
}
_killallpythonprocs

rm -f hosts
rm -f ./configscripts/user-data*

if [ -d ".vagrant" ]; then
  echo ".vagrant directory still exsists (forgot deletecluster.sh?)"
  exit
fi

echo "Update vagrant image"
vagrant box update

echo "Add vagrant insecure keys"
ssh-add keys/insecure/vagrant

echo "preparing start"
rm -Rf .cl
vckube up
while [ $? -ne 0 ]; do
    vckube up
done

echo 'request coreos token'
if [ "$(uname)" == "Darwin" ]; then
    vckube coreostoken > config/tokenosx.txt
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    vckube coreostoken > config/tokenlinux.txt
fi

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

echo "Bring machines up"
rm -f ~/.ssh/known_hosts
vagrant up
while [ $? -ne 0 ]; do
    echo "** vagrant up"
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
    vagrant up
done


vagrant up



