#!/usr/bin/env bash

rm -rf output/k8s-base.box 2> /dev/null
vagrant package --output output/k8s-base.box 
vagrant box remove hlesey/k8s-base  2> /dev/null
vagrant box add output/k8s-base.box --name hlesey/k8s-base
