### yf-fpm-server配套的服务端安装脚本centos版

为了能更快捷的安装和部署环境，编写的自动化安装脚本，包含如下程序：
- nodejs 4.5
- mongodb 3.0.12
- redis 3.0
- jdk 1.8
- maven 3.3.9
- tomcat 8.5.5 8080端口
- git
- lsof

*默认安装目录*

`
$ /home/yf
`

#### 使用方法

###### 1.下载脚本
`
$ git clone https://github.com/team4yf/yf-fpm-server-installscript-centos.git
`
###### 2.复制到/usr/bin目录下
`
$ cp yf-fpm-server-installscript-centos/yfci.sh /usr/bin/yfci
`

###### 3.赋予可执行权限
`
$ chmod +x yfci
`

###### 4.执行安装指令
`
$ yfci install
`

###### 5.查看安装情况
`
$ cd /home/yf
`
可以查看相应的程序已经安装完毕了

###### 6.启动mongodb和redis服务
`
$ yfci startup
`
通过数据可以查看到2个数据库已经正常启动了



###### 7. Run Ftp
```
docker run -d \
--name ftpd_server \
-p 21:21 -p 30000-31009:30000-31009 \
-e "PUBLICHOST=47.92.217.52" \
-e "FTP_MAX_CONNECTIONS=50" \
-e "FTP_MAX_CLIENTS=50" \
-v /home/ftpusers/admin:/home/ftpusers/admin --restart=always stilliard/pure-ftpd:hardened


# make user the dir root
chmod 777 -R /home/ftpusers/

# enter the container
docker exec -it ftpd_server /bin/bash
# run the scripts
pure-pw useradd admin -u ftpuser -d /home/ftpusers/admin
chown ftpuser:ftpgroup /home/ftpusers/admin
pure-pw mkdb

```