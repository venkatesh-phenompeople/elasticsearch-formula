#!/bin/bash

sudo mkdir -p /srv/salt
sudo mkdir -p /srv/pillar
sudo mkdir -p /srv/formulas
sudo cp /vagrant/pillar.example /srv/pillar/pillar.sls
sudo cp -r /vagrant/elasticsearch /srv/salt
echo "\
base:
  '*':
    - pillar" | sudo tee /srv/pillar/top.sls
echo "\
base:
  '*':
    - elasticsearch
    - elasticsearch.plugins" | sudo tee /srv/salt/top.sls
