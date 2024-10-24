#!/bin/bash

cd /home/csye6225/webapp/

touch .env
echo "DB_PORT=3306" >> .env
echo "DB_HOST=${db_host}" >> .env
echo "DB_DATABASE=${db_name}" >> .env
echo "DB_USERNAME=${db_username}" >> .env
echo "DB_PASSWORD=${db_password}" >> .env

sudo systemctl enable webapp.service
sudo systemctl start webapp.service

