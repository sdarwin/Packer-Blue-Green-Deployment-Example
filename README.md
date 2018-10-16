
Packer Blue Green Deployment Example

A multi-stage deployment implementation using Packer, Terraform and AWS autoscaling.

There are two different ways to run this, which is as Jenkins Jobs, or from the command-line with a bash script. Here are instructions for each case.

JENKINS
- install Jenkins on a server, or use an existing Jenkins server
- on that machine, clone this repository:
```
mkdir -p /opt/github
cd /opt/github
git clone https://github.com/sdarwin/packer-blue-green-deployment-example blue-green
cd blue-green
```
- To install Packer and Terraform 
```
sudo scripts/install.sh
```
- Customize the files terraform.tfvars and packer/variables.json, since they contain secret keys, regions, and many specific variables for your environment.
- In this example, the new repo is on the jenkins machine at /opt/github/blue-green.  Check in your changes: 
```
git add .
git commit
```
- Optionally, add github remotes, connecting /opt/github/blue-green to your github account.
- The jenkins subdirectory in this repo contains multiple jobs. Copy these jobs into your Jenkins home directory, for example:
```
cp -rp jenkins/Bake /var/lib/jenkins/jobs/
cp -rp jenkins/Deploy /var/lib/jenkins/jobs/
cp -rp jenkins/Pipeline /var/lib/jenkins/jobs/
```
Reload Jenkins.
These jobs will need to be customized. It is probably easier from the Jenkins web console, than in the xml, although both are possible.
- Install the Jenkins SSH Agent Plugin
- Create an SSH key in Credentials
- Review all the settings in the jobs, from beginning to end, and customize as necessary.

The Bake and Deploy jobs are standard Freestyle projects. The Pipeline job is a pipeline (formerly known as workflows). Either will work.

----

COMMAND-LINE ALTERNATIVE

This is a different methodology.

Rather than Jenkins, you may instead just run the included ./builder.sh to deploy. 

- "sudo scripts/install.sh", to install Packer and Terraform
- Customize the files terraform.tfvars and packer/variables.json
- "terraform init" to initialize terraform.
- "./builder.sh -h" to see the options for building and deploying.
- "./builder.sh" to proceed.

