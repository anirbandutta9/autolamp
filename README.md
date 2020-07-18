## Automatically install and setup LAMP on Ubuntu Server

This script can be used on blank ubuntu VPS/Dedivated server. This script can automatically install and setup the following :

```
1) Apache Webserver 
2) Mariadb Database Server
3) PHP
4) PhpMyAdmin 
5) Let'sEncrypt SSL for website
```

## Installation Requirements :

```
1) Blank Ubuntu VPS/Dedicated server 
2) Root SSH access to server
3) Supported ubuntu versions:  16.04 LTS, 18.04 LTS, 20.04 LTS
```

## Installation Procedure :

#### 1. SSH to your server as root user:

#### 2. Download the script:
```
sudo wget https://raw.githubusercontent.com/anirbandutta9/autolamp/master/install_lamp.sh
```
#### 3. Set the parameters inside the script as you wish.
Set this to False if you don't need to install apache webserver  
``` INSTALL_APACHE="True" ```   
Set this to False if you don't need to install PHP  
``` INSTALL_PHP="True" ```  
Set this to False if you don't need to install any database server  
``` INSTALL_MYSQL="True" ```  
SET this to True if you need to create a database   
``` CREATE_DATABASE="False" ```  
Set the database name and user you want to create  
``` DATABASE_NAME="lampdb" ```  
``` DATABASE_USER="lampdbuser" ```  
Set admin email for issuing SSL  
``` ADMIN_EMAIL="admin@example.com" ```  
Set this to True if you need to secure PhpMyAdmin installation  
``` SECURE_PHPMYADMIN="False" ```  


#### 4. Make the script executable
```
sudo chmod +x install_lamp.sh
```

#### 5. Execute the script:
```
sudo ./install_lamp.sh
```

### If this project reduced your time and effort to setup, feel free to give me a cup of coffee :)  
https://www.anirbandutta.in/pay/   


