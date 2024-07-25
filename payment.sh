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

dnf install python3.12 gcc python3-devel -y -y &>>$LOGFILE
VALIDATE $? "Installing python"

id roboshop &>>$LOGFILE
if [ $? -ne 0 ]
then
    echo "Roboshop used doesn't exist."
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Added roboshop user"
else
    echo "roboshop user already exists"
fi

rm -rf /app  &>>$LOGFILE 
VALIDATE $? "Remove the old /app direcory"

mkdir /app &>>$LOGFILE
VALIDATE $? "Create new /app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
VALIDATE $? "Downloading the application code"

cd /app
unzip /tmp/payment.zip &>>$LOGFILE
VALIDATE $? "unzip the code"

pip3.9 install -r requirements.txt &>>$LOGFILE
VALIDATE $? "Download and install the dependencies"

cp /root/roboshop-shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "Copy the payment service file"

systemctl daemon-reload &>>$LOGFILE

systemctl enalbe payment &>>$LOGFILE
VALIDATE "Enable the payment service"

systemctl start payment &>>$LOGFILE
VALIDATE $? "Start the payment service




