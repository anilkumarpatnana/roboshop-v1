#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

echo -e "$(timestamp)  [INFO]  ========== ${G}Script Execution started${N} ==========>"| tee -a  $logs_file

dnf module disable nodejs -y &>> $logs_file
validate $? "Disabling nodejs default module " | tee -a  $logs_file

dnf module enable nodejs:24 -y
validate $? "Enabling nodejs:24 module " | tee -a  $logs_file

dnf install nodejs -y
validate $? "Installing nodejs " | tee -a  $logs_file

if grep -q "^roboshop:" /etc/passwd;
then
 echo -e "roboshop user already created ....${Y}SKIPPING${N}"
else
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Creating user roboshop " | tee -a  $logs_file
fi

mkdir -p /app

curl -L -o /tmp/user.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/user-v4.zip &>> $logs_file
validate $? "Downloading application files to /tmp " | tee -a  $logs_file

unzip -o /tmp/user.zip -d /app &>> $logs_file
validate $? "Unzipping files to /app" | tee -a  $logs_file


cd /app
npm install &>> $logs_file
validate $? "Installing  node dependencies " | tee -a  $logs_file


cp user.service /etc/systemd/system/user.service &>> $logs_file
validate $? "Copying service file to /etc/systemd/system/user.service " | tee -a  $logs_file


systemctl daemon-reload &>> $logs_file
validate $? "Reloading daemon systemd " | tee -a  $logs_file

systemctl enable user &>> $logs_file
validate $? "Enabling service user " | tee -a  $logs_file

systemctl start user &>> $logs_file
validate $? "Starting service user " | tee -a  $logs_file



echo "$(timestamp)  [INFO] Time taken  $SECONDS" | tee -a  $logs_file

echo -e "$(timestamp)  [INFO]  ========== ${G}Script Execution Completed${N} ==========>" | tee -a  $logs_file
