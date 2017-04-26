#!/bin/bash

if [ $(which apt-get) ];
then
    sudo apt-get update
    PKG_MANAGER="apt-get"
    PKGS="python python-dev git curl"
else
    PKG_MANAGER="yum"
    PKGS="python python-devel git curl"
fi

sudo $PKG_MANAGER -y install $PKGS

if [ $(which pip) ];
then
    echo ''
else
    curl -L "https://bootstrap.pypa.io/get-pip.py" > get_pip.py
    sudo python get_pip.py
    rm get_pip.py
    sudo pip install gitpython
fi

sudo pip install git+https://github.com/mitodl/testinfra@python_ruby_package#egg=testinfra

if [ "$(ls /vagrant)" ]
then
    SRCDIR=/vagrant
else
    SRCDIR=/home/vagrant/sync
fi
echo "Source directory is $SRCDIR"
sudo mkdir -p /srv/salt
sudo mkdir -p /srv/pillar
sudo mkdir -p /srv/formulas
sudo cp $SRCDIR/pillar.example /srv/pillar/pillar.sls
sudo cp -r $SRCDIR/elasticsearch /srv/salt
echo "\
base:
  '*':
    - pillar" | sudo tee /srv/pillar/top.sls
echo "\
base:
  'roles:elasticsearch':
    - match: grain
    - elasticsearch
    - elasticsearch.plugins
    - elasticsearch.elastalert
  'roles:kibana':
    - match: grain
    - elasticsearch.kibana
    - elasticsearch.kibana.nginx_extra_config" | sudo tee /srv/salt/top.sls
