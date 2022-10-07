# Deployment-2

Set up a CI/CD pipeline from start to finish. 

Using Elastic Beanstalk and customizing the pipeline. 

Deploying a [url-shortener](https://github.com/RichardDeodutt/kuralabs_deployment_2) Flask app. 

# Notes before starting

- These instructions use AWS. 

- These instructions are for the AWS Ubuntu image. They assume you are running the commands as the 'ubuntu' user. 

- These instructions assume you are using a jenkins server and a jenkins agent to do all the work. 

- There are some shortcuts in the shortcut section to save time. It may be a good idea to check it first. 

# Instructions

## Step 1: Prepare the Jenkins server EC2 if you don't have one

<details>

<summary>Step by Step</summary>

- Create/Launch an EC2 using the AWS Console in your region of choice, `Asia Pacific (Tokyo) or ap-northeast-1` in my case. 

- Set the `Name and tags` to anything you want, `Application and OS Images (Amazon Machine Image)` to Ubuntu 64-bit (x86), `Instance type` to t2.micro. 

- Set the `Key pair(login)` to any keypair you have access to or create one, `Network Settings` set the security group to one with ports 80, 8080 and 22 open or create one with those ports open. Launch with `default settings` for the rest is fine. 

- `SSH or connect` to the ec2 when it is running. 

    Example below: 

    ```
    ssh -i ~/.ssh/keyfile.pem root@13.114.28.228
    ```

- `Download` the `jenkins keyring` for the package repository source list. 

    Example below: 

    ```
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/jenkins.gpg
    ```

- `Install` the `jenkins keyring` to the package repository source list. 

    Example below: 

    ```
    sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    ```

- `Update` the package repository source list. 

    Example below: 

    ```
    sudo apt update
    ```

- `Install` the `apt` packages `default-jre`. 

    Example below: 

    ```
    sudo apt install -y default-jre
    ```

- `Install` the `apt` packages `jenkins`. 

    Example below: 

    ```
    sudo apt install -y jenkins
    ```

 - `Get` the secret password and save it for future use. 

    Example below: 

    ```
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

</details>

<details>

<summary>One liner</summary>

 - `One liner` to do do everything above at once. 

    Example below: 

    ```
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/jenkins.gpg && sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' && sudo apt update && sudo apt install -y default-jre && sudo apt install -y jenkins && sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

</details>

## Step 2: Create a Jenkins user in your AWS account using IAM in the AWS Console

<details>

<summary>Step by Step</summary>

- Create a user in [AWS IAM](https://us-east-1.console.aws.amazon.com/iamv2/home) for jenkins to get access with username `Eb-user` and AWS credential type of `Access key - Programmatic access`. 

- Then select `Attach existing policies directly` and select `AdministratorAccess` permissions policy then click next tags and then next review to skip the tags and review the changes to be made. 

- Review the changes to be made and click create user when ready and save the information provided after creation such as the `Access key ID` and `Secret access key` or download the csv with the information for future use. 

</details>

## Step 3: Connect GitHub to the Jenkins server

<details>

<summary>Step by Step</summary>

- Create/Generate a [personal access token in GitHub](https://github.com/settings/tokens) for the Jenkins server and webhook. I added all the `repo`, `admin:repo_hook` and `notifications` permissions. When done save the token for future use. 

- Fork the [deployment repository](https://github.com/kura-labs-org/kuralabs_deployment_2) and using this forked repository connect it to the Jenkins server webhook in the settings of the newly forked repository. 

- Connect the webhook by configuring the setting as the following. 

    <details>

    <summary>Settings</summary>

    - The `Payload URL` to your Jenkins server webhook. 

        Example `Payload URL`
        ```
        http://35.77.201.119:8080/github-webhook/
        ```
    
    - The `Content type` to application/json. 
    
    - The `Which events would you like to trigger this webhook?` to 'Send me everything.'. 
    
    - The `Active` checkbox to checked. 

    </details>
    
- Then when everything is set click `Add webhook` to connect the forked repository to the Jenkins server webhook. 

</details>

## Step 4: Configure the Jenkins server

<details>

<summary>Step by Step</summary>

- Navigate to the Jenkins page using the url in a browser. 

    Example URL
    ```
    http://35.77.201.119:8080/
    ```

- Enter the `secret password or initial admin password` you saved earlier or get it again and enter it then click Continue. 

    Example below: 

    ```
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

- For the `Customize Jenkins page` just click Install suggested plugins and wait for it to install the plugins `which may take some time`. 

- Once that is done you will have a `Create First Admin User` page so fill out that page and save the information for future logins then click Save and Continue. 

- After that is a `Instance Configuration` page where the default `Jenkins URL` should be correct already is similar to `http://35.77.201.119:8080/` so click Save and Finish. 

- The next page is the `Jenkins is ready!` page where you just click Start using Jenkins to finish configuring the Jenkins server and go to the home page. 

</details>

## Step 5: Configure Clouds of the Jenkins server

<details>

<summary>Step by Step</summary>

- In the Jenkins server homepage click `Manage Jenkins` to go to the settings of the Jenkins server then when it loads the page click `Manage Plugins` on the next page when it loads click `Available` and search for `Amazon EC2` and select the checkbox of the one with the exact name of `Amazon EC2` and then click `Install without restart` to install it. Wait for it to install as it may take some time and only go to the next step when it is done. 

- Go to the Jenkins server homepage and click `Manage Jenkins` to go to the settings of the Jenkins server then when it loads the page click `Manage Nodes and Clouds` on the next page when it loads click `Configure Clouds`. When the new `Configure Clouds` page loads it should now have a new option to `Add a new cloud` so click that and select `Amazon EC2`. 

- When the `Amazon EC2` configuration options load enter the following. 

    <details>

    <summary>Settings</summary>

    - Under `Name` enter a name for the Agent in my case I used Jenkins-Agent. 

    - Under `Amazon EC2 Credentials` where it says `- none -` under it is `+ Add` click it to open the dropdown menu and select the `Jenkins` option. When the popup loads under `Kind` select AWS Credentials then when it loads under `Access Key ID` enter your exact AWS Access Key ID for the `Eb-user` you created and saved earlier. Then under `Secret Access Key` enter your exact AWS Secret Access Key for the `Eb-user` you created and saved earlier then click `Add` to add your `Amazon EC2 Credentials` to this Jenkins server. 
    
    - Under `Amazon EC2 Credentials` where it says `- none -` click it to open the dropdown menu and select the `Amazon EC2 Credentials` you just added. 

    - Under `Region` select your region of choice in my case I selected ap-northeast-1. 

    - Under `EC2 Key Pair's Private Key` where it says `- none -` under it is `+ Add` click it to open the dropdown menu and select the `Jenkins` option. When the popup loads under `Kind` select SSH Username with private key then when it loads under `Username` enter ubuntu then under `Private Key` select `Enter directly` and then click `Add`. In the textarea that appears copy and paste the contents of your `AWS SSH pem keyfile` to get it you can just `cat` the file and copy it from the terminal. Once the key is entered click Add to save it. If you don't have a keyfile you can create one in the AWS Console and download it then do this step. 

        Example below: 

        ```
        cat ~/.ssh/keyfile.pem
        ```

    - Under `EC2 Key Pair's Private Key` where it says `- none -` click it to open the dropdown menu and select the `EC2 Key Pair's Private Key` you just added then under `AMIs` click `Add` and wait for it to load. 

    - Under `Description` enter the following. 

        Example below: 

        ```
        Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-09-12
        ```
    
    - Under `AMI ID` enter the following. 

        Example below: 

        ```
        ami-03f4fa076d2981b45
        ```
    
    - Under `Instance Type` select T2Micro then under `Security group names` enter the same name as the security group the Jenkins server is using as the agents need atleast port 22 open. Under `Remote user` enter ubuntu and then under `AMI Type` select unix from the dropdown menu. Once it loads under `Remote ssh port` enter 22 and under `Boot Delay` enter 0. 

    - Under `Labels` enter the following. 

        Example below: 

        ```
        linux ubuntu ec2
        ```

    - Under `Idle termination time` enter 5. and under `Init script` enter the following. 

    <details>

    <summary>Init Script</summary>
    
    - Replace the `aws configure set` commands with your `Amazon EC2 Credential` for `Eb-user` specifically `access_key_id_goes_here` and `access_secret_key_goes_here` and region with your region of choice in my case I selected ap-northeast-1. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/agentdeployment.sh && sudo chmod +x agentdeployment.sh && sudo ./agentdeployment.sh

        #Update the path
        source $HOME/.bashrc

        #Just making sure it's installed
        sudo apt install default-jre

        aws configure set aws_access_key_id 'access_key_id_goes_here' && aws configure set aws_secret_access_key 'access_secret_key_goes_here' && aws configure set region 'ap-northeast-1' && aws configure set output 'json'

        #Exit successs
        exit 0
        ```

    </details>

    - Under `Number of Executors` enter 1 and under `Java Path` enter java then under `Minimum number of instances` enter 0 after that under `Instance Cap` enter 1. Check the box of `Delete root device on instance termination`, `Associate Public IP` and `Connect by SSH Process`. Under `Connection Strategy` select Public IP from the dropdown menu. `Under Host Key Verification Strategy` select accept-new from the dropdown menu.

- Once the `Amazon EC2` cloud is configured click `Apply` and `Save`. 

</details>

## Step 6: Update the forked repository

<details>

<summary>Step by Step</summary>

- `Clone or download` [this repository](https://github.com/RichardDeodutt/Deployment-2) to get the files locally on your computer. 

    Example below: 

    ```
    git clone git@github.com:RichardDeodutt/Deployment-2.git
    ```

- `Clone your forked repository` in my case that would be https://github.com/RichardDeodutt/kuralabs_deployment_2 if you have not already done so to have it locally on your computer. 

    Example below: 

    ```
    git clone git@github.com:RichardDeodutt/kuralabs_deployment_2.git
    ```

- `Everything` in the folder [Modified-Application-Files](https://github.com/RichardDeodutt/Deployment-2/tree/main/Modified-Application-Files) should be `copied over` to the `root` of your forked repository. In my case that would be https://github.com/RichardDeodutt/kuralabs_deployment_2 and it should replace and overwrite the existing files there. 

    Example below: 

    ```
    cp -a Deployment-2/Modified-Application-Files/* kuralabs_deployment_2/
    ```

- You may want to edit the [Jenkinsfile](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/Jenkinsfile) on your forked repository to have the `Deploy` stage use the region of your choice in my case I selected ap-northeast-1.

- Once these changes are made and the newly forked repository is `patched` `commit` and `push` these changes to make sure they are on your `online GitHub repository` as in the website. 

    Example below: 

    ```
    git add .
    ```

    ```
    git commit -m "Update"
    ```

    ```
    git push
    ```

</details>

## Step 7: Create a Multibranch Pipeline for the forked repository

<details>

<summary>Step by Step</summary>

- In the Jenkins server homepage click `New Item` to create a new pipeline then when it loads the page enter a `item name` in my case I named it `Deployment-2` and then select `Multibranch Pipeline` clicking `OK` once done. 

- On the Configuration page for the new pipeline enter the following settings. 

    <details>

    <summary>Settings</summary>

    - On `Branch Sources` click `Add source` and select `GitHub`. On the new `GitHub section` under `Credentials` click `+ Add` and select `Jenkins`. When the popup loads under `Username` enter your exact GitHub username then under `Password` enter your exact [personal access token in GitHub](https://github.com/settings/tokens) you created and saved earlier then click `Add` to add your GitHub credentials to this Jenkins server. 
    
    - Under `Credentials` where it says `- none -` click it to open the dropdown menu and select the GitHub credentials you just added. 
    
    - Where it says `Repository HTTPS URL` under it enter your forked repository URL in my case it would be https://github.com/RichardDeodutt/kuralabs_deployment_2 then click `Validate`. It should say it's ok. 

        Example below: 

        ```
        Credentials ok. Connected to https://github.com/RichardDeodutt/kuralabs_deployment_2.
        ```
    
    - This `may not be needed` but if you created `more branches` in your fork but want to work with one you can scroll down until you see `Property strategy`. Above that should be a `Add` button, click that and select `Filter by name (with wildcards)`. Under Include enter `main` and use wildcards or * to select and exclude unwated branches in my case I had a `original` branch so under `Exclude` I entered `o*` to exclude it. 

    </details>

- Once the pipeline is configured click `Apply` and `Save`. 

</details>

## Step 8: Build Test and Deploy the application to Elastic Beanstalk

<details>

<summary>Step by Step</summary>

<br>

- In the Jenkins server homepage click on the pipeline created and `build it` if it isn't building and or queued. This should `build`, `test` and `deploy` the application using `elastic beanstalk` so remember to take it down when done to `avoid extra cost`. 

</details>

## Task 1: Modify or add to the pipeline

- Add another test. 

    <details>

    <summary>Another Test</summary>

    - Stage below: 

        ```
        stage ('Pytest') {
            steps {
            sh '''#!/bin/bash
                source testenv/bin/activate
                py.test --verbose --junit-xml test-reports/pytest-results.xml
                '''
            }
            post{
            always {
                junit 'test-reports/pytest-results.xml'
            }
            }
        }
        ```

    - Added Test [Pytest](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/test_pages.py). 

    </details>

- Add a way to notify you. 

    <details>

    <summary>Notifications</summary>

    - Download and Install [catlight](https://catlight.io/downloads). 

    - Add a `Connection` to Jenkins and enter the `Jenkins server url` then enter your credentials, the `username` and `password` you created and connect. 

    - Once connected select the projects you want `to get notifications from` and Save. 

    - It will send a desktop notification when a build `fails or passes`. 

    <details>

    <summary>Dashboard</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Dashboard.png"><img src="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Dashboard.png" />
    </p>

    </details>

    <details>

    <summary>Notifications</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Notifications.png"><img src="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Notifications.png" />
    </p>

    </details>

    <details>

    <summary>Broken</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Broken.png"><img src="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Broken.png" />
    </p>

    </details>

    </details>

- Use Cypress for testing. 

    <details>

    <summary>E2E Test with Cypress</summary>

    - Stages below: 

        ```
        stage ('Build Tools') {
            steps {
            sh '''#!/bin/bash
            source testenv/bin/activate
            node --max-old-space-size=100 /usr/bin/npm install --save-dev cypress@7.6.0
            /usr/bin/npx cypress verify
            '''
            }
        }
        ```

        ```
        stage ('Deploy') {
            steps {
            sh '''#!/bin/bash
                InitCMD='$HOME/.local/bin/eb init --region ap-northeast-1 --platform python-3.8 url-shortener'
                CreateCMD='$HOME/.local/bin/eb create url-shortener-dev -c url-shortener-dev -p python-3.8'
                DeployCMD='$HOME/.local/bin/eb deploy url-shortener-dev'
                $InitCMD && $CreateCMD || $DeployCMD
                '''
            }
        }
        ```

        ```
        stage ('Cypress E2E') {
            steps {
            sh '''#!/bin/bash
                source testenv/bin/activate
                NO_COLOR=1 /usr/bin/npx cypress run --spec cypress/integration/test.spec.js
                '''
            }
            post{
            always {
                junit 'test-reports/cypress-results.xml'
            }
            }
        }
        ```

    - Added Test [Cypress](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/cypress/integration/test.spec.js). 

    - Added Config [Cypress](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/cypress.json). 

    - Modified Fixed [Jenkinsfile](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/Jenkinsfile). 

    </details>

- Add a linter. 

    <details>

    <summary>Linter</summary>

    - Stage below: 

        ```
        stage ('Pylint') {
            steps {
            sh '''#!/bin/bash
                source testenv/bin/activate
                pylint --output-format=text,pylint_junit.JUnitReporter:test-reports/pylint-results.xml application.py
                '''
            }
            post{
            always {
                junit 'test-reports/pylint-results.xml'
            }
            }
        }
        ```

    - Modified Pip [Requirements](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/requirements.txt). 

    - Modified Fixed [Application](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/application.py). 

    </details>

- Change something on the application front. 

    <details>

    <summary>Changes</summary>

    - Modified Template [Base](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/templates/base.html). 

    - Modified Template [Home](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/templates/home.html). 

    - Modified Style [CSS](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/static/style.css). 

    <details>

    <summary>Makeover</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Makeover.png"><img src="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Makeover.png" />
    </p>

    </details>

    </details>

- Once done appy the changes and build the pipeline again. 

    <details>

    <summary>Build</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Build.png"><img src="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Build.png" />
    </p>

    </details>

## Task 2: Diagram the new pipeline

- Create a diagram for the new pipeline. 

    <details>

    <summary>Pipeline</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Pipeline.png"><img src="https://github.com/RichardDeodutt/Deployment-2/blob/main/Images/Pipeline.png" />
    </p>

    </details>

## Task 3: Create documentation

- Create documentation of everything. 

    <details>

    <summary>Documentation</summary>

    <br>

    - [Documentation](https://github.com/RichardDeodutt/Deployment-2/blob/main/README.md). 

    </details>

# Shortcuts

## Starting from scratch

### Deploy everything all in one (No Jenkins agents)

<details>

<summary>All In One</summary>

- You can use my [all in one deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/Deployment-Scripts/allinonedeployment.sh) during EC2 creation by copying and pasting it in the userdata field to automate installing Jenkins, the Jenkins agent, the AWS CLI, the AWS EB CLI on the 'jenkins' user, the cypress dependencies and the status check after a deployment. 

- If the EC2 is created already you can run one of the commands below to run my [all in one deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/Deployment-Scripts/allinonedeployment.sh). 

    - If this is the first time deploying, run the command below. 
        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/allinonedeployment.sh && sudo chmod +x allinonedeployment.sh && sudo ./allinonedeployment.sh
        ```

    - If you want to redo the deployment, run the commmand below **but it will delete the 'Deployment-2' directory and the 'aws' directory if it was created from a previous deployment.** 

        ```
        cd && sudo rm -r Deployment-2 ; sudo rm -r aws ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/allinonedeployment.sh && sudo chmod +x allinonedeployment.sh && sudo ./allinonedeployment.sh
        ```

</details>

### Deploy everything in parts (With Jenkins agents)

<details>

<summary>Jenkins Server</summary>

- Jenkins Server Part

    - You can use my [jenkins deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/Deployment-Scripts/jenkinsdeployment.sh) during EC2 creation by copying and pasting it in the userdata field to automate installing Jenkins and the status check after a deployment. This will be the Jenkins server that controls the agents. 

    - If the EC2 is created already you can run the commands below to run my [jenkins deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/Deployment-Scripts/jenkinsdeployment.sh). 

        - If this is the first time deploying, run the command below. 
            ```
            cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/jenkinsdeployment.sh && sudo chmod +x jenkinsdeployment.sh && sudo ./jenkinsdeployment.sh
            ```

        - If you want to redo the deployment, run the commmand below **but it will delete the 'Deployment-2' directory and the 'aws' directory if it was created from a previous deployment.** 

            ```
            cd && sudo rm -r Deployment-2 ; sudo rm -r aws ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/jenkinsdeployment.sh && sudo chmod +x jenkinsdeployment.sh && sudo ./jenkinsdeployment.sh
            ```

</details>

<details>

<summary>Jenkins Agent</summary>

- Jenkins Agent Part

    - The Jenkins server should automatically create this agent and you only need to configure it correctly in the Jenkins server web interface to run the correct init script below. Replace the aws configurations with your `Eb-user` credentials and region. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/agentdeployment.sh && sudo chmod +x agentdeployment.sh && sudo ./agentdeployment.sh

        #Update the path
        source $HOME/.bashrc

        #Just making sure it's installed
        sudo apt install default-jre

        aws configure set aws_access_key_id 'access_key_id_goes_here' && aws configure set aws_secret_access_key 'access_secret_key_goes_here' && aws configure set region 'ap-northeast-1' && aws configure set output 'json'

        #Exit successs
        exit 0
        ```

    - If the EC2 is created already you can run the commands below to run my [agent deployment script](https://github.com/RichardDeodutt/Deployment-2/blob/main/Deployment-Scripts/agentdeployment.sh). 

        - If this is the first time deploying, run the command below. 
            ```
            cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/agentdeployment.sh && sudo chmod +x agentdeployment.sh && sudo ./agentdeployment.sh
            ```

        - If you want to redo the deployment, run the commmand below **but it will delete the 'Deployment-2' directory and the 'aws' directory if it was created from a previous deployment.** 

            ```
            cd && sudo rm -r Deployment-2 ; sudo rm -r aws ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Deployment-Scripts/agentdeployment.sh && sudo chmod +x agentdeployment.sh && sudo ./agentdeployment.sh
            ```

</details>

## Install parts separately

<details>

<summary>Parts</summary>

- If you just want to install a specific part run the corresponding script below.

    <details>

    <summary>Install Jenkins</summary>

    - To install Jenkins. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installjenkins.sh && sudo chmod +x installjenkins.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installjenkins.sh
        ```

    </details>

    <details>

    <summary>Install Jenkins Agent</summary>

    - To install the Jenkins agent. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installagent.sh && sudo chmod +x installagent.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installagent.sh
        ```

    </details>

    <details>

    <summary>Install The AWS CLI</summary>

    - To install the AWS CLI. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installawscli.sh && sudo chmod +x installawscli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installawscli.sh
        ```

    </details>

    <details>

    <summary>Install The AWS EB CLI('jenkins' User)</summary>

    - To install the AWS EB CLI as the 'jenkins' user. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installjenkinsawsebcli.sh && sudo chmod +x installjenkinsawsebcli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installjenkinsawsebcli.sh
        ```

    </details>

    <details>

    <summary>Install The AWS EB CLI('ubuntu' User)</summary>

    - To install the AWS EB CLI as the 'ubuntu' user. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installawsebcli.sh && sudo chmod +x installawsebcli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installawsebcli.sh
        ```

    </details>

    <details>

    <summary>Install Cypress Dependencies</summary>

    - To install Cypress dependencies.

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/installcydepends.sh && sudo chmod +x installcydepends.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installcydepends.sh
        ```

    </details>

    <details>

    <summary>Check Deployment Status</summary>

    - To check the status after a deployment.

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/statuscheck.sh && sudo chmod +x statuscheck.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-2/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./statuscheck.sh
        ```

    </details>

</details>

# Why?

- I'm using a Jenkins agent so I can stick to only using T2Micro EC2s. One for the Jenkins server and one for the Jenkins agent doing the building, testing and deployment. 

- I'm Using the Agent `Init script` instead of using the `Userdata` to set up the agent because the `Userdata` method might not be ready when the Jenkins server connects using SSH and it causes issues so this way works more `efficently` for `frequent` `Launching` and `Terminating` of Instances. 

# Issues

- Running the `Jenkins server` and the `all the tests` on a `T2Micro EC2` will fail and `possibly crash` the EC2 during the `Cypress test` because there is `not enough resources`(CPU and MEM) to do everything at once. 

- Any code not up to `Pylint's standard` in [application.py](https://github.com/RichardDeodutt/Deployment-2/blob/main/Modified-Application-Files/application.py) will throw a `"error"` and fail the test breaking the `rest of the chain` even if the error in question is `just a style thing` and `not a real error`. 