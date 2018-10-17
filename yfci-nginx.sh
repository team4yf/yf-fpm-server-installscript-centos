#! /bin/sh

yum install openssl
yum install zlib
yum install pcre

yum install nginx

service nginx start
