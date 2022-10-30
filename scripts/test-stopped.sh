#! /bin/bash

# returns the number of running containers + 1 (one line for headers)
running_containers=$(docker ps | wc -l | sed 's/ //g')

if [[ "$running_containers" != "1" ]]; then
	echo "Expected 0 running containers, but found $running_containers lines in output"
	exit -1
fi
