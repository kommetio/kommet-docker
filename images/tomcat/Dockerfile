FROM tomcat:9.0.55-jdk11-openjdk

LABEL maintainer="radek@kommet.io"

# add dir to store koll files
RUN mkdir /usr/local/tomcat/webapps/koll

# add dir to store external libs
RUN mkdir /usr/local/tomcat/webapps/lib

# add dir to store uploaded files
RUN mkdir /usr/local/tomcat/webapps/filestorage


# install psql for testing purposes only - not needed for the app to work
RUN apt-get update && apt-get install -y postgresql-client

ADD init.sh /usr/local/tomcat/bin/init.sh
RUN chmod 755 /usr/local/tomcat/bin/init.sh

EXPOSE 8080

# catalina.sh start runs in the background, so we need to keep the container running
# we could also use "catalina.sh run", but this command does not (?) redirect output to catalina.out log

CMD /usr/local/tomcat/bin/init.sh ; catalina.sh start ; tail -f /dev/null
