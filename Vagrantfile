# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "deb/wheezy-amd64"
  config.vm.provision :shell, path: "setup.sh"
  config.vm.network :forwarded_port, host:8080, host_ip:"127.0.0.1", guest: 80
  config.vm.network :forwarded_port, host:8081, host_ip:"127.0.0.1", guest: 85
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
	vb.cpus = 2
    vb.memory = "512"
  end
end
