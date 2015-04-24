#!/bin/sh
rm -f ./vagrantsecure*
ssh-keygen -t rsa -C "core user vagrant" -b 4096 -f ./vagrantsecure -N ""