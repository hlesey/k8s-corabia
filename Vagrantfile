# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
BOX_IMAGE="centos/7"


required_plugins = %w(vagrant-vbguest vagrant-share)

required_plugins.each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "4", "--ioapic", "on"]
  end

  config.vm.synced_folder "../", "/repo", id: "repo",
    owner: "vagrant",
    group: "vagrant",
    mount_option: ["dmode=777,fmode=777"]

  config.vm.synced_folder "scripts", "/scripts", id: "scripts",
    owner: "vagrant",
    group: "vagrant",
    mount_option: ["dmode=777,fmode=777"]

  # master node
  config.vm.define "master", autostart:false do |master|
    master.vm.box = BOX_IMAGE
    master.vm.network :private_network, ip:"192.168.100.100"
    master.vm.network :forwarded_port, guest: 22, host: 22100, id: 'ssh'
    master.vm.hostname = 'master.local'
    master.vm.provision "shell", path: "scripts/install_kubeadm.sh"
    master.vm.provision "shell", path: "scripts/nfs.sh"
    master.vm.provision "shell", path: "scripts/master.sh"
  end

  # slave node
  config.vm.define "node01", autostart:false do |node|
    node.vm.box = BOX_IMAGE
    node.vm.network :private_network, ip:"192.168.100.101"
    node.vm.network :forwarded_port, guest: 22, host: 22101, id: 'ssh'
    node.vm.hostname = 'node01.local'
    node.vm.provision "shell", path: "scripts/install_kubeadm.sh"
    node.vm.provision "shell", path: "scripts/minion.sh"
  end

  # slave node
  config.vm.define "node02", autostart:false do |node|
    node.vm.box = BOX_IMAGE
    node.vm.network :private_network, ip:"192.168.100.102"
    node.vm.network :forwarded_port, guest: 22, host: 22102, id: 'ssh'
    node.vm.hostname = 'node02.local'
    node.vm.provision "shell", path: "scripts/install_kubeadm.sh"
    node.vm.provision "shell", path: "scripts/minion.sh"
  end
end

