#! /bin/bash

hash=$1

# wait for postgres to be up
pg_retries=0
until [[ ("$(pg_isready)" =~ ^.*accepting.*$) || $pg_retries > 20 ]]
do
  pg_retries=$((pg_retries+1))
  echo "Waiting for postgres: attempt $pg_retries"
  sleep 2
done

psql -U postgres -d env0010000000002 -c "UPDATE obj_004 SET _triggerflag = 'UPDATEROOTPWD', isactive = false, activationhash = '$hash' where username = 'root'";

echo $hash
