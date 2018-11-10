#!/usr/bin/env bash

# configure /etc/hosts file
echo "192.168.100.100   master master.local k8s.local phippy.local myapp.local nfsserver.local" >> /etc/hosts
echo "192.168.100.101   node01 node01.local" >> /etc/hosts
echo "192.168.100.102   node02 node02.local" >> /etc/hosts
echo "192.168.100.103   node03 node03.local" >> /etc/hosts