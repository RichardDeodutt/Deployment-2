#!/bin/bash

#Richard Deodutt
#09/22/2022
#This script is meant to deploy Jenkins on a ubuntu ec2

#Home directory
Root='/home/ubuntu/'

#Deployment logs
LogFile="$Root""Deployment.log"

RepositoryURL='https://github.com/RichardDeodutt/Deployment-2.git'

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
    echo "`timestamp` || $Text" | tee $LogFile
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

#Install jenkins
installjenkins(){
    #Change into the deployment directory
    cd $Root"/Deployment-2"
    #Run the install jenkins script
    installjenkins.sh && log "$(printokay "Successfully installed jenkins")" || { log "$(printerror "Failure installing jenkins")" && exiterror ; }
    #Go back
    cd ..
}

#Log the status of the deployment
status(){
    #Install Screenfetch
    aptinstalllog "screenfetch"
    #Log Jenkins Status
    log "$(echo "Jenkins Status"; systemctl status jenkins --no-pager)"
    #Log Jenkins Secret Password
    log "$(printokay "$(cat /var/lib/jenkins/secrets/initialAdminPassword)")"
    #Log Screenfetch
    log "$(echo "Screenfetch"; screenfetch)"
}

#The main function
main(){
    #Update local apt repo database
    aptupdatelog
    #Install git
    aptinstalllog "git"
    #Clone the repository
    git clone $RepositoryURL && log "$(printokay "Successfully cloned $Pkg")" || { log "$(printerror "Failure cloning $Pkg")" && exiterror ; }
    #Install jenkins
    installjenkins
    #Delay for 10 seconds for jenkins to load
    sleep 10
    #Init Status
    status
}

#Call the main function
main

#Log successs
log "$(printokay "Successfully installed jenkins")"
#Exit successs
exit 0