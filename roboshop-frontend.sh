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
 
dnf module disable nginx -y &>> $logs_file
validate $? "Disabling default nginx module " | tee -a  $logs_file

dnf module enable nginx:1.26 -y &>> $logs_file
validate $? "Enabling nginx:1.26 module  " | tee -a  $logs_file

dnf install nginx -y &>> $logs_file
validate $? "Installing nginx " | tee -a  $logs_file

systemctl enable nginx &>> $logs_file
validate $? "Enabling nginx service " | tee -a  $logs_file

systemctl start nginx &>> $logs_file
validate $? "Starting nginx service " | tee -a  $logs_file

rm -rf /usr/share/nginx/html/* &>> $logs_file
validate $? "Removing default files from nginx home path " | tee -a  $logs_file

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $logs_file
validate $? "Downloading frontend files to /tmp " | tee -a  $logs_file

unzip -o /tmp/frontend.zip -d /usr/share/nginx/html
validate $? "Unzipping files from /tmp to /usr/share/nginx/html " | tee -a  $logs_file

cp /home/ec2-user/repo/roboshop-v1/roboshop.conf  /etc/nginx/default.d/roboshop.conf &>> $logs_file
validate $? "copying roboshop.conf file to /etc/nginx/default.d/roboshop.conf " | tee -a  $logs_file

nginx -t &>> $logs_file
validate $? "Checking roboshop.conf configuration syntax " | tee -a  $logs_file


systemctl restart nginx &>> $logs_file
validate $? "Restarting nginx ...  " | tee -a  $logs_file

echo "$(timestamp)  [INFO] Time taken  $SECONDS" | tee -a  $logs_file

echo -e "$(timestamp)  [INFO]  ${R}========== ${C}Script Execution Completed${R} ==========>${N}" | tee -a  $logs_file

