#!/bin/bash
sudo -s
yum install -y httpd
yum install -y wget
wget --content-disposition https://templatemo.com/download/templatemo_591_villa_agency
yum install -y unzip
unzip templatemo_591_villa_agency.zip
cp -r templatemo_591_villa_agency/* /var/www/html
systemctl enable httpd
systemctl start httpd
