# Deployment-2

Set up a CI/CD pipeline from start to finish. 

Using Elastic Beanstalk and customizing the pipeline. 

Deploying a [url-shortener](https://github.com/RichardDeodutt/kuralabs_deployment_2) Flask app

# Notes before starting

- These instructions use AWS.

- These instructions are for the AWS Ubuntu image.

- There are some shortcuts in the shortcut section. 

# Instructions

## Step 1: Prepare the Jenkins server EC2 if you don't have one

- Create a EC2 using the AWS Console and set the correct ssh keys, security group and open ports. 

- Install Jenkins on the Jenkins server EC2 if it isn't already.

- Install the AWS CLI on the Jenkins server EC2 if it isn't already.

- Install the AWS EB CLI on the Jenkins server EC2 using the 'jenkins' user if it isn't already.

## Step 2: Create a Jenkins user in your AWS account using IAM in the AWS Console

# Shortcuts

## Starting from scratch

- You can use my [deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/deployment.sh) during EC2 creation in the userdata field to automate installing Jenkins, the AWS CLI and the AWS EB CLI on the 'jenkins' user. 

- If the EC2 is created already you can run one of the commands below to run my [deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/deployment.sh)

    - If this is the first time deploying, run the command below
        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/deployment.sh && sudo chmod +x deployment.sh && sudo ./deployment.sh
        ```

    - If you want to redo the deployment, run the commmand below **but it will delete the 'Deployment-2' directory and the 'aws' directory created from the previous deployment.**

        ```
        cd && sudo rm -r Deployment-2 ; sudo rm -r aws ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/deployment.sh && sudo chmod +x deployment.sh && sudo ./deployment.sh
        ```
- If you just want to install a specific part run the corresponding script below

    - Install Jenkins
        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installjenkins.sh && sudo chmod +x installjenkins.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installjenkins.sh
        ```
    - Install the AWS CLI
        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installawscli.sh && sudo chmod +x installawscli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installawscli.sh
        ```
    - Install the AWS EB CLI as the 'jenkins' user
        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installawsebcli.sh && sudo chmod +x installawsebcli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installawsebcli.sh
        ```