#! /bin/bash

# Make sure Tomcat is up
processes=$(docker exec km-tomcat ps ax | grep "tomcat")

if [[ ! "$processes" =~ ^.*tomcat.*$ ]]; then
	echo "Tomcat is not up"
	exit -1
fi

# make sure Tomcat is exposed at port 8000
localhost_resp=$(curl -i -s -L -v localhost:8000)

echo "CURL exit code $?"

regex="^.*HTTP\/1.1[[:space:]]*200.*$"
if [[ ! "$localhost_resp" =~ $regex ]]; then
	echo "Tomcat server is not responding outside of container at localhost:8000"
	echo "CURL output: $localhost_resp"
	exit -1
fi
