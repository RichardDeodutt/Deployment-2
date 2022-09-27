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

    #Install awsebcli with pip to the current user only
    pip install awsebcli --upgrade --user > /dev/null 2>&1 && logokay "Successfully installed the AWS EB CLI" || { logerror "Failure installing the AWS EB CLI" && exiterror ; }

    #As the current user create a .bashrc file in the home folder if it does not exist
    cd && touch .bashrc && logokay "Successfully created .bashrc for the current user if it does not exist" || { logerror "Failure creating .bashrc for the current user" && exiterror ; }

    #Add to the path the .local/bin location where awsebcli is installed
    echo 'PATH=$PATH:$HOME/.local/bin' > $HOME/.bashrc && logokay "Successfully added the AWS EB CLI to the user's PATH" || { logerror "Failure adding the AWS EB CLI to the current user's PATH" && exiterror ; }
}

#Log start
logokay "Running the install AWS EB CLI script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the install AWS EB CLI script successfully"

#Exit successs
exit 0