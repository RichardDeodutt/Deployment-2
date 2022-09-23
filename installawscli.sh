#!/bin/bash

#Richard Deodutt
#09/23/2022
#This script is meant to install the AWS CLI on ubuntu

#Source or import standard.sh
source standard.sh

#Log file name for the AWS CLI installation
LogFileName="InstallAWSCLI.log"

#Set the log file location and name
setlogs

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install curl if not already
    aptinstalllog "curl"

    #Install unzip if not already
    aptinstalllog "unzip"

    #Curl the package of the AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && logokay "Successfully curled the AWS CLI" || { logerror "Failure curling the AWS CLI" && exiterror ; }

    #Unzip the AWS CLI package
    unzip awscliv2.zip -q && logokay "Successfully unzipped the AWS CLI" || { logerror "Failure unzipping the AWS CLI" && exiterror ; }

    #Install the AWS CLI if not already
    ./aws/install && log "$(printokay "Successfully Installed the AWS CLI")" || { log "$(printerror "Failure Installing the AWS CLI")" && exiterror ; }
}

#Log start
logokay "Running install AWS CLI script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran install AWS CLI script successfully"

#Exit successs
exit 0