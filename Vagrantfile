# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
BOX_IMAGE="hlesey/k8s-base"
BOX_VERSION="1.15.1"
# BOX_VERSION="0"
required_plugins = %w(vagrant-vbguest vagrant-share)

required_plugins.each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

cluster = {                                                  
  "master" => { :ip => "192.168.100.100", :cpus => 4, :mem => 2048 },
  "node01" => { :ip => "192.168.100.101", :cpus => 2, :mem => 1024 },
  "node02" => { :ip => "192.168.100.102", :cpus => 2, :mem => 1024 },
}
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  cluster.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |cfg|
      cfg.vm.provider :virtualbox do |vb, override|
        config.vm.box = BOX_IMAGE
        config.vm.box_version = BOX_VERSION
        override.vm.network :private_network, ip: "#{info[:ip]}"
        override.vm.hostname = hostname + ".local"

        if hostname.include? "master" 
          override.vm.provision "shell", path: "src/scripts/common.sh"
          override.vm.provision "shell", path: "src/scripts/master.sh"
          override.vm.provision "shell", path: "src/scripts/nfs.sh"
        else
          override.vm.provision "shell", path: "src/scripts/common.sh"
          override.vm.provision "shell", path: "src/scripts/minion.sh"
        end
        
        override.vm.synced_folder "../", "/repo", id: "repo",
        owner: "vagrant",
        group: "vagrant",
        mount_option: ["dmode=777,fmode=777"]
       
        override.vm.synced_folder "src", "/src", id: "scripts",
        owner: "vagrant",
        group: "vagrant",
        mount_option: ["dmode=777,fmode=777"]

        vb.name = hostname
        vb.customize [
          "modifyvm", :id, 
          "--memory", info[:mem], 
          "--cpus", info[:cpus], 
          "--hwvirtex", "on", 
          "--uartmode1", "disconnected",
          "--nested-hw-virt", "on",
          "--ioapic", "on"
        ]
      end # end provider
    end # end config
  end # end cluster
end
