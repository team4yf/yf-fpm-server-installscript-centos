#! /bin/sh

uname -r

yum update

yum remove docker  docker-common docker-selinux docker-engine

yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum list docker-ce --showduplicates | sort -r

sudo yum install docker-ce

systemctl start docker

systemctl enable docker

docker version