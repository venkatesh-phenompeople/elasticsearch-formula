#!/bin/bash

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
  'roles:kibana':
    - match: grain
    - elasticsearch.kibana
    - elasticsearch.kibana.nginx_extra_config" | sudo tee /srv/salt/top.sls
