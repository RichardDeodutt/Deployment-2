#!/bin/bash

#Richard Deodutt
#09/22/2022
#This script is meant to deploy Jenkins on a ubuntu ec2

#Home directory
Home='/home/ubuntu'

#Log file name
LogFileName="Deployment.log"

#Log file location and name
LogFile=$Home/$LogFileName

#The Url of the repository to clone
RepositoryURL='https://github.com/RichardDeodutt/Deployment-2.git'

#The folder of the repository
RepositoryFolder='Deployment-2'

#Set the LogFile variable
setlogs(){
    #Combine Home and Logfilename
    LogFile=$Home/$LogFileName
}

#Color output, don't change
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
#No color output, don't change
NC='\033[0m'

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

#Log with print okay
logokay(){
    #Argument 1 is the text to print
    Text=$1
    #Log with okay or green text color
    log "$(printokay "$Text")"
}

#Log with print warning
logwarning(){
    #Argument 1 is the text to print
    Text=$1
    #Log with warning or yellow text color
    log "$(printwarning "$Text")"
}

#Log with print error
logerror(){
    #Argument 1 is the text to print
    Text=$1
    #Log with error or red text color
    log "$(printerror "$Text")"
}

#Function to exit with a error code
exiterror(){
    #Log error
    logerror "Something went wrong with the deployment. exiting"
    #Exit with error
    exit 1
}

#Run as admin only check
admincheck(){
    #Check if the user has root, sudo or admin permissions
    if [ $UID != 0 ]; then
        #Send out a warning message
        logwarning "Run again with admin permissions"
        #Exit with a error message
        exiterror
    fi
}

#Run a command and exit if it has a error
cmdrunexiterror(){
    #Argument 1 is the command to run
    Command=$1
    #Argument 2 is the success message
    Okay=$2
    #Argument 3 is the failure message
    Fail=$3
    "$Command" /dev/null 2>&1 && logokay "$Okay" || { logerror "$Fail" && exiterror ; }
}

#Function to log if a apt update succeeded or failed
aptupdatelog(){
    #Update local apt repo database
    apt-get update > /dev/null 2>&1 && logokay "Successfully updated repo list" || { logerror "Failure updating repo list" && exiterror ; }
}

#Function to log if a apt install succeeded or failed
aptinstalllog(){
    #First arugment is the apt package to log
    Pkg=$1
    #Install using apt-get if not already then log if it fails or not and exit if it fails
    apt-get install $Pkg -y > /dev/null 2>&1 && logokay "Successfully installed $Pkg" || { logerror "Failure installing $Pkg" && exiterror ; }
}

#Install jenkins
installjenkins(){
    #Change directory to the Scripts folder
    cd $Home/$RepositoryFolder/Scripts/
    #Run the install jenkins script
    ./installjenkins.sh && logokay "Successfully installed jenkins through a script" || { logerror "Failure installing jenkins through a script" && exiterror ; }
    #Change directory to the home folder
    cd $Home
}

#Install the AWS CLI
installawscli(){
    #Change directory to the Scripts folder
    cd $Home/$RepositoryFolder/Scripts/
    #Run the install AWS CLI script
    $Home/$RepositoryFolder/Scripts/installawscli.sh && logokay "Successfully installed the AWS CLI through a script" || { logerror "Failure installing the AWS CLI through a script" && exiterror ; }
    #Change directory to the home folder
    cd $Home
}

#Log the status of the deployment
status(){
    #Install Screenfetch if not already
    aptinstalllog "screenfetch"
    #Log Jenkins Status
    log "$(echo "Jenkins Status" ; systemctl status jenkins --no-pager)"
    #Log Jenkins Secret Password
    log "$(echo "Secret Password")"
    logokay "$(cat /var/lib/jenkins/secrets/initialAdminPassword)"
    #Log the AWS CLI version
    log "$(echo "The AWS CLI Version")"
    logokay "$(/usr/local/bin/aws --version)"
    #Log Screenfetch
    log "$(echo "Screenfetch" ; screenfetch)"
}

#The main function
main(){
    #Update local apt repo database
    aptupdatelog
    #Install git if not already
    aptinstalllog "git"
    #Clone the repository
    git clone $RepositoryURL > /dev/null 2>&1 && logokay "Successfully cloned $Pkg" || { logerror "Failure cloning $Pkg" && exiterror ; }
    #Install jenkins if not already
    installjenkins
    #Install the AWS CLI if not already
    installawscli
    #Delay for 10 seconds for jenkins to load
    sleep 10
    #Init Status
    status
}

#Log start
logokay "Running deployment script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Successfully ran the deployment script"

#Exit successs
exit 0