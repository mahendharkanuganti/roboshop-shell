#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disable the old nodejs versions"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enable the nodejs version 20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id roboshop  &>>$LOGFILE
if [ $? -ne 0 ]
then
    echo "User roboshop doesn't exist. Proceed to add user"
    useradd roboshop
    VALIDATE &? "Added roboshop user"
else
    echo "roboshop user already exist"
fi

rm -rf /app  &>>$LOGFILE 
VALIDATE $? "Remove the old /app direcory"

mkdir /app &>>$LOGFILE
VALIDATE $? "Create new /app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip  &>>$LOGFILE
VALIDATE $? "Download the application code"

cd /app
unzip /tmp/cart.zip &>>$LOGFILE
VALIDATE $? "unzip the code"

npm install &>>$LOGFILE
VALIDATE $? "Download and install the dependencies"

cp /root/roboshop-shell/cart.service /etc/systemd/system/cart.service &>>$LOGFILE
VALIDATE $? "Copy the catrt sevice file"

systemctl daemon-reload &>>$LOGFILE

systemctl enable cart &>>$LOGFILE
VALIDATE $? "Enable cart service"

systemctl start cart &>>$LOGFILE
VALIDATE $? "Start the cart service"
