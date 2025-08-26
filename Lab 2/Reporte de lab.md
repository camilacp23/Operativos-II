Reporte Laboratorio #2 - Contenedores
Universidad Latina de Costa Rica
BIT-28 Sistemas Operativos II

Objetivos
- Comprender qué son los contenedores.
- Identificar las diferencias entre Docker y LXD.
- Instalar y administrar contenedores con Docker.
- Utilizar Portainer como interfaz gráfica de Docker.

Marco teórico
Los contenedores son una tecnología de virtualización ligera que permite ejecutar aplicaciones aisladas en un mismo sistema operativo, compartiendo el kernel pero manteniendo independencia a nivel de procesos y sistema de archivos. A diferencia de las máquinas virtuales, los contenedores no requieren un hipervisor completo ni asignación fija de recursos, lo que los hace más eficientes.

Docker es la plataforma de contenedores más popular, diseñada para ejecutar aplicaciones en múltiples entornos (Linux, Windows, macOS). Permite empaquetar aplicaciones junto con sus dependencias en imágenes reutilizables.

LXD, basado en LXC, está más orientado a entornos Linux y se asemeja más a máquinas virtuales ligeras. Mientras que Docker se centra en contenedores de aplicaciones, LXD ofrece contenedores de sistema que emulan un sistema operativo completo.
Procedimiento


###################################################################

1. Instalación de Docker en Ubuntu
Se siguieron los pasos oficiales desde la documentación de Docker:
https://docs.docker.com/engine/install/ubuntu/

###################################################################

2. Creación de red Docker
docker network create misitio-net

###################################################################
3. Creación de contenedor MySQL/MariaDB
docker run -d --name mysql11 \
--network misitio-net \
-e MYSQL_ROOT_PASSWORD=carlos.123 \
-e MYSQL_USER=carlos \
-e MYSQL_PASSWORD=carlos.123 \
-e MYSQL_DATABASE=misitiodb \
-v websitedbvolume:/var/lib/mysql \
mariadb:latest
##################################################################


4. Creación de contenedor servidor web

mkdir public_html

docker run -d --name sitio \
--network misitio-net \
-v $(pwd)/public_html:/var/www/html \
-p 8080:80 \
php:apache
5. Uso de Docker Compose
Archivo docker-compose.yml:

version: '3'

services:
  sitio:
    image: php:apache
    container_name: sitio
    ports:
      - 8081:80
    volumes:
      - ./public_html:/var/www/html
    networks:
      - misitio-net

  misitiodb:
    image: mariadb:latest
    container_name: misitiodb
    volumes:
      - websitedbvolume:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: "carlos.123"
      MYSQL_USER: 'carlos'
      MYSQL_PASSWORD: 'carlos.123'
      MYSQL_DATABASE: misitiodb
    networks:
      - misitio-net

networks:
  misitio-net:

volumes:
  websitedbvolume:

#########################################


6. Creación de una imagen personalizada
Archivo Dockerfile:

FROM php:8.1-apache
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libicu-dev \
        libxml2-dev \
        vim \
        wget \
        unzip \
    && docker-php-ext-install -j$(nproc) iconv intl opcache \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql exif gettext mysqli

docker build -t miprimeraimagen:v1 .



#################################################################


Conclusiones
En este laboratorio se comprendió el funcionamiento de los contenedores como alternativa a la virtualización tradicional. Se realizaron pruebas de creación de contenedores individuales y orquestados mediante Docker Compose. También se exploró la creación de imágenes personalizadas mediante Dockerfile. Docker se presenta como una herramienta flexible, portable y eficiente para el despliegue de aplicaciones.