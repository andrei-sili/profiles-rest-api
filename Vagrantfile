# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_version = "~> 20190314.0.0"

  # Synced folder (Windows <-> VM)
  config.vm.synced_folder ".", "/vagrant"

  # Port forwarding
  config.vm.network "forwarded_port", guest: 8000, host: 8000

  # Optional DHCP networking (pentru unele aplicații)
  # config.vm.network "private_network", type: "dhcp"

  # Timeout boot (pentru sisteme lente)
  config.vm.boot_timeout = 600

  # Provisioning
  config.vm.provision "shell", inline: <<-SHELL
    systemctl disable apt-daily.service
    systemctl disable apt-daily.timer

    sudo apt-get update
    sudo apt-get install -y python3-venv zip

    touch /home/vagrant/.bash_aliases

    if ! grep -q PYTHON_ALIAS_ADDED /home/vagrant/.bash_aliases; then
      echo "# PYTHON_ALIAS_ADDED" >> /home/vagrant/.bash_aliases
      echo "alias python='python3'" >> /home/vagrant/.bash_aliases
    fi
  SHELL
end
