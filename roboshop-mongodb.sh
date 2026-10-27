#!/bin/bash

user_id=$(id -u)

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
    echo "$2 installed successfully"
    else
    echo "$2 installation failed"
    fi
}


dnf install nginxx
validate $? "Nginx"



