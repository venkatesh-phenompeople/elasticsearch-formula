# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  config.vm.define "elasticsearch" do |elasticsearch|
    elasticsearch.vm.box = "debian/jessie64"
    elasticsearch.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
    end
    elasticsearch.vm.network "private_network", ip: "192.168.33.11"
    elasticsearch.vm.provision "shell", path: "scripts/vagrant_setup.sh"
    elasticsearch.vm.provision :salt do |salt|
      salt.bootstrap_options = '-U -Z'
      salt.masterless = true
      salt.run_highstate = true
      salt.colorize = true
      salt.verbose = true
      salt.grains_config = "grains/elasticsearch.yml"
    end
    elasticsearch.vm.provision "shell" do |testinfra|
      testinfra.path = "scripts/testinfra.sh"
      testinfra.args = ["-k not kibana and not nginx"]
    end
  end

  config.vm.define "kibana" do |kibana|
    kibana.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    kibana.vm.box = "debian/jessie64"
    kibana.vm.network "private_network", ip: "192.168.33.10"
    kibana.vm.provision "shell", path: "scripts/vagrant_setup.sh"
    kibana.vm.provision :salt do |salt|
      salt.bootstrap_options = '-U -Z'
      salt.masterless = true
      salt.run_highstate = true
      salt.colorize = true
      salt.verbose = true
      salt.grains_config = "grains/kibana.yml"
    end
    kibana.vm.provision "shell", "path": "scripts/testinfra.sh"
  end

end
