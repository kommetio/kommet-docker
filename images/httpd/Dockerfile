FROM debian:10

RUN apt-get update && apt-get install -y apache2

RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod proxy_http

# run apache in foreground
CMD ["apachectl", "-k", "start", "-DFOREGROUND"]

EXPOSE 80
