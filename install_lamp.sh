#!/bin/bash
################################################################################
# Script for installing LAMP on Ubuntu 16.04, 18.04 and 20.04 (could be used for other version too)
# Author: Anirban Dutta
#-------------------------------------------------------------------------------
# This script can install the following automatically on your Ubuntu server.
# 1) Apache Webserver 
# 2) Mariadb Database Server
# 3) PHP
# 4) PhpMyAdmin 
# 5) Let'sEncrypt SSL for website 
#-------------------------------------------------------------------------------
# Make a new file:
# sudo nano lamp.sh
# Place this content in it and then make the file executable:
# sudo chmod +x lamp.sh
# Execute the script to install Odoo:
# ./lamp.sh
################################################################################

# Set this to False if you don't need to install apache webserver
INSTALL_APACHE="True"
# Set this to False if you don't need to install PHP
INSTALL_PHP="True"
# Set this to False if you don't need to install any database server  
INSTALL_MYSQL="True"
# SET this to True if you need to create a database 
CREATE_DATABASE="False"
# Set the database name and user you want to create
DATABASE_NAME="lampdb"
DATABASE_USER="lampdbuser"
# Set this to True if you need to install PHPMYADMIN
INSTALL_PHPMYADMIN="False"
# Set your domain name to be mapped 
WEBSITE_NAME="example.com"
# Set this to True if you need to install Free SSL for the Website
ENABLE_SSL="False"
# Set admin email for issuing SSL
ADMIN_EMAIL="admin@example.com"
# Set this to True if you need to secure PhpMyAdmin installation
SECURE_PHPMYADMIN="False"
# Set this to True if you need to install modsecurity
INSTALL_MODSECURITY="False"
# Set this to True if you need to secure your site using .htaccess rules
SECURE_WEBSITE="False"


if [ "$(whoami)" != 'root' ]; then
        echo "Please run this script as root user only! "
		echo "Use this command to switch to root user:   sudo -i "
        exit 1;
    fi

if [ $INSTALL_APACHE != "True" ] && [ $INSTALL_MYSQL != "True" ] && [ $INSTALL_PHP != "True" ]; then
        echo "Please set some values to True for the script to run! "
        exit 1;
    fi
	
banner()
{
  echo "+-----------------------------------------------------------------------+"
  printf "| %-40s |\n" "`date`"
  echo "|                                                                       |"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+-----------------------------------------------------------------------+"
}

banner "Automatic LAMP Server Installation Started.
Please wait !!  This might take several minutes to complete !! "

sleep 7;
#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Updating Server ----"
sudo apt-get update -y

#--------------------------------------------------
# Install Apache Webserver
#--------------------------------------------------

if [ $INSTALL_APACHE = "True" ]; then
echo -e "\n---- Installing Apache Web Server ----"
apt-get install apache2 libapache2-mod-php -y
cat <<EOF > ~/$WEBSITE_NAME.conf

<VirtualHost *:80>

    ServerName $WEBSITE_NAME
    ServerAlias www.$WEBSITE_NAME

    ServerAdmin webmaster@$WEBSITE_NAME
    DocumentRoot /var/www/html/$WEBSITE_NAME

<Directory /var/www/html/$WEBSITE_NAME>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
        Require all granted
    </Directory>

</VirtualHost>

EOF

sudo mv ~/$WEBSITE_NAME.conf  /etc/apache2/sites-available/
sudo a2ensite $WEBSITE_NAME.conf
sudo a2enmod rewrite
sudo mkdir /var/www/html/$WEBSITE_NAME
echo "CONGRATULATIONS! Website is working. Remove this index.html page and put your website files" >> /var/www/html/$WEBSITE_NAME/index.html
sudo systemctl restart apache2 
else
  echo "Apache server isn't installed due to the choice of the user!"
fi


#--------------------------------------------------
# Install PHP
#--------------------------------------------------


if [ $INSTALL_PHP = "True" ]; then
echo -e "\n---- Installing PHP ----"
sudo apt-get install php php-mysql libapache2-mod-php php-redis php-cli php-cgi php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip php-curl php-imagick php-bcmath php-redis -y
else
  echo "PHP isn't installed due to the choice of the user!"
fi


#--------------------------------------------------
# Install MariaDB Server
#--------------------------------------------------


