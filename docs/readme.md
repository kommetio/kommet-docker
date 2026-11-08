#  Kommet Docker image

## Running the app as a container
Use the following Bash command assuming `kmt-langs` is the name of the new app, `8020` is the port we want to run on:
```
docker run -d --name kmt-langs -p 8020:8080 -v kmt-langs-db:/var/lib/postgresql -v kmt-langs-files:/usr/local/tomcat/webapps/filestorage -v kmt-langs-lib:/usr/local/tomcat/webapps/lib -t kommet/kommet
```

This will create three Docker volumes:
* `kmt-langs-db` as storage for Postgresql database
* `kmt-langs-lib` for Java libraries
* `kmt-langs-files` for file storage

You can also use other images instead of `kommet/kommet`, e.g. `kommet/kommet:latest`.