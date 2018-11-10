#!/usr/bin/env bash

vagrant package --output output/k8s-base.box 
vagrant box add output/k8s-base.box --name qedzone/k8s-base
