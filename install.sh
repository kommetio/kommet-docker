#! /bin/bash

KM_WAR_PATH=$1
KM_DB_PWD=$2
KM_APP_NAME=$3

# import variable from external config file
export $(cat .kmenv | xargs)

# create directory if not exists
if [[ ! -d "volumes/bin" ]]; then
	mkdir volumes/bin
else
	echo "Directory volumes/bin already exists. Stopping installation"
	exit -1
fi

# make sure the database volume is empty (db not initialized)
if [ "$(ls -A volumes/db/data)" ]; then
	echo "Database volume directory is not empty. Stopping installation."
	exit -1
fi

cp $KM_WAR_PATH volumes/bin/

# export db password as environment variable
export KM_DB_PWD="$KM_DB_PWD"

export KM_APP_NAME="$KM_APP_NAME"

volume_dir="$(pwd)/volumes"

echo "Volume directory: $volume_dir"

echo "Building images"
KM_VOLUME=$volume_dir KM_DB_PWD=${KM_DB_PWD} KM_APP_NAME=${KM_APP_NAME} KM_TOMCAT_PORT=${KM_TOMCAT_PORT} KM_HTTPD_PORT=${KM_HTTPD_PORT} KM_DB_PORT=${KM_DB_PORT} docker-compose build

echo "Running containers"
KM_VOLUME=$volume_dir KM_DB_PWD=${KM_DB_PWD} KM_APP_NAME=${KM_APP_NAME} KM_TOMCAT_PORT=${KM_TOMCAT_PORT} KM_HTTPD_PORT=${KM_HTTPD_PORT} KM_DB_PORT=${KM_DB_PORT} docker-compose up -d

echo "Initializing database"
chmod 777 $(pwd)/scripts/init-new-env.sh
$(pwd)/scripts/init-new-env.sh ${KM_DB_PWD} "$ENV_ID" ${KM_APP_NAME}

# set database password in tomcat container
docker exec $KM_APP_NAME-tomcat bash -c "export KM_DB_PWD=${KM_DB_PWD}"

echo "Installation completed. The service is available at localhost:${KM_TOMCAT_PORT} and localhost:${KM_HTTPD_PORT}"
