# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "router" do |router|


  # Box que utilizaremos
    router.vm.box = "ubuntu/xenial64"
  # Hostname
    router.vm.hostname = "router"

  # Aprovisionamiento
    router.vm.provision "shell", path: "routerSetup.sh", privileged: true

  # Red
    router.vm.network "private_network", ip: "172.25.52.1", virtualbox__intnet: "LAN1"
    router.vm.network "private_network", ip: "172.22.52.1", virtualbox__intnet: "LAN2"

    router.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", 256]
    end

  end

# Pool 1
  config.vm.define "master1" do |master1|

# Box que utilizaremos
    master1.vm.box = "ubuntu/xenial64"
    master1.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", 512]
    end
# Aprovisionamiento
    master1.vm.provision "shell", path: "master1Installer.sh", privileged: true
# Hostname
    master1.vm.hostname = "master1"

# Red privada
    master1.vm.network "private_network", ip: "172.22.52.18", virtualbox__intnet: "LAN2"

  end


# Nodo de procesamiento 1
  config.vm.define "node1" do |node1|

# Box que utilizaremos
      node1.vm.box = "ubuntu/xenial64"

# Hostname
      node1.vm.hostname = "node1"

# Red privada
      node1.vm.network "private_network", ip: "172.22.52.19", virtualbox__intnet: "LAN2"

# Aprovisionamiento
      node1.vm.provision "shell", path: "node1Installer.sh", privileged: true

# Configuracion memoria
      node1.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", 512]
      end

  end


# Pool 2
  config.vm.define "master2" do |master2|


  # Box que utilizaremos
    master2.vm.box = "ubuntu/xenial64"
  # Hostname
    master2.vm.hostname = "master2"

  # Aprovisionamiento
    master2.vm.provision "shell", path: "master2Installer.sh", privileged: true

  # Red privada
    master2.vm.network "private_network", ip: "172.25.52.18", virtualbox__intnet: "LAN1"

# Configuracion memoria
    master2.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", 512]
    end

  end


  # Nodo de procesamiento 2
    config.vm.define "node2" do |node2|

  # Box que utilizaremos
        node2.vm.box = "ubuntu/xenial64"

  # Hostname
        node2.vm.hostname = "node2"

  # Red privada
        node2.vm.network "private_network", ip: "172.25.52.19", virtualbox__intnet: "LAN1"

  # Aprovisionamiento
        node2.vm.provision "shell", path: "node2Installer.sh", privileged: true

  # Configuracion memoria
        node2.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--memory", 512]
        end

    end

end
