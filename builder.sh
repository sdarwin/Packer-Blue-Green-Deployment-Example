#!/bin/bash

set -e 
help=n nb=n nd=n
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --nb)
    nb=y
    shift # past argument
    ;;
    --nd)
    nd=y
    shift # past argument
    ;;
    -h|--help)
    help=y
    shift # past argument
    ;;
    *)    # unknown option
    shift # past argument
    ;;
esac
done
#echo "nb is $nb and nd is $nd"

help()
{
  echo " "
  echo "builder.sh is a script to build AMIs with packer, and deploy to autoscaling groups with Terraform."
  echo " "
  echo "Usage: builder.sh --nb --nd --help"
  echo "--nb is 'no build/bake'. An AMI will not be built. Can also be achieved by placing a file at packer/nobuild.txt"
  echo "--nd is 'no deploy'. The autoscaling groups will not be updated. Can also be achieved by placing a file at packer/nodeploy.txt"
  echo "-h|--help shows this message."
  echo " "
  echo "Example:"
  echo "./builder.sh"
  echo "Both build and deploy will run."
  echo " "
  exit 0
}

if [ "$help" = "y" ]; then
  help
fi

startingdir=$(pwd)
bake()
{
  cd packer
  if [ -f nobuild.txt ] || [ "$nb" = "y" ] ; then
    if [  $(cat ami.txt | grep ami) ]; then
      echo " "
      echo "NOTE!!"
      echo " "
      echo "Per request, bake cycle will be skipped."
      echo " "
      return 0
    else
      echo " "
      echo "NOTE!!"
      echo " "
      echo "Planning to skip build/bake cycle. However, the file packer/ami.txt doesn't contain the a valid AMI, or doesn't even exist."
      echo "Choices are: don't skip the build, or else put a valid AMI into packer/ami.txt"
      echo " "
      exit 1
    fi
  fi
  #Otherwise proceeding with the bake cycle
  rm -f packer_output.txt ami.txt
  /usr/local/bin/packer build -machine-readable -var-file=variables.json app.json | tee packer_output.txt
  cat packer_output.txt| egrep 'artifact,0,id' | cut -f6 -d, | cut -f2 -d: > ami.txt
  AMI=$(cat ami.txt)
  if [ ! $(cat ami.txt | grep ami) ]; then
    echo " "
    echo "Something has likely gone wrong with the build. Can't find ami value. Exiting."
    echo " "
    exit 1
  fi
}

#Call the Bake cycle
bake

#Call the deploy cycle with terraform

if [ -f nodeploy.txt ] || [ "$nd" = "y" ]; then
  echo " "
  echo "NOTE!!"
  echo " "
  echo "Per request, skipping deploy."
  echo " "
  exit 0
fi
 
cd $startingdir
AMI="$(cat packer/ami.txt|tr -d '\n')"
terraform apply -var "ami=$AMI" -auto-approve

