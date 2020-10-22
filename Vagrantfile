# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
BOX_IMAGE="hlesey/k8s-base"
BOX_VERSION="1.18.2.2"
required_plugins = %w(vagrant-vbguest)

cluster = {                                                  
  "control-plane" => { :ip => "192.168.234.100", :cpus => 2, :mem => 2048 },
  "node01" => { :ip => "192.168.234.101", :cpus => 2, :mem => 1280 },
  "node02" => { :ip => "192.168.234.102", :cpus => 2, :mem => 1280 },
}

required_plugins.each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  cluster.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |cfg|
      cfg.vm.provider :virtualbox do |vb, override|
        config.vm.box = BOX_IMAGE
        config.vm.box_version = BOX_VERSION
        config.vm.boot_timeout = 900
        override.vm.network :private_network, ip: "#{info[:ip]}"
        override.vm.hostname = hostname + ".local"

        if hostname.include? "control-plane"
          override.vm.provision "shell", path: "src/scripts/common.sh"
          override.vm.provision "shell", path: "src/scripts/control-plane.sh"
          override.vm.provision "shell", path: "src/scripts/nfs.sh"
          override.vm.network :forwarded_port, guest: 30080, host: 30080, id: 'ingress-http'
          override.vm.network :forwarded_port, guest: 30443, host: 30443, id: 'ingress-https'
        else
          override.vm.provision "shell", path: "src/scripts/common.sh"
          override.vm.provision "shell", path: "src/scripts/node.sh"
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
          "--ioapic", "on",
          # https://github.com/joelhandwell/ubuntu_vagrant_boxes/issues/1
          # "--uartmode1", "disconnected",
          "--uartmode1", "file", File.join(Dir.pwd, hostname + "-console.log")
        ]
      end # end provider
    end # end config
  end # end cluster
end

module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end
    def OS.unix?
        !OS.windows?
    end
    def OS.linux?
        OS.unix? and not OS.mac?
    end
end
