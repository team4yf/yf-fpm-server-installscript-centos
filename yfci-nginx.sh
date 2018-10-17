#! /bin/sh

yum install openssl
yum install zlib
yum install pcre

yum install nginx

service nginx start
cd /etc/nginx/conf.d/default/conf
pwd
