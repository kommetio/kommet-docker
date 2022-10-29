#! /bin/bash

DB_PWD=$1
IMAGE_NAME_TAGS=$2
ENV_ID="0010000000002"

mkdir tomcat || true

# copy tomcat script
cp ../tomcat/init.sh tomcat

mkdir db || true

# copy database scripts and templates
cp -rf ../../volumes/db/* db/

docker build --no-cache --progress=plain --build-arg dbpwd=$DB_PWD --build-arg envid=$ENV_ID -t $IMAGE_NAME_TAGS .
