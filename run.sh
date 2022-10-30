#! /bin/bash

VOLUME_DIR="$(pwd)/volumes"

KM_DB_PWD=$1
KM_APP_NAME=$2

export $(cat .kmenv | xargs)

KM_VOLUME=$VOLUME_DIR \
	KM_DB_PWD=${KM_DB_PWD} \
	KM_APP_NAME=${KM_APP_NAME} \
	KM_TOMCAT_PORT=${KM_TOMCAT_PORT} \
	KM_HTTPD_PORT=${KM_HTTPD_PORT} \
	KM_DB_PORT=${KM_DB_PORT} \
	docker-compose up -d
