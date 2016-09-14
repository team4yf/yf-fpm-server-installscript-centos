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
YF_HOME_DIR="/home/ci/java"
YF_LIB_DIR="$YF_HOME_DIR/lib"
YF_TARGET_DIR="$YF_HOME_DIR/target"
YF_LOG_DIR="$YF_HOME_DIR/log"
YF_CONF_FILE="$YF_HOME_DIR/ci.conf"

# About Nodejs

NODE_VERSION=""
NODE_DOWNLOAD_URI=""
NODE_DIR=""


# About Java

# JDK 1.8
JAVA_VERSION="jdk1.8.0_102"
JAVA_TAR="jdk-8u102-linux-x64.tar.gz"
JAVA_DOWNLOAD_URI="http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz"
JAVA_HOME_DIR="$CI_LIB_DIR/$JAVA_VERSION"

# Maven 3.3.9
MAVEN_VERSION="apache-maven-3.3.9"
MAVEN_TAR="$MAVEN_VERSION-bin.tar.gz"
MAVEN_DOWNLOAD_URI="http://mirrors.cnnic.cn/apache/maven/maven-3/3.3.9/binaries/$MAVEN_TAR"
MAVEN_DIR="$CI_LIB_DIR/$MAVEN_VERSION"

# Tomcat 8.5.4
TOMCAT_VERSION="apache-tomcat-8.5.4"
TOMCAT_TAR="$TOMCAT_VERSION.tar.gz"
TOMCAT_DOWNLOAD_URI="http://mirrors.cnnic.cn/apache/tomcat/tomcat-8/v8.5.4/bin/$TOMCAT_TAR"
TOMCAT_HOME_DIR="$CI_LIB_DIR/$TOMCAT_VERSION"
TOMCAT_DEPLOY_DIR="$TOMCAT_HOME_DIR/webapps"

TOMCAT_PORT="8080"


