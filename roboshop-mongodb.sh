#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $logs_folder



if [ $user_id -ne  0 ];
 then
 echo "Please  executing file with sudo access"
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
   dnf list installed ${package} &>> $logs_file
   if [ $? -ne  0 ];
    then
    echo "Going to install : ${package}" | tee -a  $logs_file
     dnf install ${package} -y &>> $logs_file
     validate $? "Installing ${package}" &>> $logs_file
    else
     echo -e  "${package} already installed...${Y}SKIPPING${N}" | tee -a  $logs_file
   fi  
done



