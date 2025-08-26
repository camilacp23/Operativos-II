sudo apt update -y
sudo apt upgrade -y
sudo apt install apache2
sudo mkdir /var/www/operativos
if [ -d "/var/www/operativos" ]; then
  echo "El directorio existe."
else
  sudo mkdir /var/www/operativos
fi

if [ ! -f "sudo touch /var/www/operativos/index.html" ]; then
  sudo touch /var/www/operativos/index.html
  echo "hola" > /var/www/operativos/index.html
else
  echo "El archivo ya existe."
fi

sudo cp /etc/apache2/sites-available/000-default.conf  /etc/apache2/sites-available/operativos.conf
sudo sed -i 's/html/operativos/g' /etc/apache2/sites-available/operativos.conf
sudo a2dissite 000-default.conf
sudo a2ensite operativos.conf
sudo service apache2 reload
