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
    echo "Please run this script with root access"
    exit 1  # manually exit the script if error comes
else
    echo "you are a super user"
fi

dnf module disable nodejs -y
VALIDATE $? "disble old version off Nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enable Nodejs version:20"

dnf install nodejs -y
VALIDATE $? "Install Nodejs"

if [ "id roboshop" -ne 0 ]
then
    echo "roboshop user doesn't exist. continue with user creation"
    useradd roboshop
    VALIDATE $? "Adding roboshop user"
else
    echo "roboshop user already exist"
fi

rm -rf /app
mkdir /app

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Download the application"

cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "Unzip the appication"

npm install 
VALIDATE $? "Install the dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copy the catalogue service file"

systemctl daemon-reload
VALIDATE $? "Relaod the system daemon"

systemctl enable catalogue
VALIDATE $? "Enable catalogue service"

systemctl start catalogue
VALIDATE $? "Start catalogue service"

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copy the MongoDB repo"

dnf install -y mongodb-mongosh
VALIDATE $? "Install the mongodb clinet"

mongosh --host mongodb.mahidevops.cloud </app/schema/catalogue.js
VALIDATE $? "Load the catalogue application schema to MongoDB"
