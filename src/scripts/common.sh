#!/usr/bin/env bash

source /src/scripts/vars

# configure /etc/hosts file
echo "$MASTER_IP   master master.local nfsserver.local" >> /etc/hosts
echo "$NODE01_IP   node01 node01.local"                 >> /etc/hosts
echo "$NODE02_IP   node02 node02.local"                 >> /etc/hosts
echo "$NODE03_IP   node03 node03.local"                 >> /etc/hosts