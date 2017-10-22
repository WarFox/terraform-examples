#!/usr/bin/env bash
yum update -y
yum install mysql-server -y
service mysqld start
chkconfig mysqld on
