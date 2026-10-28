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

echo "$(timestamp)  [INFO]  ========== Script started execution==========>" | tee -a  $logs_file

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $logs_file
validate $? "mongo repo adding" | tee -a  $logs_file

dnf install mongodb-org -y             &>> $logs_file
validate $? "installing mongodb... " | tee -a  $logs_file

systemctl enable mongod                 &>> $logs_file
validate $? "enabling mongodb service..." | tee -a  $logs_file
 
systemctl start mongod                  &>> $logs_file
validate $? "starting mongodb service..." | tee -a  $logs_file

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
validate $? "allowing listening from 0.0.0.0" | tee -a  $logs_file

systemctl restart mongod                 &>> $logs_file
validate $? "restarting mongodb service..." | tee -a  $logs_file

systemctl status mongod                   &>> $logs_file
validate $? "checking status of mongodb service..." | tee -a  $logs_file


echo "$(timestamp)  [INFO] Time taken  $SECONDS" | tee -a  $logs_file

echo "$(timestamp)  [INFO]  ========== Script execution completed ==========>" | tee -a  $logs_file
