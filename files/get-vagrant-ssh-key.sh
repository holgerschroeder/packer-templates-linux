#!/bin/bash -e
# get the "vagrant insecure ssh key",
# then we can put it into the vm, and
# vagrant can log into it with a ssh key,
# without the need for a vagrant password
wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub'
