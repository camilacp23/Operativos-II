🔹 1. Instalar Docker y Docker Compose

sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# Verifica que funciona:

docker --version
docker-compose --version

🔹 2. Crear carpeta del proyecto

mkdir mi-proyecto-docker
cd mi-proyecto-docker

🔹 3. Crear el archivo

nano docker-compose.yml

# contenido del archivo

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


🔹 4. Crear carpeta public_html con un archivo de prueba

mkdir public_html
echo "h1>Hola desde Docker!h1>" > public_html/index.html

🔹 5. Levantar los contenedores

sudo docker-compose up -d

# Verifica que estén corriendo:

sudo docker ps

🔹 6. Probar en navegador

Abre en tu navegador:

http://localhost:8081


