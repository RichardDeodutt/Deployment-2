#!/bin/bash

#Richard Deodutt
#09/24/2022
#This script is meant to install the AWS EB CLI on ubuntu

#Source or import standard.sh
source libstandard.sh

#Home directory
Home='/home/ubuntu'

#Log file name for the AWS EB CLI installation
LogFileName="InstallAWSEBCLI.log"

#Set the log file location and name
setlogs

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install python3-pip if not already
    aptinstalllog "python3-pip"

    #Change directory to the home folder
    cd $Home

    #As the jenkins user install awsebcli with pip
    su - jenkins -c "pip install awsebcli --upgrade --user > /dev/null 2>&1" && logokay "Successfully installed the AWS EB CLI" || { logerror "Failure installing the AWS EB CLI" && exiterror ; }

    #As the jenkins user create a .bashrc file in the home folder
    su - jenkins -c "cd && touch .bashrc" && logokay "Successfully created .bashrc for jenkins user" || { logerror "Failure creating .bashrc for jenkins user" && exiterror ; }

    #Add to the path of the jenkins user the location where awsebcli is installed
    echo 'PATH=$PATH:$HOME/.local/bin' > '/var/lib/jenkins/.bashrc' && logokay "Successfully added the AWS EB CLI to jenkins user's PATH" || { logerror "Failure adding the AWS EB CLI to jenkins user's PATH" && exiterror ; }
}

#Log start
logokay "Running install AWS EB CLI script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the install AWS EB CLI script successfully"

#Exit successs
exit 0