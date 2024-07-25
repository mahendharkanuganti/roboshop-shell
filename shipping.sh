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

dnf install maven -y &>>$LOGFILE
VALIDATE $? "Installing Maven software"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE
VALIDATE $? "Downloading the application code"

cd /app
unzip /tmp/shipping.zip &>>$LOGFILE
VALIDATE $? "unzip the code"

mvn clean package &>>$LOGFILE
VALIDATE $? "Build the application"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
VALIDATE $? "Rename the .jar file"

cp /root/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "copy the shipping service configuration file"

systemctl daemon-reload &>>$LOGFILE
systemctl enable shipping &>>$LOGFILE
VALIDATE $? "Enable the shipping service"

systemctl start shipping &>>$LOGFILE
VALIDATE $? "Start the shipping service"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.mahidevops.cloud -u root -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE
VALIDATE $? "Load the shipping application schema into MySQL Database"

systemctl restart shipping &>>$LOGFILE
VALIDATE $? "Restart the shipping service"

