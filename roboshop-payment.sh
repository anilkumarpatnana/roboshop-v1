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
 

dnf install python3.14 python3.14-pip -y &>> $logs_file
validate $? "Installing  python3.14 " | tee -a  $logs_file

python3.14 --version | tee -a  $logs_file

if grep -q "^roboshop:" /etc/passwd;
then
 echo -e "roboshop user already created ....${Y}SKIPPING${N}"
else
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Creating user roboshop " | tee -a  $logs_file
fi


mkdir -p /app  &>> $logs_file
validate $? "Creating app directory " | tee -a  $logs_file

curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip

unzip -o /tmp/payment.zip -d /app  &>> $logs_file
validate $? "Unzipping payment to /app " | tee -a  $logs_file


cd /app

python3.14 -m venv /app/.venv
validate $? "Creating virtual environment  " | tee -a  $logs_file


/app/.venv/bin/pip install -r requirements.txt
validate $? "Installing dependencies " | tee -a  $logs_file


cp /home/ec2-user/repo/roboshop-v1/payment.service /etc/systemd/system/payment.service
validate $? "Copying payment.service file to  /etc/systemd/system/payment.service " | tee -a  $logs_file


systemctl daemon-reload
validate $? "Reloading deamon systemd  " | tee -a  $logs_file

systemctl enable payment
validate $? "Enabling payment service " | tee -a  $logs_file

systemctl start payment
validate $? "Starting payment service " | tee -a  $logs_file


echo "$(timestamp)  [INFO] Time taken  $SECONDS" | tee -a  $logs_file

echo -e "$(timestamp)  [INFO]  ${R}========== ${C}Script Execution Completed${R} ==========>${N}" | tee -a  $logs_file

