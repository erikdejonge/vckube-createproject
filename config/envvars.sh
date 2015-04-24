#!/bin/sh
alias bootj="sudo journalctl --boot"
alias cloudconfig="sudo coreos-cloudinit --from-file /var/lib/coreos-vagrant/vagrantfile-user-data"
alias jerr="sudo journalctl -f -p err; journalctl -xe"
alias hist="history"
alias jetcd="journalctl -u etcd"
alias jflannel="journalctl -u flannels"
alias jfleet="journalctl -u fleet"
alias jdocker="journalctl -u docker"
alias locate="sudo find / | grep $1"
alias lsfleet="sudo fleetctl list-machines; echo; sudo fleetctl list-units"
alias lsunits="systemctl list-units"
alias lsunitsfl="sudo fleetctl list-units"
alias lsmachfl="sudo fleetctl list-machines"

alias showcloudconfig='cat /var/lib/coreos-vagrant/vagrantfile-user-data'
alias stdocker="sudo systemctl status docker"
alias stetcd="sudo systemctl status etcd"
alias stflannel="sudo systemctl status flanneld"
alias stfleet="sudo systemctl status fleet"
alias stkubenode="sudo systemctl status kube-kubelet; sudo systemctl status kube-proxy"
alias stkubemaster="sudo systemctl status kube-apiserver; sudo systemctl status kube-controller-manager;  sudo systemctl status kube-register; sudo systemctl status kube-scheduler"
alias synctime="sudo systemctl stop ntpd.service;sudo ntpdate pool.ntp.org;sudo systemctl start ntpd.service"
alias jerr="journalctl -xe"

function _dostatus() {
  stat=$(sudo systemctl status $1 | grep active | xargs -0 echo)

  if [ -z "$stat" ]
  then
    echo -e $1": \033[0;31mfailed\033[0m"
  else
    echo -e $1": \033[0;32mactive\033[0m"
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
   units=$(systemctl list-units | sed 's/[\d128-\d255]//g' | grep loaded | grep ".service" | grep -v systemd | grep -v "@" | awk '{print $1}')
   _units
   funits=$(systemctl list-units | sed 's/[\d128-\d255]//g' | grep loaded | grep -v active | grep -v Reflects| awk '{print $1}')

   if [ "$funits" ]; then
       echo -e "\n\033[0;31m== Failed ==\033[0m"
   fi
   _failedunits
}
alias status="_status"
alias stats="_status"

export PATH=$PATH:$HOME/bin
