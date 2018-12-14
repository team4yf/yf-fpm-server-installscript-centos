#! /bin/sh

# Author: yfsoft
# Version: 1.0.0
# Date: 2018-10-17
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
NODE_VERSION_CODE="v8.11.1"
NODE_VERSION="node-$NODE_VERSION_CODE-linux-x64"
NODE_TAR="$NODE_VERSION.tar"
NODE_XZ="$NODE_TAR.xz"
NODE_DOWNLOAD_URI="https://nodejs.org/dist/$NODE_VERSION_CODE/$NODE_XZ"
NODE_HOME_DIR="$NODE_LIB_DIR/$NODE_VERSION"

# Functions
# Return Code 0 : ok , others : error

# Install
function yfInstall {
  # Install gcc
  yum install gcc

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
    npm install -g yarn
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Nodejs Installed   <<<<<<<<<<<<<<<<${RES}"
  fi

  ###  Install Git & lsof
  echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Git & LSOF    <<<<<<<<<<<<<<<<${RES}"
  yum install git
  yum install lsof
  echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Git & LSOF Installed   <<<<<<<<<<<<<<<<${RES}"
  echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>     Install Done ${RES}"
  return 0
}

function yfRequireCommand {
  echo -e "${GREEN_COLOR}[GO]>>>>>>  您输入的参数错误，可选的参数如下：         ${RES}"
  echo -e "${GREEN_COLOR}[GO]>>>>>>  yfci install  : 安装ci目录，maven，下载git代码          ${RES}"
}
echo -e "${BLUE_COLOR}[GO]>>>>>>>>>>>> Command:[$1]>>>>>>>>>>>>>>${RES}"

#没有值
if [ -z $1 ]; then
  yfRequireCommand
  exit
## 安装流程
elif [ $1 = "install" ]; then

  yfInstall
else
  ciRequireCommand
  exit
fi #end if