#!/bin/bash

#PACKER
mkdir -p /opt/downloads
cd /opt/downloads
wget https://releases.hashicorp.com/packer/1.3.0/packer_1.3.0_linux_amd64.zip
apt install -y unzip
unzip packer_1.3.0_linux_amd64.zip
cp packer /usr/local/bin

#TERRAFORM
mkdir -p /opt/downloads
cd /opt/downloads
wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
apt install -y unzip
unzip terraform_0.11.8_linux_amd64.zip
cp terraform /usr/local/bin

