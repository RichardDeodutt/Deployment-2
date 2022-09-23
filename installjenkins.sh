#!/bin/bash

#Richard Deodutt
#09/22/2022
#This script is meant to install Jenkins on a ubuntu ec2

#Install jenkins logs
LogFile="InstallJenkins.log"

#Color output, don't change
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
#No color output, don't change
NC='\033[0m'

#Function to exit with a error code
exiterror(){
    #Log error
    log "$(printerror "Something went wrong with installing jenkins. exiting")"
    #Exit with error
    exit 1
}

#function to get a timestamp
timestamp(){
    #Two Different Date and Time Styles
    #echo $(date +"%m/%d/%Y %H:%M:%S %Z")
    echo $(date +"%a %b %d %Y %I:%M:%S %p %Z")
}

#function to log text with a timestamp to a logfile
log(){
    #First arugment is the text to log
    Text=$1
    #Log with a timestamp
    echo "`timestamp` || $Text" | tee -a $LogFile
}

#Print to the console in colored text
colorprint(){
    #Argument 1 is the text to print
    Text=$1
    #Arugment 2 is the color to print
    Color=$2
    printf "${Color}$Text${NC}\n"
}

#Print text in the green color for okay
printokay(){
    #Argument 1 is the text to print
    Text=$1
    #Green color to print
    Color=$Green
    #Echo the colored text
    echo $(colorprint "$Text" $Color)
}

#Print text in the yellow color for warning
printwarning(){
    #Argument 1 is the text to print
    Text=$1
    #Yellow color to print
    Color=$Yellow
    #Echo the colored text
    echo $(colorprint "$Text" $Color)
}

#Print text in the red color for error
printerror(){
    #Argument 1 is the text to print
    Text=$1
    #Red color to print
    Color=$Red
    #Echo the colored text
    echo $(colorprint "$Text" $Color)
}

#Function to log if a apt update succeeded or failed
aptupdatelog(){
    #Update local apt repo database
    apt-get update > /dev/null 2>&1 && log "$(printokay "Successfully updated repo list")" || { log "$(printerror "Failure updating repo list")" && exiterror ; }
}

#Function to log if a apt install succeeded or failed
aptinstalllog(){
    #First arugment is the apt package to log
    Pkg=$1
    #Install using apt-get then log if it fails or not and exit if it fails
    apt-get install $Pkg -y > /dev/null 2>&1 && log "$(printokay "Successfully installed $Pkg")" || { log "$(printerror "Failure installing $Pkg")" && exiterror ; }
}

#The main function
main(){
    #Adding the Keyrings without user interaction
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | gpg --batch --yes --dearmor -o /usr/share/keyrings/jenkins.gpg && log "$(printokay "Successfully installed jenkins keyring")" || { log "$(printerror "Failure installing jenkins keyring")" && exiterror ; }

    #Adding the repo to the sources of apt
    sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' && log "$(printokay "Successfully installed jenkins repo")" || { log "$(printerror "Failure installing jenkins repo")" && exiterror ; }

    #Update local apt repo database
    aptupdatelog

    #Install java
    aptinstalllog "default-jre"

    #Install jenkins
    aptinstalllog "jenkins"

    #Install python3-pip
    aptinstalllog "python3-pip"

    #Install python3.10-venv
    aptinstalllog "python3.10-venv"

    #Start the Jenkins service
    systemctl start jenkins && log "$(printokay "Successfully started systemctl jenkins")" || { log "$(printerror "Failure starting jenkins")" && exiterror ; }
}

#Call the main function
main

#Log successs
log "$(printokay "Successfully ran install jenkins script")"
#Exit successs
exit 0