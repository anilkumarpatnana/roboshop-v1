#!/bin/bash

user_id=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
NC="\e[0m"

if [ $user_id -eq  0 ];
 then
 echo "Thanks for executing file with sudo access"
 else
 echo "Please execute file with sudo access"
 exit 1
fi

validate(){
    if [ $1 -eq 0 ];
    then
    echo -e "$2 .....$(G)Success"
    else
    echo -e "$2 .....$(R)failed"
    fi
}


dnf install nginx -y
validate $? "nginx installation"



