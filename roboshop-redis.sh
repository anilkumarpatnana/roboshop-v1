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

dnf module disable redis -y &>> $logs_file
validate $? "redis default module disabling" &>> $logs_file

dnf module enable redis:7 -y &>> $logs_file
validate $? "enabling redis module " &>> $logs_file

dnf install redis -y &>> $logs_file
validate $? "redis installation" &>> $logs_file

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> $logs_file
validate $? "enabled redis to listen from all addresses and updated protected mode to NO" | tee -a  $logs_file

systemctl enable redis &>> $logs_file
systemctl start redis &>> $logs_file
validate $? "Starting and enabling redis" | tee -a  $logs_file

systemctl status redis &>> $logs_file
validate $? "redis service running" | tee -a  $logs_file

ss -lntp | grep 6379 &>> $logs_file
validate $? "redis is listening on port 6379" | tee -a  $logs_file

redis-cli ping &>> $logs_file
validate $? "redis-cli responding" | tee -a  $logs_file