if [ $INSTALL_MYSQL = "True" ]; then
echo -e "\n---- Installing MariaDB Server ----"
sudo apt-get install mariadb-server -y
else
  echo "MariaDB server isn't installed due to the choice of the user!"
fi


#--------------------------------------------------
# Install PhpMyAdmin
#--------------------------------------------------

if [ $INSTALL_PHPMYADMIN = "True" ] && [ $INSTALL_APACHE = "True" ] && [ $INSTALL_PHP = "True" ] && [ $INSTALL_MYSQL = "True"  ]; then
echo -e "\n---- Installing PhpMyAdmin ----"
sudo apt-get install phpmyadmin -y
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin.conf
sudo systemctl restart apache2
else
  echo "PhpMyAdmin isn't installed due to the choice of the user!"
fi




#--------------------------------------------------
# Enable ssl with certbot
#--------------------------------------------------

if [ $INSTALL_APACHE = "True" ] && [ $ENABLE_SSL = "True" ] && [ $ADMIN_EMAIL != "admin@example.com" ];then
  sudo add-apt-repository ppa:certbot/certbot -y && sudo apt-get update -y
  sudo apt-get install certbot python3-certbot-apache -y
  sudo certbot --apache -d $WEBSITE_NAME --noninteractive --agree-tos --email $ADMIN_EMAIL --redirect
  sudo service apache2 reload
  echo "SSL/HTTPS is enabled!"
else
  echo "SSL/HTTPS isn't enabled due to choice of the user or because of a misconfiguration!"
fi



#--------------------------------------------------
# Create MySql database and User
#--------------------------------------------------

if [ $CREATE_DATABASE = "True" ] && [ $INSTALL_MYSQL = "True" ]; then
echo -e "\n---- Creating Database and User ----"
function generatePassword()
{
    echo "$(openssl rand -base64 12)"
}

BIN_MYSQL=$(which mysql)
DATABASE_HOST='localhost'
DATABASE_PASS=$(generatePassword)
ROOTMYSQL_PASS=" "
SQL1="CREATE DATABASE IF NOT EXISTS ${DATABASE_NAME};"
SQL2="CREATE USER '${DATABASE_USER}'@'${DATABASE_HOST}' IDENTIFIED BY '${DATABASE_PASS}';"
SQL3="GRANT ALL PRIVILEGES ON ${DATABASE_NAME}.* TO '${DATABASE_USER}'@'${DATABASE_HOST}';"
SQL4="FLUSH PRIVILEGES;"
$BIN_MYSQL -u root -e "${SQL1}${SQL2}${SQL3}${SQL4}"
cat <<EOF > ~/database.txt

   >> Host      : ${DATABASE_HOST}
   >> Port      : 3306
   >> Database  : ${DATABASE_NAME}
   >> User      : ${DATABASE_USER}
   >> Pass      : ${DATABASE_PASS}
   

EOF
echo "Successfully Created Database and User! "
else
  echo "Database isn't created due to the choice of the user!"
fi


echo "-----------------------------------------------------------"
echo "Done! Your setup is completed successfully. Specifications:"
if [ $INSTALL_APACHE = "True" ]; then
echo "Visit website: http://$WEBSITE_NAME "
echo "Document root:  /var/www/html/$WEBSITE_NAME"
echo "Apache configuration file:  /etc/apache2/sites-available/$WEBSITE_NAME.conf "
echo "Check Apache status:   systemctl status apache2"
fi
if [ $INSTALL_MYSQL = "True" ]; then
  echo "Check Mysql Status:  systemctl status mariadb"
fi
if [ $INSTALL_PHP = "True" ]; then
  echo "Check PHP version:  php -v"
fi
if [ $INSTALL_PHPMYADMIN = "True" ]; then
  echo "Access PhpMyAdmin: http://$WEBSITE_NAME/phpmyadmin"
fi
if [ $CREATE_DATABASE = "True" ]; then
    echo " Database details: "
    echo " >> Host      : ${DATABASE_HOST}"
	echo " >> Port      : 3306 "
    echo " >> Database  : ${DATABASE_NAME}"
    echo " >> User      : ${DATABASE_USER}"
    echo " >> Pass      : ${DATABASE_PASS}"
  echo "Database information saved at : /root/database.txt"
fi
echo "-----------------------------------------------------------"

