#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
C="\e[1;36m"

mkdir -p $logs_folder

echo "Script started execution at $(date +"%F %T")" &>> $logs_file

if [ $user_id -ne  0 ];
 then
 echo "Please  executing file with sudo access"
 exit 1
fi

validate(){
    if [ $1 -eq 0 ];
    then
    echo -e "$2 .....${G}Success${N}"| tee -a  $logs_file
    else
    echo -e "$2 .....${R}failed${N}" | tee -a  $logs_file
    fi
}

timestamp(){
    date "+%F %T"
}

echo -e "$(timestamp)  [INFO]  ${R}========== ${C}Script Execution Started${R} ==========>${N}" | tee -a  $logs_file
 

dnf module enable maven:3.9 -y &>> $logs_file
validate $? "user service is running " | tee -a  $logs_file

dnf install maven java-25-openjdk-devel -y &>> $logs_file

alternatives --set java 

