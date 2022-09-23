#!/bin/bash

#Richard Deodutt
#09/22/2022
#This script is meant to install Jenkins on ubuntu

#Source or import standard.sh
source standard.sh

#Log file name for jenkins installation
LogFileName="InstallJenkins.log"

#Set the log file location and name
setlogs

#The main function
main(){
    #Adding the Keyrings if not already
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | gpg --batch --yes --dearmor -o /usr/share/keyrings/jenkins.gpg && logokay "Successfully installed jenkins keyring" || { logerror "Failure installing jenkins keyring" && exiterror ; }

    #Adding the repo to the sources of apt if not already
    sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' && logokay "Successfully installed jenkins repo" || { logerror "Failure installing jenkins repo" && exiterror ; }

    #Update local apt repo database
    aptupdatelog

    #Install java if not already
    aptinstalllog "default-jre"

    #Install jenkins if not already
    aptinstalllog "jenkins"

    #Install python3-pip if not already
    aptinstalllog "python3-pip"

    #Install python3.10-venv if not already
    aptinstalllog "python3.10-venv"

    #Start the Jenkins service if not already
    systemctl start jenkins && logokay "Successfully started systemctl jenkins" || { logerror "Failure starting jenkins" && exiterror ; }
}

#Log start
logokay "Running install jenkins script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the install jenkins script successfully"

#Exit successs
exit 0