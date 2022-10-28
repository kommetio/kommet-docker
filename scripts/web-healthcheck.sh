#! /bin/bash

# Make sure Tomcat is up
processes=$(docker exec rm-tomcat ps ax | grep "tomcat")

if [[ ! "$processes" =~ ^.*tomcat.*$ ]]; then
	echo "Tomcat is not up"
	exit -1
fi

# Make sure Apache is up
processes=$(docker exec rm-httpd ps ax | grep "apache2")

if [[ ! "$processes" =~ ^.*apache2.*$ ]]; then
	echo "Apache2 server is not up"
	exit -1
fi

# make sure Apache2 is exposed at port 8001
localhost_resp=$(curl -i -s localhost:8001 | head -n 5)
regex="^.*HTTP\/1.1[[:space:]]*200.*$"
if [[ ! "$localhost_resp" =~ $regex ]]; then
	echo "Apache2 server is not responding outside of container at localhost:8001"
	echo "$localhost_resp"
	exit -1
fi
