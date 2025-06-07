#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.arunjesusdevops.site

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then            
        echo -e "$2...$R FAILED $N"
    else
        echo -e "$2. .$G SUCESS $N" 
   fi
}

dnf module disable nodejs -y

VALIDATE $? "Disabling current nodejs"

dnf module enable nodejs:20 -y

VALIDATE $? "Enabling nodejs 20" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "Installing nodejs 20" &>> $LOGFILE

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop

VALIDATE $? "Creating the ROBOSHOP user" &>> $LOGFILE

mkdir /app 

VALIDATE $? "Creating the APP directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 

VALIDATE $? "Downloading the catalogue application" &>> $LOGFILE

cd /app

unzip /tmp/catalogue.zip

VALIDATE $? "Unzipping catalogue" &>> $LOGFILE

npm install 

VALIDATE $? "Installing Dependencies" &>> $LOGFILE

cp /root/roboshop-shell/robo-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE$? "Copying the catalogue service file"

systemctl daemon-reload

VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue 

VALIDATE $? "enable catalogue"

systemctl start catalogue

VALIDATE $? "start catalogue"

cp /root/roboshop-shell/robo-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongorepo"

dnf install mongodb-mongosh -y

VALIDATE $? "Installing mongo client"

mongosh --host $MONGDB_HOST </app/db/master-data.js

VALIDATE $? "Loading catlogue date into MongoDB"
