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

    #As the jenkins user install awsebcli with pip
    su - jenkins -c "pip install awsebcli --upgrade --user" && logokay "Successfully installed the AWS EB CLI" || { logerror "Failure installing the AWS EB CLI" && exiterror ; }

    #Contents of the new .bashrc file
    bashrcfile='$PATH=$PATH:$HOME/.local/bin'

    #As the jenkins user create a .bashrc file in the home folder and add to the path the location where awsebcli is installed
    su - jenkins -c "cd && echo $bashrcfile > .bashrc" && logokay "Successfully added the AWS EB CLI to PATH" || { logerror "Failure adding the AWS EB CLI to PATH" && exiterror ; }
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