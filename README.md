# Deployment-2

Set up a CI/CD pipeline from start to finish. 

Using Elastic Beanstalk and customizing the pipeline. 

Deploying a [url-shortener](https://github.com/RichardDeodutt/kuralabs_deployment_2) Flask app. 

# Notes before starting

- These instructions use AWS. 

- These instructions are for the AWS Ubuntu image. 

- These instructions assume you are using a jenkins server and a jenkins agent to do all the work. 

- There are some shortcuts in the shortcut section to save time. It may be a good idea to check it first. 

# Instructions

## Step 1: Prepare the Jenkins server EC2 if you don't have one

- Create/Launch an EC2 using the AWS Console in your region of choice, `Asia Pacific (Tokyo) or ap-northeast-1` in my case.

- Set the `Name and tags` to anything you want, `Application and OS Images (Amazon Machine Image)` to Ubuntu 64-bit (x86), `Instance type` to t2.micro. 

- Set the `Key pair(login)` to any keypair you have access to or create one, `Network Settings` set the security group to one with ports 80, 8080 and 22 open or create one with those ports open. Launch with `default settings` for the rest is fine. 

- `SSH or connect` to the ec2 when it is running and `install` the `apt` packages `default-jre` and `jenkins` on the Jenkins server EC2 you just created if it isn't already installed. 

    Example below:

    ```
    sudo apt install default-jre && sudo apt install jenkins
    ```

## Step 2: Create a Jenkins user in your AWS account using IAM in the AWS Console

- Create a user in [AWS IAM](https://us-east-1.console.aws.amazon.com/iamv2/home) for jenkins to get access called `Eb-user` with `AdministratorAccess` permissions policy. 

- Save the information provided after creation such as the `Access key ID` and `Secret access key`

## Step 3: Connect GitHub to the Jenkins server

- Create/Generate a [personal access token in GitHub](https://github.com/settings/tokens) for the Jenkins server and webhook. I added all the `repo`, `admin:repo_hook` and `notifications` permissions. 

- Fork the [deployment repo](https://github.com/kura-labs-org/kuralabs_deployment_2) and using this repo connect it to the Jenkins server using the personal access token from GitHub by creating a Multibranch pipeline. 

- After it passed Jenkin's clone, build, and test phases connect Jenkin's webhook to the GitHub repository. 

## Step 4: Configure and deploy the application to Elastic Beanstalk

- On the Jenkins server as the 'jenkins' user run the command `AWS Configure` to configure Jenkins with the Jenkins user created through IAM. Giving the Jenkins server access to the your AWS account. 

- As the 'jenkins' user Navigating to the workspaces of the 'jenkins' user at the path `/var/lib/jenkins/workspace` and enter the directory of your project name which should be the one recently built by jenkins containing the application code and enviorment. 

- In the project directory recently entered as the 'jenkins' user run the `eb init` and `eb create` commands. 

## Step 5: Add a deployment stage to the pipeline

- On your fork created of the [deployment repo](https://github.com/kura-labs-org/kuralabs_deployment_2) edit your Jenkinsfile to add a deployment stage as. 

    ```
    stage ('Deploy') {
     steps {
       sh '/var/lib/jenkins/.local/bin/eb deploy url-shortener-dev'
     }
   }
    ```

## Step 6: Modify or add to the pipeline

- Add another test. 

- Add a way to notify you. 

- Use Cypress for testing. 

- Add a linter. 

- Change something on the application front. 

- Once done appy the changes and build the pipeline again. 

## Step 6: Diagram the new pipeline

- Create a diagram for the new pipeline. 

## Step 7: Create documentation

- Create documentation of everything. 

# Shortcuts

## Starting from scratch

### Deploy everything all in one (No Jenkins agents)

- You can use my [all in one deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/Deployment-Scripts/allinonedeployment.sh) during EC2 creation by copying and pasting it in the userdata field to automate installing Jenkins, the AWS CLI, the AWS EB CLI on the 'jenkins' user, the cy depends and the status check after a deployment.

- If the EC2 is created already you can run one of the commands below to run my [all in one deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/Deployment-Scripts/allinonedeployment.sh). 

    - If this is the first time deploying, run the command below. 
        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/allinonedeployment.sh && sudo chmod +x allinonedeployment.sh && sudo ./allinonedeployment.sh
        ```

    - If you want to redo the deployment, run the commmand below **but it will delete the 'Deployment-2' directory and the 'aws' directory created from the previous deployment.**

        ```
        cd && sudo rm -r Deployment-2 ; sudo rm -r aws ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/allinonedeployment.sh && sudo chmod +x allinonedeployment.sh && sudo ./allinonedeployment.sh
        ```

### Deploy everything in parts (With Jenkins agents)

- Jenkins Server Part

    - You can use my [jenkins deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/Deployment-Scripts/jenkinsdeployment.sh) during EC2 creation by copying and pasting it in the userdata field to automate installing Jenkins and the status check after a deployment. This will be the Jenkins server that controls the agents. 

    - If the EC2 is created already you can run the commands below to run my [jenkins deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/Deployment-Scripts/jenkinsdeployment.sh). 

        ```
        cd && sudo rm -r * ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/jenkinsdeployment.sh && sudo chmod +x jenkinsdeployment.sh && sudo ./jenkinsdeployment.sh
        ```

- Jenkins Agent Part

    - The Jenkins server should automatically create this agent and you only need to configure it correctly in the Jenkins server web interface to run the correct init script below. Replace the aws configurations with your `Eb-user` credentials and region. 

        ```

        cd && sudo rm -r * ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/agentdeployment.sh && sudo chmod +x agentdeployment.sh && sudo ./agentdeployment.sh

        #Add it to path now also
        source $HOME/.bashrc

        #Just making sure it's installed
        sudo apt install default-jre

        aws configure set aws_access_key_id 'access_key_id_goes_here' && aws configure set aws_secret_access_key 'access_secret_key_goes_here' && aws configure set region 'ap-northeast-1' && aws configure set output 'json'

        #Exit successs
        exit 0

        ```

    - If the EC2 is created already you can run the commands below to run my [agent deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/Deployment-Scripts/agentdeployment.sh). 

        ```

        cd && sudo rm -r * ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/agentdeployment.sh && sudo chmod +x agentdeployment.sh && sudo ./agentdeployment.sh

        ```

### Install parts separately

- If you just want to install a specific part run the corresponding script below.

    - To install Jenkins. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installjenkins.sh && sudo chmod +x installjenkins.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installjenkins.sh
        ```

    - To install the Jenkins agent. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installagent.sh && sudo chmod +x installagent.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installagent.sh
        ```

    - To install the AWS CLI. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installawscli.sh && sudo chmod +x installawscli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installawscli.sh
        ```

    - To install the AWS EB CLI as the 'jenkins' user. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installjenkinsawsebcli.sh && sudo chmod +x installjenkinsawsebcli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installjenkinsawsebcli.sh
        ```

    - To install the AWS EB CLI as the 'ubuntu' user. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installawsebcli.sh && sudo chmod +x installawsebcli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installawsebcli.sh
        ```

    - To install the Cy Depends.

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installcydepends.sh && sudo chmod +x installcydepends.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installcydepends.sh
        ```

    - To check the status after a deployment.

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/statuscheck.sh && sudo chmod +x statuscheck.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./statuscheck.sh
        ```

# Why?

# Issues