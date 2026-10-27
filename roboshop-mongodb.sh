#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/shell-practice"
logs_file="$logs_folder/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $logs_folder &>> $logs_file

if [ $user_id -eq  0 ];
 then
 echo "Thanks for executing file with sudo access" &>> $logs_file
 else
 echo "Please execute file with sudo access" &>> $logs_file
 exit 1
fi

validate(){
    if [ $1 -eq 0 ];
    then
    echo -e "$2 .....${G}Success${N}" &>> $logs_file
    else
    echo -e "$2 .....${R}failed${N}" &>> $logs_file
    fi
}

for package in $@
do
   dnf installed ${package} &>> $logs_file
   if [ $? -ne  0 ];
    then
     dnf install ${package} -y &>> $logs_file
     validate $? "${package} installed ${G}successfully${N}" &>> $logs_file
    else
     echo "${package} already installed...${Y}SKIPPING${N}" &>> $logs_file
   fi  
done



