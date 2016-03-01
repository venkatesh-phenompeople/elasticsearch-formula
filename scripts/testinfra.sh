#!/bin/bash

if [[ -z $(which pip) ]]
then
    sudo salt-call --local pkg.install python-pip
fi
if [[ -z $(which testinfra) ]]
then
    sudo pip install testinfra
fi
sudo rm -rf /vagrant/tests/__pycache__
testinfra /vagrant/tests
