pipeline {
    agent any
    environment { 
        BAKE = 'yes'
        DEPLOY = 'yes'
    }
    stages {
        stage('Bake') {
            when { environment name: 'BAKE', value: 'yes' }
            steps {
		checkout scm
     sshagent (credentials: ['f10b7529-200d-4d52-9055-993ef0fffd8d	']) {
              sh '''
  set -e
  cd packer
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
'''
            }
            }
        }
        stage('Deploy') {
            when { environment name: 'DEPLOY', value: 'yes' }
            steps {
		checkout scm
     sshagent (credentials: ['f10b7529-200d-4d52-9055-993ef0fffd8d	']) {
              sh '''
set -e
AMI="$(cat packer/ami.txt|tr -d '\n')"
echo "AMI is $AMI"
if [ ! $AMI ]; then
    echo " "
    echo "Something has likely gone wrong with the build. Can't find ami value. Exiting."
    echo " "
    exit 1
  fi
terraform init
terraform apply -var "ami=$AMI" -auto-approve

'''
            }
        }
    }
}
}