# 需要读取相关的配置文件
if [ -f $CI_CONF_FILE ]; then
  TOMCAT_HOME_DIR=`grep 'TOMCAT_HOME=' $CI_CONF_FILE`
  TOMCAT_HOME_DIR=${TOMCAT_HOME_DIR#*=}
  TOMCAT_PORT=`grep 'TOMCAT_PORT=' $CI_CONF_FILE`
  TOMCAT_PORT=${TOMCAT_PORT#*=}
  TOMCAT_DEPLOY_DIR="$TOMCAT_HOME_DIR/webapps"
fi

# 项目的变量定义
PROJECT_GIT="https://git.oschina.net/yfdever/BizApi.git"
PROJECT_DIR="$CI_HOME_DIR/BizApi"
PROJECT_SOURCE_DIR="$PROJECT_DIR/api"
PROJECT_TARGET_DIR="$PROJECT_SOURCE_DIR/target"
PROJECT_TARGET_VERSION_CODE=`date '+%m%d%H%M'`


# 定义相关的函数
# 返回 0 表示操作成功，小于 0 的所有返回值，均为执行错误

# 安装操作
function ciInstall {
  ### 创建CI工作区
  echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Create CI Dir    >> >>>>>>>>>>>>>>>>${RES}"
  #放心执行，因为已经存在的忽略掉的
  mkdir -p $YF_HOME_DIR
  mkdir -p $CI_LIB_DIR
  mkdir -p $CI_TARGET_DIR
  mkdir -p $CI_LOG_DIR

  ### 安装 jdk 1.8
  #判断是否安装过 jdk
  if [ ! -d $JAVA_HOME_DIR ]; then
    echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install JDK    >> >>>>>>>>>>>>>>>>${RES}"
    cd $CI_LIB_DIR
    if [ -f $SETUP_DIR/$JAVA_TAR ]; then
      cp $SETUP_DIR/$JAVA_TAR $CI_LIB_DIR/$JAVA_TAR
    else
      wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" -O $JAVA_TAR $JAVA_DOWNLOAD_URI
    fi

    tar -zxvf $JAVA_TAR
    # TODO:修改环境变量
    echo "JAVA_HOME=$JAVA_HOME_DIR" >> /etc/profile
    echo 'PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
    echo 'CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile
    echo "export JAVA_HOME PATH CLASSPATH" >> /etc/profile
    source /etc/profile
    java -version
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       JDK Installed   >> >>>>>>>>>>>>>>>>${RES}"
  fi

  ### 安装 tomcat
  #判断是否安装过 tomcat
  if [ ! -d $TOMCAT_HOME_DIR ]; then
    echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Tomcat    >> >>>>>>>>>>>>>>>>${RES}"
    cd $CI_LIB_DIR
    if [ -f $SETUP_DIR/$TOMCAT_TAR ]; then
      cp $SETUP_DIR/$TOMCAT_TAR $CI_LIB_DIR/$TOMCAT_TAR
    else
      wget $TOMCAT_DOWNLOAD_URI
    fi

    tar -zxvf $TOMCAT_TAR
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Tomcat Installed   >> >>>>>>>>>>>>>>>>${RES}"
  fi


  ### 安装 maven
  #判断是否安装过maven
  if [ ! -d $MAVEN_DIR ]; then
    echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Maven    >> >>>>>>>>>>>>>>>>${RES}"
    cd $CI_LIB_DIR
    if [ -f $SETUP_DIR/$MAVEN_TAR ]; then
      cp $SETUP_DIR/$MAVEN_TAR $CI_LIB_DIR/$MAVEN_TAR
    else
      wget $MAVEN_DOWNLOAD_URI
    fi
    tar -zxvf $MAVEN_TAR
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Maven Installed   >> >>>>>>>>>>>>>>>>${RES}"
  fi

  ### 安装 git & lsof
  echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Install Git & LSOF    >> >>>>>>>>>>>>>>>>${RES}"
  yum install git
  yum install lsof
  echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Git & LSOF Installed   >> >>>>>>>>>>>>>>>>${RES}"

  ### 下载代码
  #if [ ! -d $PROJECT_DIR ]; then
  #  echo -e "${BLUE_COLOR}[PO]>>>>>>>>>>>>>>>>>      Download Code From Git : >$PROJECT_GIT< ${RES}"
  #  cd $CI_HOME_DIR
  #  git clone $PROJECT_GIT
  #fi
  #echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>       Code Downloaded ${RES}"

  echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>     Install Down ${RES}"
  echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>     New You Can Build The Project ${RES}"
  echo -e "${GREEN_COLOR}[OK]>>>>>>>>>>>>>>>>>     $ ci build ${RES}"
  return 0
}

# 配置设置
function ciConfig {
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
  rm -f $CI_CONF_FILE
  echo "TOMCAT_HOME=$TOMCAT_HOME_DIR" > $CI_CONF_FILE
  echo "TOMCAT_PORT=$TOMCAT_PORT" >> $CI_CONF_FILE
  return 0
}

# 清空ci工作区的所有文件，慎用
function ciClean {
  if [ ! -d $CI_HOME_DIR ]; then
    #该目录已经不存在
    echo -e "${PINK}目录 : $CI_HOME_DIR 已不存在,无需删除~ ${RES}"
    return 22
  fi
  echo -e "${PINK}确认要清除CI目录[$CI_HOME_DIR]么?${RES}"
  read -p "[y/n]:" isYN
  if [ $isYN = "y" ]; then
    rm -rf $CI_HOME_DIR
  else
    echo "Bye"
    return 21
  fi
  return 0
}

# 清楚ci工作区的 target & log目录
function ciClear {
  echo -e "${PINK}确认要清除CI目录的日志和目标文件么?${RES}"
  read -p "[y/n]:" isYN
  if [ $isYN = "y" ]; then
    rm -rf $CI_HOME_DIR/log/*
    rm -rf $CI_HOME_DIR/target/*
  else
    echo "Bye"
    return 31
  fi
  return 0
}

# 构建项目
function ciBuild {
  echo -e "${BLUE_COLOR}[GO]>>>>>>      CLEAN${RES}"
  # 清空target目录下的文件
  rm -rf $PROJECT_TARGET_DIR/*
  if [ -f $CI_TARGET_DIR/api_deploy.war ]; then
    rm -f $CI_TARGET_DIR/api_deploy.war
  fi
  echo -e "${GREEN_COLOR}[OK]>>>>>>     CLEAN DONE${RES}"
  #下拉代码
  cd $PROJECT_DIR
  echo -e "${BLUE_COLOR}[GO]>>>>>>      PULL THE MASTER BRANCH CODE      ${RES}"
  git pull origin master
  echo -e "${GREEN_COLOR}[OK]>>>>>>     PULL DONE     ${RES}"

  echo -e "${BLUE_COLOR}[GO]>>>>>>      BUILD THE SOURCE      ${RES}"
  #编译代码
  cd $PROJECT_SOURCE_DIR
  $MAVEN_DIR/bin/mvn package > $CI_LOG_DIR/MAVEN_PACKAGE_$PROJECT_TARGET_VERSION_CODE.log
  echo -e "${GREEN_COLOR}[OK]>>>>>> BUILD DONE           ${RES}"
  #ls -l $API_TARGET_DIR
  echo -e "${BLUE_COLOR}[GO]>>>>>> Copy to target dir     ${RES}"
  # 这里需要替换成相应的tomcat的目录
  cp $PROJECT_TARGET_DIR/api.war $CI_TARGET_DIR/api_$PROJECT_TARGET_VERSION_CODE.war
  cp $PROJECT_TARGET_DIR/api.war $CI_TARGET_DIR/api_deploy.war
  echo -e "${GREEN_COLOR}[OK]>>>>>> Target Version : $PROJECT_TARGET_VERSION_CODE"
  echo -e "${GREEN_COLOR}[OK]>>>>>> You Need TO Deploy       ${RES}"
  echo -e "${GREEN_COLOR}[OK]>>>>>> Like: $ ./ci.sh deploy       ${RES}"

  return 0
}

# 复制工程并重启tomcat
function ciRestart {
  if [ -z $1 ]; then
    target_war="$CI_TARGET_DIR/api_deploy.war"
  fi
  echo "target_war  $target_war"
  if [ ! -f $target_war ]; then
    echo -e "${PINK}[ERROR]>>>>>> Cant Find The TargetWar File~ You Need Run The Next Command:        ${RES}"
    echo -e "${GREEN_COLOR}[OK]>>>>>> $ ./ci.sh build       ${RES}"
    return 52
  fi

  echo -e "${BLUE_COLOR}[GO]>>>>>> SHUTDOWN TOMCAT          ${RES}"
  $TOMCAT_HOME_DIR/bin/shutdown.sh
  # 有时候会关闭掉，导致重启不了
  # 使用lsof强制进行关闭
  kill -9 `lsof -t -i:$TOMCAT_PORT`
  echo -e "${GREEN_COLOR}[OK]>>>>>>  Shutdown ok          ${RES}"

  cp $target_war $TOMCAT_DEPLOY_DIR/api.war

  $TOMCAT_HOME_DIR/bin/startup.sh

  if [ ! -f $TOMCAT_DEPLOY_DIR/api.war ]; then
    echo -e "${PINK}[ERROR]>>>>>> API  deploy failed~ plz run again        ${RES}"
    return 51
  else
    echo -e "${GREEN_COLOR}[OK]>>>>>> Success~ Deploy Finished~          ${RES}"
  fi
  return 0
}

# 手动部署项目
function ciDeploy {
  target_war="$CI_TARGET_DIR/api_deploy.war"
  if [ ! -z $1 ]; then
    echo $1
    target_war="$CI_TARGET_DIR/api_$1.war"
  fi
  echo $target_war
  echo -e "${GREEN_COLOR}[GO]>>>>>> Deploy          ${RES}"
  echo -e "${GREEN_COLOR}[GO]>>>>>>  The Tomcat Var Is:          ${RES}"
  echo -e "${GREEN_COLOR}[OK]>>>>>>  TOMCAT_HOME_DIR At $TOMCAT_HOME_DIR ${RES}"
  echo -e "${GREEN_COLOR}[OK]>>>>>>  TOMCAT_PORT     At $TOMCAT_PORT ${RES}"
  echo -e "${GREEN_COLOR}[OK]>>>>>>  TOMCAT_DEPLOY_DIR     At $TOMCAT_DEPLOY_DIR ${RES}"
  echo -e "${GREEN_COLOR}[OK]>>>>>>  是否使用当前环境变量进行发布?${RES}"
  read -p "[y/n]:" isYN
  if [ ! $isYN = "y" ]; then
    echo -e "${GREEN_COLOR}[OK]>>>>>>  请输入 $ ci.sh conf 重新配置tomcat的目录${RES}"
    return 41
  fi

  ciRestart $target_war

  return $?
}

# 自动部署项目
function ciPublish {
  ciRestart
  return $?
}

function ciRequireCommand {
  echo -e "${GREEN_COLOR}[GO]>>>>>>  您输入的参数错误，可选的参数如下：         ${RES}"
  echo -e "${GREEN_COLOR}[GO]>>>>>>  ci install  : 安装ci目录，maven，下载git代码          ${RES}"
  echo -e "${GREEN_COLOR}[GO]>>>>>>  ci build  ：编译git仓库中最新的代码 ${RES}"
  echo -e "${GREEN_COLOR}[GO]>>>>>>  ci deploy ：将代码发布到servlet容器中并重启该容器 ${RES}"
  echo -e "${GREEN_COLOR}[GO]>>>>>>  ci conf ：设置servlet容器的目录和端口 ${RES}"
}
echo -e "${BLUE_COLOR}[GO]>>>>>>>>>>>> Command:[$1]>>>>>>>>>>>>>>${RES}"

#没有值
if [ -z $1 ]; then
  ciRequireCommand
  exit
## 安装流程
elif [ $1 = "install" ]; then

  ciInstall

elif [ $1 = "conf" ]; then

  ciConfig
  if [ $? > 0 ]; then
    exit
  fi

elif [ $1 = "clean" ]; then
  ciClean
  if [ $? > 0 ]; then
    exit
  fi

elif [ $1 = "clear" ]; then
  ciClear
  if [ $? > 0 ]; then
    exit
  fi
elif [ $1 = "build" ]; then
  ciBuild
elif [ $1 = "deploy" ]; then
  ciDeploy $2
elif [ $1 = "publish" ]; then
  ciPublish
  if [ $? > 0 ]; then
    exit
  fi
else
  ciRequireCommand
  exit
fi #end if
