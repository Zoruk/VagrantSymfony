# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "deb/wheezy-amd64"
  config.vm.provision :shell, path: "setup.sh"
  config.vm.provision :shell, path: "xdebug_ip.sh", run: "always"
  config.vm.network :forwarded_port, host: 8080, host_ip: "127.0.0.1", guest: 80
  config.vm.network :forwarded_port, host: 8081, host_ip: "127.0.0.1", guest: 85
  config.vm.synced_folder "./", "/vagrant", id: "vagrant-root",
    owner: "vagrant",
    group: "www-data",
    mount_options: ["dmode=775,fmode=664"]

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
	vb.cpus = 2
    vb.memory = "512"
  end
end
