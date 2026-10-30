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

dnf module disable nodejs -y &>> $logs_file
validate $? "Disabling nodejs default module " | tee -a  $logs_file

dnf module enable nodejs:24 -y &>> $logs_file
validate $? "Enabling nodejs:24 module " | tee -a  $logs_file

dnf install nodejs -y &>> $logs_file
validate $? "Installing nodejs " | tee -a  $logs_file

if grep -q "^roboshop:" /etc/passwd;
then
 echo -e "roboshop user already created ....${Y}SKIPPING${N}"
else
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Creating user roboshop " | tee -a  $logs_file
fi

mkdir -p /app

curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/cart-v4.zip &>> $logs_file
validate $? "Downloading application files to /tmp " | tee -a  $logs_file

unzip -o /tmp/cart.zip -d /app &>> $logs_file
validate $? "Unzipping files to /app" | tee -a  $logs_file


cd /app
npm install &>> $logs_file
validate $? "Installing  node dependencies " | tee -a  $logs_file


cp /home/ec2-user/repo/roboshop-v1/cart.service /etc/systemd/system/cart.service &>> $logs_file
validate $? "Copying service file to /etc/systemd/system/cart.service " | tee -a  $logs_file


systemctl daemon-reload &>> $logs_file
validate $? "Reloading daemon systemd " | tee -a  $logs_file

systemctl enable cart &>> $logs_file
validate $? "Enabling service cart " | tee -a  $logs_file

systemctl start cart &>> $logs_file
validate $? "Starting service cart " | tee -a  $logs_file

echo -e "${Y}==========> VERIFICATION${N}"

systemctl status cart &>> $logs_file
validate $? "cart service is running " | tee -a  $logs_file

health_check=$(curl http://localhost:8080/health) | tee -a  $logs_file
validate $? "http://localhost:8080/health .... is responding " | tee -a  $logs_file



echo "$(timestamp)  [INFO] Time taken  $SECONDS" | tee -a  $logs_file

echo -e "$(timestamp)  [INFO]  ${R}========== ${C}Script Execution Completed${R} ==========>${N}" | tee -a  $logs_file
