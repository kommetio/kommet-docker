#! /bin/bash

db_pwd=$1
env_id=$2
app_name=$3

# make sure containers are running
if [ ! "$(docker ps -q -f name=$app_name-db)" ]
then
	echo "Container $app_name-db is not running"
	exit -1
fi

if [ ! "$(docker ps -q -f name=$app_name-tomcat)" ]
then
	echo "Container $app_name-tomcat is not running"
	exit -1
fi

if [ ! "$(docker ps -q -f name=$app_name-httpd)" ]
then
	echo "Container $app_name-httpd is not running"
	exit -1
fi

echo "Changing permissions for init.sh script"

docker exec $app_name-db chmod 777 /home/db/scripts/init.sh

echo "Inside pwd: $db_pwd"

# run initialization script
echo "Running init script"
docker exec $app_name-db /home/db/scripts/init.sh $db_pwd $env_id

init_result=$?

if [ $init_result != 0 ]; then
	echo "DB init failed"
	exit -1
fi

echo "Initialization completed"
