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

cp rabbitmq.repo /etc/yum.repos.d/  &>> $logs_file
validate $? "Adding rabbitmq repo file to yum.repos.d" | tee -a  $logs_file

dnf install erlang rabbitmq-server -y  &>> $logs_file
validate $? "Installing rabbitmq-server" | tee -a  $logs_file

systemctl enable rabbitmq-server  &>> $logs_file
validate $? "Enabling rabbitmq-server service" | tee -a  $logs_file

systemctl start rabbitmq-server  &>> $logs_file
validate $? "Starting rabbitmq-server service" | tee -a  $logs_file

rabbitmqctl add_user roboshop roboshop123  &>> $logs_file
validate $? "Creating rabbitmq user for RoboShop" | tee -a  $logs_file

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $logs_file
validate $? "Providing permission for user roboshop configure, read, write permission" | tee -a  $logs_file

systemctl status rabbitmq-server &>> $logs_file
validate $? "rabbitmq service is running " | tee -a  $logs_file

ss -lntp | grep 5672  &>> $logs_file
validate $? "rabbitmq listening on port no 5672" | tee -a  $logs_file

rabbitmq-plugins enable rabbitmq_management &>> $logs_file
rabbitmqctl set_user_tags roboshop administrator &>> $logs_file




echo "$(timestamp)  [INFO] Time taken  $SECONDS" | tee -a  $logs_file

echo "$(timestamp)  [INFO]  ========== Script execution completed ==========>" | tee -a  $logs_file
