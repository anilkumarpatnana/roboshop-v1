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
validate $? "Disabling default nodejs" | tee -a  $logs_file

dnf module enable nodejs:24 -y &>> $logs_file
validate $? "Enabling nodejs:24 " | tee -a  $logs_file

dnf install nodejs -y &>> $logs_file
validate $? "Installing nodejs " | tee -a  $logs_file

node -v | tee -a  $logs_file
validate $? "Checking nodejs version is " | tee -a  $logs_file

grep -q "^roboshop:" /etc/passwd

if [ $? -eq 0 ];
then
    echo -e "Roboshop User Already Created ....${Y}SKIPPING${N}"
else
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
validate $? "Creating roboshop user for running application " | tee -a  $logs_file
fi

mkdir -p /app &>> $logs_file
validate $? "Creating /app directory for application code " | tee -a  $logs_file

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>> $logs_file
validate $? "Downloading application code to tmp directory " | tee -a  $logs_file

cd /app &>> $logs_file
validate $? "Moving to app directory " | tee -a  $logs_file

unzip -o /tmp/catalogue.zip -d /app &>> "$logs_file"
validate $? "unzipping application code from tmp to app directoy " | tee -a  $logs_file

cd /app

npm install &>> $logs_file
validate $? "Installing Dependencies " | tee -a  $logs_file

cd /home/ec2-user/repos/roboshop-v1

cp /home/ec2-user/repo/roboshop-v1/catalogue.service  /etc/systemd/system/catalogue.service
validate $? "Copying service file to /etc/systemd/system/catalogue.service  " | tee -a  $logs_file

systemctl daemon-reload
validate $? "Reloading the daemon systemd " | tee -a  $logs_file

systemctl enable catalogue
validate $? "Enabling catalogue service " | tee -a  $logs_file

systemctl start catalogue
validate $? "Starting catalogue service " | tee -a  $logs_file

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Copying mongo repo to /etc/yum.repos.d/mongo.repo for installing mongo-client  " | tee -a  $logs_file


dnf install mongodb-mongosh -y &>> $logs_file
validate $? "Installing mongodb-mongosh client for loading data " | tee -a  $logs_file


product_count=$(mongosh --host mongodb.roboshop.anilkumarpatnana.online --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()') &>> $logs_file

if [ "$product_count" -ne 0 ]; then
    echo -e "Products data already added to MongoDB ....${Y}SKIPPING${N}" | tee -a "$logs_file"
else
    mongosh --host mongodb.roboshop.anilkumarpatnana.online < /app/db/master-data.js
    validate $? "Loading products data to MongoDB" | tee -a "$logs_file"
fi

echo -e "${Y}==========> VERIFICATION${N}"

systemctl status catalogue &>> $logs_file
validate $? "catalogue service is running " | tee -a  $logs_file

health_check=$(curl http://localhost:8080/health) | tee -a  $logs_file
validate $? "http://localhost:8080/health .... is responding " | tee -a  $logs_file

health_check=$(curl http://localhost:8080/products) | tee -a  $logs_file
validate $? "http://localhost:8080/products .... is responding " | tee -a  $logs_file



echo "$(timestamp)  [INFO] Time taken  $SECONDS" | tee -a  $logs_file

echo -e "$(timestamp)  [INFO]  ${R}========== ${C}Script Execution Completed${R} ==========>${N}" | tee -a  $logs_file
