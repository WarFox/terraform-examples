#!/usr/bin/env bash
yum install httpd -y
yum update -y
service httpd start
chkconfig httpd on
echo "<html><head><title>Hello World!</title></head><body><h1>Hello World!</h1></body></html>" > /var/www/html/index.html
