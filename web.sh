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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling nginx service"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Remove the default application content"

rm -rf /tmp/web* &>>$LOGFILE
VALIDATE $? "Remove the old Zipped content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE
VALIDATE $? "download the frontend content"

cd /usr/share/nginx/html &>>$LOGFILE

unzip /tmp/web.zip &>>$LOGFILE
VALIDATE $? "unzip the content"

cp /root/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf
VALIDATE $? "copy the roboshop configuration file"

systemctl restart nginx 
VALIDATE $? "Restart nginx service"



