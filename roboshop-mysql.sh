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

echo "$(timestamp)  [INFO]  ========== Script started execution==========>"| tee -a  $logs_file

dnf module enable mysql:8.4 -y &>> $logs_file
validate $? "Enabling mysql:8.4 module" | tee -a  $logs_file

dnf install mysql-server -y &>> $logs_file
validate $? "Installing mysql-server" | tee -a  $logs_file

systemctl enable mysqld &>> $logs_file
validate $? "Enabling Mysqld service" | tee -a  $logs_file

systemctl start mysqld &>> $logs_file
validate $? "Starting Mysqld service" | tee -a  $logs_file

mysql_secure_installation --set-root-pass RoboShop@1 &>> $logs_file
validate $? "Setting root password for mysql" | tee -a  $logs_file


echo "$(timestamp)  [INFO] Time taken  $SECONDS" | tee -a  $logs_file

echo "$(timestamp)  [INFO]  ========== Script execution completed ==========>" | tee -a  $logs_file
