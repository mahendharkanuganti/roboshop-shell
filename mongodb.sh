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
        echo -e "$2...$R SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access"
    exit 1  # manually exit the script if error comes
else
    echo "you are a super user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied mongo repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installing mongoDB"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabling mongoDB"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Starting MongoDB service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? Remote server access

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restart MongoDB service"