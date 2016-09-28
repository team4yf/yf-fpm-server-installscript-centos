#! /bin/sh

# Author: yfsoft
# Version: 1.0.0
# Date: 2016-09-14
# Desc: for install,build,run nodejs & java code tools ,ex:jdk,maven,tomcat,node,npm,git ...

# Console Color Defined
RED_COLOR='\E[1;31m'
GREEN_COLOR='\E[1;32m'
YELOW_COLOR='\E[1;33m'
BLUE_COLOR='\E[1;34m'
PINK='\E[1;35m'
RES='\E[0m'

# Clear The Screen
clear

# Setup Files Directory
SETUP_DIR="/home/setups"

# YF WorkSpace Directory
YF_HOME_DIR="/home/yf"
YF_LOG_DIR="$YF_HOME_DIR/log"
YF_CONF_FILE="$YF_HOME_DIR/yf.conf"


# About Nodejs

NODE_DIR="$YF_HOME_DIR/nodejs"
NODE_LIB_DIR="$NODE_DIR/lib"
NODE_VERSION_CODE="v4.5.0"
NODE_VERSION="node-$NODE_VERSION_CODE-linux-x64"
NODE_TAR="$NODE_VERSION.tar"
NODE_XZ="$NODE_TAR.xz"
NODE_DOWNLOAD_URI="https://nodejs.org/dist/$NODE_VERSION_CODE/$NODE_XZ"
NODE_HOME_DIR="$NODE_LIB_DIR/$NODE_VERSION"

# About Mongodb

MONGO_DIR="$YF_HOME_DIR/mongodb"
MONGO_DATA_DIR="$MONGO_DIR/data"
MONGO_LOG_DIR="$MONGO_DIR/log"
MONGO_LIB_DIR="$MONGO_DIR/lib"
MONGO_VERSION_CODE="v3.0"
MONGO_TAR="mongodb-linux-x86_64-v3.0-latest.tgz"
MONGO_DOWNLOAD_URI="http://downloads.mongodb.org/linux/$MONGO_TAR"
MONGO_HOME_DIR="$MONGO_LIB_DIR/$MONGO_VERSION_CODE"

MONGO_STARTUP="$MONGO_HOME_DIR/bin/mongod --dbpath=$MONGO_DATA_DIR/ --logpath=$MONGO_LOG_DIR/log.log --fork"

# About Redis3.0

REDIS_DIR="$YF_HOME_DIR/redis"
REDIS_LIB_DIR="$REDIS_DIR/lib"
REDIS_VERSION_CODE="redis-3.0.7"
REDIS_TAR="$REDIS_VERSION_CODE.tar.gz"
REDIS_DOWNLOAD_URI="http://download.redis.io/releases/${REDIS_TAR}"
REDIS_HOME_DIR="$REDIS_LIB_DIR/$REDIS_VERSION_CODE"

REDIS_STARTUP="$REDIS_HOME_DIR/src/redis-server"

# About Tcl
TCL_DIR="$REDIS_LIB_DIR/tcl"
TCL_VERSION_CODE="tcl8.6.1"
TCL_TAR="tcl8.6.1-src.tar.gz"
TCL_DOWNLOAD_URI="http://nchc.dl.sourceforge.net/project/tcl/Tcl/8.6.1/$TCL_TAR"
TCL_HOME_DIR="$TCL_DIR/$TCL_VERSION_CODE"


# About Java

JAVA_DIR="$YF_HOME_DIR/java"
JAVA_LIB_DIR="$JAVA_DIR/lib"
JAVA_TARGET_DIR="$JAVA_DIR/target"

# JDK 1.8
JAVA_VERSION="jdk1.8.0_102"
JAVA_TAR="jdk-8u102-linux-x64.tar.gz"
JAVA_DOWNLOAD_URI="http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz"
JAVA_HOME_DIR="$JAVA_LIB_DIR/$JAVA_VERSION"

# Maven 3.3.9
MAVEN_VERSION="apache-maven-3.3.9"
MAVEN_TAR="$MAVEN_VERSION-bin.tar.gz"
MAVEN_DOWNLOAD_URI="http://mirrors.cnnic.cn/apache/maven/maven-3/3.3.9/binaries/$MAVEN_TAR"
MAVEN_DIR="$JAVA_LIB_DIR/$MAVEN_VERSION"

