#! /bin/bash

db_pwd=$1
env_id=$2

dbname="env$env_id"

# exit if any command fails
set -e

echo "Initializing database from scratch"

#if [ ! "$(whoami)" == "postgres" ]; then
#  echo "Failed to log in as postgres"
#  exit -1
#fi

echo "Creating databases and users"

# wait for postgres to be available
pg_retries=0
until [[ ("$(pg_isready)" =~ ^.*accepting.*$) || $pg_retries > 10 ]]
do
  pg_retries=$((pg_retries+1))
  echo "Waiting for postgres: attempt $pg_retries"
  sleep 2
done

function db_exists() {
  local db_list=$(su postgres -c 'psql -l')

  if [[ "$db_list" == *$1* ]]; then
    echo "Database $1 exists"
    return
  else
    echo "Database $2 does not exist"
    return
  fi
}

echo "Postgres status: $(pg_isready)"

# make sure the DBs do not exist before the init script is called
if [[ $(db_exists "$dbname") =~ ^.*exists.*$ ]]; then
  echo "Database $dbname already exists. It must not be there before init script is called."
  exit -1
fi

if [[ $(db_exists "kolmu") =~ ^.*exists.*$ ]]; then
  echo "Database kolmu already exists. It must not be there before init script is called."
  exit -1
fi

su postgres -c 'psql -a -f /home/db/scripts/init.sql'

psql -U postgres -d postgres -c "CREATE DATABASE $dbname OWNER kolmuenv ENCODING 'UTF8' TEMPLATE 'template0';"

if [[ ! $(db_exists "$dbname") =~ ^.*exists.*$ ]]; then
  echo "Database $dbname not created"
  exit -1
fi

if [[ ! $(db_exists "kolmu") =~ ^.*exists.*$ ]]; then
  echo "Database kolmu not created"
  exit -1
fi

echo "Users and databases created"

echo "Setting database user passwords: $db_pwd"

pwd_set_result=$(psql -U postgres -d postgres -c "alter user kolmuapp with password '$db_pwd';")
echo "$pwd_set_result"

pwd_set_result=$(psql -U postgres -d postgres -c "alter user kolmuenv with password '$db_pwd';")
echo "$pwd_set_result"

echo "Restoring databases from templates"

su postgres -c "PGPASSWORD=$db_pwd pg_restore -h localhost -p 5432 -U kolmuapp -d kolmu -v /home/db/dbtemplates/kolmu.backup"

echo "Verifying master database creation"

# make sure kolmu database has been properly restored by checking it contains some tables
cmd="PGPASSWORD=$db_pwd psql -d kolmu -U kolmuapp -h localhost -c 'select count(*) as size from envs'"
kolmu_tables=$(bash -c "$cmd")

if [[ ! "$kolmu_tables" =~ ^.*size.*$ ]]; then
  echo "Test query on kolmu db failed with result: $kolmu_tables"
  exit -1
fi

echo "Restoring env db"

su postgres -c "PGPASSWORD=$db_pwd pg_restore -h localhost -p 5432 -U kolmuenv -d $dbname -v /home/db/dbtemplates/newenvtemplate.backup"

# make sure the env database has been properly restored by checking it contains some tables
cmd="PGPASSWORD=$db_pwd psql -d $dbname -U kolmuenv -h localhost -c 'select count(*) as size from types'"
envdb_tables=$(bash -c "$cmd")

if [[ ! "$envdb_tables" =~ ^.*size.*$ ]]; then
  echo "Test query on env db failed with result: $envdb_tables"
  exit -1
fi
