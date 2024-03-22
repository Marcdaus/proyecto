# Por ahora utilizamos la esta imagen que inclueye apache y php
FROM php:7.4-apache
# instalamos los paquetes necesarios para que se entiendan entre si 
RUN apt-get update
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli 
# Exponemos el puerto 80 
EXPOSE 80