# Tomcat 8.5.5
TOMCAT_VERSION="apache-tomcat-8.5.5"
TOMCAT_TAR="$TOMCAT_VERSION.tar.gz"
TOMCAT_DOWNLOAD_URI="http://apache.fayea.com/tomcat/tomcat-8/v8.5.5/bin/$TOMCAT_TAR"
TOMCAT_HOME_DIR="$JAVA_LIB_DIR/$TOMCAT_VERSION"
TOMCAT_DEPLOY_DIR="$TOMCAT_HOME_DIR/webapps"

TOMCAT_PORT="8080"


# 需要读取相关的配置文件
if [ -f $YF_CONF_FILE ]; then
  TOMCAT_HOME_DIR=`grep 'TOMCAT_HOME=' $YF_CONF_FILE`
  TOMCAT_HOME_DIR=${TOMCAT_HOME_DIR#*=}
  TOMCAT_PORT=`grep 'TOMCAT_PORT=' $YF_CONF_FILE`
  TOMCAT_PORT=${TOMCAT_PORT#*=}
  TOMCAT_DEPLOY_DIR="$TOMCAT_HOME_DIR/webapps"
fi


# Functions
# Return Code 0 : ok , others : error

# Install
function yfInstall {

  if [ ! -d $SETUP_DIR ]; then
    mkdir -p $SETUP_DIR
  fi

  NOW_TIME=`date '+%m%d%H%M'`

  ### Create Directory
  echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Create YF Dir    <<<<<<<<<<<<<<<<${RES}"
  mkdir -p $YF_HOME_DIR
  mkdir -p $YF_LOG_DIR

  ### Install nodejs
  if [ ! -d $NODE_HOME_DIR ]; then
    mkdir -p $NODE_LIB_DIR

    echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Nodejs    <<<<<<<<<<<<<<<<${RES}"
    cd $NODE_LIB_DIR
    if [ -f $SETUP_DIR/$NODE_XZ ]; then
      cp $SETUP_DIR/$NODE_XZ $NODE_LIB_DIR/$NODE_XZ
    else
      wget $NODE_DOWNLOAD_URI
      cp $NODE_XZ $SETUP_DIR/$NODE_XZ
    fi
    xz -d $NODE_XZ
    tar -xvf $NODE_TAR > $YF_LOG_DIR/$NOW_TIME.nodejs.install.log

    echo "NODE_HOME=$NODE_HOME_DIR" >> /etc/profile
    echo 'PATH=$NODE_HOME/bin:$PATH' >> /etc/profile
    echo 'NODE_PATH=$NODE_HOME/lib/node_modules' >> /etc/profile
    echo "export NODE_HOME PATH NODE_PATH" >> /etc/profile
    source /etc/profile
    node -v
    npm install -g pm2
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Nodejs Installed   <<<<<<<<<<<<<<<<${RES}"
  fi


  ### Install Mongodb
  if [ ! -d $MONGO_DIR ]; then
    mkdir -p $MONGO_DATA_DIR
    mkdir -p $MONGO_LOG_DIR
    mkdir -p $MONGO_LIB_DIR
    echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Mongodb    <<<<<<<<<<<<<<<<${RES}"
    cd $MONGO_LIB_DIR
    if [ -f $SETUP_DIR/$MONGO_TAR ]; then
      cp $SETUP_DIR/$MONGO_TAR $MONGO_LIB_DIR/$MONGO_TAR
    else
      wget $MONGO_DOWNLOAD_URI
      cp $MONGO_TAR $SETUP_DIR/$MONGO_TAR
    fi
    tar -zxvf $MONGO_TAR > $YF_LOG_DIR/$NOW_TIME.mongodb.install.log
    rm -rf $MONGO_TAR
    mv mongodb* $MONGO_HOME_DIR
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Mongodb Installed   <<<<<<<<<<<<<<<<${RES}"
  fi

  ### Install Redis
  if [ ! -d $REDIS_DIR ]; then
    mkdir -p $REDIS_LIB_DIR
    echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Tcl    <<<<<<<<<<<<<<<<${RES}"
    mkdir -p $TCL_DIR
    cd $TCL_DIR
    if [ -f $SETUP_DIR/$TCL_TAR ]; then
      cp $SETUP_DIR/$TCL_TAR $TCL_DIR/$TCL_TAR
    else
      wget $TCL_DOWNLOAD_URI
      cp $TCL_TAR $SETUP_DIR/$TCL_TAR
    fi
    tar -zxvf $TCL_TAR > $YF_LOG_DIR/$NOW_TIME.tcl.install.log
    cd $TCL_HOME_DIR/unix
    ./configure
    make
    make install

    echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Redis    <<<<<<<<<<<<<<<<${RES}"
    cd $REDIS_LIB_DIR
    if [ -f $SETUP_DIR/$REDIS_TAR ]; then
      cp $SETUP_DIR/$REDIS_TAR $REDIS_LIB_DIR/$REDIS_TAR
    else
      wget $REDIS_DOWNLOAD_URI
      cp $REDIS_TAR $SETUP_DIR/$REDIS_TAR
    fi
    tar -zxvf $REDIS_TAR > $YF_LOG_DIR/$NOW_TIME.redis.install.log
    cd $REDIS_HOME_DIR
    make
    make install
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Redis Installed   <<<<<<<<<<<<<<<<${RES}"
  fi

  ### Install JDK
  if [ ! -d $JAVA_HOME_DIR ]; then
    mkdir -p $JAVA_DIR
    mkdir -p $JAVA_LIB_DIR
    mkdir -p $JAVA_TARGET_DIR
    echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install JDK    <<<<<<<<<<<<<<<<${RES}"
    cd $JAVA_LIB_DIR
    if [ -f $SETUP_DIR/$JAVA_TAR ]; then
      cp $SETUP_DIR/$JAVA_TAR $JAVA_LIB_DIR/$JAVA_TAR
    else
      wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" -O $JAVA_TAR $JAVA_DOWNLOAD_URI
      cp $JAVA_TAR $SETUP_DIR/$JAVA_TAR
    fi

    tar -zxvf $JAVA_TAR > $YF_LOG_DIR/$NOW_TIME.jdk.install.log

    echo "JAVA_HOME=$JAVA_HOME_DIR" >> /etc/profile
    echo 'PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
    echo 'CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile
    echo "export JAVA_HOME PATH CLASSPATH" >> /etc/profile
    source /etc/profile
    java -version
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       JDK Installed   <<<<<<<<<<<<<<<<${RES}"
  fi

  ### Install Tomcat
  if [ ! -d $TOMCAT_HOME_DIR ]; then
    echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Tomcat    <<<<<<<<<<<<<<<<${RES}"
    cd $JAVA_LIB_DIR
    if [ -f $SETUP_DIR/$TOMCAT_TAR ]; then
      cp $SETUP_DIR/$TOMCAT_TAR $JAVA_LIB_DIR/$TOMCAT_TAR
    else
      wget $TOMCAT_DOWNLOAD_URI
      cp $TOMCAT_TAR $SETUP_DIR/$TOMCAT_TAR
    fi

    tar -zxvf $TOMCAT_TAR > $YF_LOG_DIR/$NOW_TIME.tomcat.install.log
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Tomcat Installed   <<<<<<<<<<<<<<<<${RES}"
  fi


  ### Install Maven
  if [ ! -d $MAVEN_DIR ]; then
    echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Maven    >> <<<<<<<<<<<<<<<<${RES}"
    cd $JAVA_LIB_DIR
    if [ -f $SETUP_DIR/$MAVEN_TAR ]; then
      cp $SETUP_DIR/$MAVEN_TAR $JAVA_LIB_DIR/$MAVEN_TAR
    else
      wget $MAVEN_DOWNLOAD_URI
      cp $MAVEN_TAR $SETUP_DIR/$MAVEN_TAR
    fi
    tar -zxvf $MAVEN_TAR > $YF_LOG_DIR/$NOW_TIME.maven.install.log
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Maven Installed   <<<<<<<<<<<<<<<<${RES}"
  fi

  ###  Install Git & lsof
  echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Git & LSOF    <<<<<<<<<<<<<<<<${RES}"
  yum install git
  yum install lsof
  echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Git & LSOF Installed   <<<<<<<<<<<<<<<<${RES}"
  echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>     Install Done ${RES}"
  return 0
}

function yfStartup {
  echo -e "${PINK}启动mongodb${RES}"
  $MONGO_STARTUP
  echo -e "${PINK}指令：$MONGO_STARTUP ${RES}"

  echo -e "${PINK}启动redis${RES}"
  nohup $REDIS_STARTUP &
  echo -e "${PINK}指令：$REDIS_STARTUP ${RES}"
}

# 配置设置
function yfConfig {
  echo -e "${PINK}请输入tomcat的所在目录(默认:$TOMCAT_HOME_DIR)? ${RES}"
  read -p ":" _tomcatHome
  if [ -z $_tomcatHome ]; then
    echo -e "${PINK}确认要使用默认的安装目录: $TOMCAT_PORT?${RES}"
    read -p "[y/n]:" isYN
    if [ ! $isYN = "y" ]; then
      echo -e "${PINK}[ERROR]您已放弃本次配置，请在下一次部署工程前完成配置，否则将无法部署 ${RES}"
      return 11
    else
      TOMCAT_HOME_DIR="$TOMCAT_HOME_DIR"
    fi
  else
    TOMCAT_HOME_DIR=$_tomcatHome
  fi
  echo -e "${PINK}请输入tomcat所使用的端口(默认:$TOMCAT_PORT)?${RES}"
  read -p  ":" _tomcatPort
  if [ -z $_tomcatPort ]; then
    echo -e "${PINK}确认要使用默认的端口号: $TOMCAT_PORT?${RES}"
    read -p "[y/n]:" isYN
    if [ ! $isYN = "y" ]; then
      echo -e "${PINK}[ERROR]您已放弃本次配置，请在下一次部署工程前完成配置，否则将无法部署 ${RES}"
      return 12
    else
      TOMCAT_PORT="$TOMCAT_PORT"
    fi
  else
    TOMCAT_PORT=$_tomcatPort
  fi
  # 写入文件
  rm -f $YF_CONF_FILE
  echo "TOMCAT_HOME=$TOMCAT_HOME_DIR" > $YF_CONF_FILE
  echo "TOMCAT_PORT=$TOMCAT_PORT" >> $YF_CONF_FILE
  return 0
}

# Clean The WorkSpace
function yfClean {
  if [ ! -d $YF_HOME_DIR ]; then
    #该目录已经不存在
    echo -e "${PINK}目录 : $YF_HOME_DIR 已不存在,无需删除~ ${RES}"
    return 22
  fi
  echo -e "${PINK}确认要清除CI目录[$YF_HOME_DIR]么?${RES}"
  read -p "[y/n]:" isYN
  if [ $isYN = "y" ]; then
    rm -rf $YF_HOME_DIR
    echo -e "${PINK}环境变量的配置文件中的内容需要手动去除,$ vi /etc/profile ${RES}"
  else
    echo "Bye"
    return 21
  fi
  return 0
}


function yfRequireCommand {
  echo -e "${GREEN_COLOR}[GO]>>>>>>  您输入的参数错误，可选的参数如下：         ${RES}"
  echo -e "${GREEN_COLOR}[GO]>>>>>>  yfci install  : 安装ci目录，maven，下载git代码          ${RES}"
  echo -e "${GREEN_COLOR}[GO]>>>>>>  yfci build  ：编译git仓库中最新的代码 ${RES}"
  echo -e "${GREEN_COLOR}[GO]>>>>>>  yfci deploy ：将代码发布到servlet容器中并重启该容器 ${RES}"
  echo -e "${GREEN_COLOR}[GO]>>>>>>  yfci conf ：设置servlet容器的目录和端口 ${RES}"
}
echo -e "${BLUE_COLOR}[GO]>>>>>>>>>>>> Command:[$1]>>>>>>>>>>>>>>${RES}"

#没有值
if [ -z $1 ]; then
  yfRequireCommand
  exit
## 安装流程
elif [ $1 = "install" ]; then

  yfInstall

## 安装流程
elif [ $1 = "startup" ]; then

  yfStartup

elif [ $1 = "conf" ]; then

  ciConfig
  if [ $? > 0 ]; then
    exit
  fi

elif [ $1 = "clean" ]; then
  yfClean
  if [ $? > 0 ]; then
    exit
  fi
else
  ciRequireCommand
  exit
fi #end if
