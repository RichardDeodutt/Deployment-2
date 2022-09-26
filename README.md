# Deployment-2

Set up a CI/CD pipeline from start to finish. 

Using Elastic Beanstalk and customizing the pipeline. 

Deploying a [url-shortener](https://github.com/RichardDeodutt/kuralabs_deployment_2) Flask app. 

# Notes before starting

- These instructions use AWS. 

- These instructions are for the AWS Ubuntu image. 

- These instructions assume you are using the 'ubuntu' user and sometimes 'jenkins' user. 

- There are some shortcuts in the shortcut section to save time. It may be a good idea to check it first. 

# Instructions

## Step 1: Prepare the Jenkins server EC2 if you don't have one

- Create a EC2 using the AWS Console and set the correct ssh keys, security group and open ports. 

- Install Jenkins on the Jenkins server EC2 if it isn't already. 

- Install the AWS CLI on the Jenkins server EC2 if it isn't already. 

- Install the AWS EB CLI on the Jenkins server EC2 using the 'jenkins' user if it isn't already. 

## Step 2: Create a Jenkins user in your AWS account using IAM in the AWS Console

- Create a user for jenkins to get access called 'Eb-user' with `AdministratorAccess` permissions policy. 

## Step 3: Connect GitHub to the Jenkins server

- Create a personal access token in GitHub. 

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

- You can use my [deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/deployment.sh) during EC2 creation by copying and pasting it in the userdata field to automate installing Jenkins, the AWS CLI, the AWS EB CLI on the 'jenkins' user, the cy depends and the status check after a deployment.

- If the EC2 is created already you can run one of the commands below to run my [deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/deployment.sh). 

    - If this is the first time deploying, run the command below. 
        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/deployment.sh && sudo chmod +x deployment.sh && sudo ./deployment.sh
        ```

    - If you want to redo the deployment, run the commmand below **but it will delete the 'Deployment-2' directory and the 'aws' directory created from the previous deployment.**

        ```
        cd && sudo rm -r Deployment-2 ; sudo rm -r aws ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/deployment.sh && sudo chmod +x deployment.sh && sudo ./deployment.sh
        ```
- If you just want to install a specific part run the corresponding script below.

    - To install Jenkins. 
        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installjenkins.sh && sudo chmod +x installjenkins.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installjenkins.sh
        ```
    - To install the AWS CLI. 
        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installawscli.sh && sudo chmod +x installawscli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installawscli.sh
        ```
    - To install the AWS EB CLI as the 'jenkins' user. 
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