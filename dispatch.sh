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

dnf install golang -y &>>$LOGFILE
VALIDATE $? "Installing golang"

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

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE
VALIDATE $? "Downloading the application code"

cd /app
unzip /tmp/dispatch.zip &>>$LOGFILE
VALIDATE $? "unzip the code"

go mod init dispatch &>>$LOGFILE
go get &>>$LOGFILE
go build &>>$LOGFILE
VALIDATE $? "Download the dependencies & build the software"

cp /root/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service
VALIDATE $? "Copy the dispatch service config file"

systemctl daemon-reload &>>$LOGFILE

systemctl enable dispatch &>>$LOGFILE
systemctl start dispatch &>>$LOGFILE
VALIDATE $? "ENable and start the dispatch service"