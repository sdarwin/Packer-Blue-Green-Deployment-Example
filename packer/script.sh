#!/bin/bash
#
DEPLOYMENTENV="staging"
INVENTORY="inventories-aws/$DEPLOYMENTENV"
DEPLOYMENTUSER="wpdeploy"
PACKERUSER="ubuntu"
DEPLOYMENTANSIBLEBASE="/opt/ansible"
DEPLOYMENTANSIBLEDIR="/opt/ansible/Ansible-Wordpress-Playbooks"
DEPLOYMENTANSIBLEURL="git@github.com:sdarwin/Ansible-Wordpress-Playbooks.git"
#DEPLOYMENTGROUP="tag_wpappservers"
DEPLOYMENTGROUP="tag_role_wpappservers"
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible
sudo mkdir -p $DEPLOYMENTANSIBLEBASE
sudo chown $PACKERUSER $DEPLOYMENTANSIBLEBASE
cd $DEPLOYMENTANSIBLEBASE 
ssh-keyscan github.com >> ~/.ssh/known_hosts
if [ ! -d "$DEPLOYMENTANSIBLEDIR" ] ; then
    git clone --recurse-submodules $DEPLOYMENTANSIBLEURL $DEPLOYMENTANSIBLEDIR
else
    cd "$DEPLOYMENTANSIBLEDIR"
    git pull $DEPLOYMENTANSIBLEURL
fi
cd $DEPLOYMENTANSIBLEDIR
echo -e "[$DEPLOYMENTGROUP]\nlocalhost ansible_connection=local" | sudo tee $INVENTORY/hosts > /dev/null
ansible-playbook -i $INVENTORY bootstrap.yml 
#ansible_connection=local doesn't let you set remote user. Here is a work-around.
setfacl -m $DEPLOYMENTUSER:x   $(dirname "$SSH_AUTH_SOCK")
setfacl -m $DEPLOYMENTUSER:rwx "$SSH_AUTH_SOCK"
sudo -E su $DEPLOYMENTUSER -c "ssh-keyscan github.com >> ~/.ssh/known_hosts;cd $DEPLOYMENTANSIBLEDIR;ansible-playbook -i $INVENTORY deploy.yml"

