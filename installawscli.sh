#!/bin/bash

#Richard Deodutt
#09/23/2022
#This script is meant to install the AWS CLI on ubuntu

#Installing the AWS CLI logs
LogFile="InstallAWSCLI.log"

#Color output, don't change
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
#No color output, don't change
NC='\033[0m'

#Function to exit with a error code
exiterror(){
    #Log error
    log "$(printerror "Something went wrong with installing the AWS CLI. exiting")"
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
    #Install using apt-get if not already then log if it fails or not and exit if it fails
    apt-get install $Pkg -y > /dev/null 2>&1 && log "$(printokay "Successfully installed $Pkg")" || { log "$(printerror "Failure installing $Pkg")" && exiterror ; }
}

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install curl if not already
    aptinstalllog "curl"

    #Install unzip if not already
    aptinstalllog "unzip"

    #Curl the package of the AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && log "$(printokay "Successfully curled the AWS CLI")" || { log "$(printerror "Failure curling the AWS CLI")" && exiterror ; }

    #Unzip the AWS CLI package
    unzip awscliv2.zip && log "$(printokay "Successfully unzipped the AWS CLI")" || { log "$(printerror "Failure unzipping the AWS CLI")" && exiterror ; }

    #Install the AWS CLI if not already
    ./aws/install && log "$(printokay "Successfully Installed the AWS CLI")" || { log "$(printerror "Failure Installing the AWS CLI")" && exiterror ; }
}

#Log start
log "$(printokay "Running install AWS CLI script")"

#Call the main function
main

#Log successs
log "$(printokay "Successfully ran install AWS CLI script")"
#Exit successs
exit 0