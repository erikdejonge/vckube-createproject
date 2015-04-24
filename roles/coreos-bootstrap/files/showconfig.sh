#!/bin/sh
echo -e "\033[0;34midentity:\033[0m"
echo -e "name: \033[0;91m"`hostname`"\033[0m"
version=`cat /etc/os-release | grep PRETTY_NAME | awk -F'=' '{print $2}' | tr -d '"'`
echo -e "version: \033[0;95m"`echo $version | awk '{print $1}'`"\033[0m\033[0;94m "`echo $version | awk '{print $2}'`"\033[0m"
echo 'ip:' `cat /etc/systemd/network/static.network | grep Address | awk -F'=' '{print $2}' | tr -d '"'`
echo 'flannel:' `cat /run/flannel/subnet.env | grep SUBNET | awk -F'=' '{print $2}' | tr -d '"'`
echo -e "\033[0;34msystemd:\033[0m"

function _dostatus() {
  stat=$(sudo systemctl status $1 | grep active | xargs echo)
  name=$1
  name=${name/.service/}
  if [ -z "$stat" ]
  then
    echo -e "\033[0;31m$name\033[0m"
  else
    echo -e "\033[0;32m$name\033[0m"
  fi;
}
function _units() {

  for unit in $units; do
    _dostatus $unit
  done;
}
function _failedunits() {

  for funit in $funits; do
    sudo systemctl status $funit
  done;
}
function _status() {
   units=$(systemctl list-units |  sed 's/[\d128-\d255]//g' | grep loaded | grep ".service" | grep -v systemd | grep -v "@" | awk '{print $1}')
   _units
   funits=$(systemctl list-units |  sed 's/[\d128-\d255]//g' | grep loaded | grep -v active | grep -v Reflects| awk '{print $1}')

   if [ "$funits" ]; then
       echo -e "\n\033[0;31m== Failed ==\033[0m"
   fi
   _failedunits
}
_status
