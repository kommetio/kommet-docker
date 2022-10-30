#! /bin/bash

if [ -f /usr/local/tomcat/bin/setenv.sh ]; then
	echo "setenv.sh found"
	chmod 755 /usr/local/tomcat/bin/setenv.sh
else
	echo "setenv.sh not found"
fi
