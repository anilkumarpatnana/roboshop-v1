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


for package in "$@"
do
    if dnf list installed "$package" &>> "$logs_file"; then
        echo -e "${package} already installed...${Y}SKIPPING${N}" | tee -a "$logs_file"

    elif dnf list available "$package" &>> "$logs_file"; then
        echo "Going to install: ${package}" | tee -a "$logs_file"

        dnf install "$package" -y &>> "$logs_file"
        validate $? "Installing ${package}"

    else
        echo -e "${package} not available in repositories...${R}FAILED${N}" | tee -a "$logs_file"
        exit 1
    fi
done




