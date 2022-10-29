FROM tomcat:9.0.55-jdk11-openjdk

LABEL maintainer="radek@raimme.com"

RUN apt-get update && apt-get install -y sudo

# add dir to store koll files
RUN mkdir /usr/local/tomcat/webapps/koll

# add dir to store external libs
RUN mkdir /usr/local/tomcat/webapps/lib

# add dir to store uploaded files
RUN mkdir /usr/local/tomcat/webapps/filestorage

# add platform war
ADD km-1.0.war /usr/local/tomcat/webapps/ROOT.war

ADD tomcat/init.sh /usr/local/tomcat/bin/init.sh
RUN chmod 755 /usr/local/tomcat/bin/init.sh

EXPOSE 8080

#####################################################################################
# postgresql
#####################################################################################

ARG dbpwd
ARG envid

# Create the file repository configuration:
#RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
#RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# install psql for testing purposes only - not needed for the app to work
RUN apt-get update && apt-get install -y postgresql-13

ADD db/scripts /home/db/scripts
ADD db/dbtemplates /home/db/dbtemplates

# enable peer auth for user postgres
RUN sed -i -E 's/postgres(\s+)peer/postgres\1trust/' /etc/postgresql/13/main/pg_hba.conf

RUN chmod 755 /home/db/scripts/init.sh
# run database initialization - the postgresql start command has to be chained with the script execution
# otherwise psql stops before the script is called
RUN /etc/init.d/postgresql start && /home/db/scripts/init.sh $dbpwd $envid

# set database password to be used in running container
ENV KM_DB_PWD=$dbpwd
ENV KM_ENVDB_PORT=5432
ENV KM_ENVDB_HOST=localhost
ENV KM_DEFAULT_ENV_ID=$envid
ENV KM_FILE_DIR=/usr/local/tomcat/webapps/filestorage
ENV KM_ROOTDIR=/usr/local/tomcat/webapps/ROOT
ENV KM_KOLLDIR=/usr/local/tomcat/webapps/koll
ENV KM_LIB_DIR=/usr/local/tomcat/webapps/lib

#####################################################################################
# apache2
#####################################################################################

RUN apt-get update && apt-get install -y apache2

RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod proxy_http

EXPOSE 80

#####################################################################################

# catalina.sh start runs in the background, so we need to keep the container running
# we could also use "catalina.sh run", but this command does not (?) redirect output to catalina.out log

# hint - it seems that the DFOREGROUND process has to be defined as last in the command chain below, otherwise processes that come later are not executed (?)
CMD /usr/local/tomcat/bin/init.sh ; catalina.sh start ; service postgresql start ; apachectl -k start -DFOREGROUND ; tail -f /dev/null
