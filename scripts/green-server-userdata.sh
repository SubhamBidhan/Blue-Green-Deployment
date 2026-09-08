#!/bin/bash
sudo -s
yum install -y httpd
yum install -y wget
wget --content-disposition https://templatemo.com/download/templatemo_558_klassy_cafe
yum install -y unzip
unzip templatemo_558_klassy_cafe.zip
cp -r templatemo_558_klassy_cafe/* /var/www/html
systemctl enable httpd
systemctl start httpd
