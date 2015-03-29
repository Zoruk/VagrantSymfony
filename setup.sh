#! /usr/bin/env bash
 
# Variables
APPENV=local
DBHOST=localhost
DBNAME=symfony
DBUSER=symfony
DBPASSWD=PASSWORD

# Symfony settings
SF_VERSION="2.6.*"
SF_SECRET=ThisTokenIsNotSoSecretChangeIt
 
echo -e "\n--- Mkay, installing now... ---\n"

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update
 
#echo -e "\n--- Updating debian ---\n"
#apt-get -y upgrade > /dev/null 2>&1

echo -e "\n--- Install base packages ---\n"
apt-get -y install vim htop curl build-essential python-software-properties git > /dev/null 2>&1
 
echo -e "\n--- Install MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
apt-get -y install mysql-server-5.5 phpmyadmin > /dev/null 2>&1
 
echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"
 
echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql php-apc php5-xdebug > /dev/null 2>&1
 
echo -e "\n--- Enabling mod-rewrite ---\n"
a2enmod rewrite > /dev/null 2>&1
 
echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
 
echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
 
echo -e "\n--- Configure Apache to use phpmyadmin ---\n"
echo -e "\n\nListen 85\n" >> /etc/apache2/ports.conf
cat > /etc/apache2/sites-available/phpmyadmin << "EOF"
<VirtualHost *:85>
    ServerAdmin webmaster@localhost
    DocumentRoot /usr/share/phpmyadmin
    DirectoryIndex index.php
    ErrorLog ${APACHE_LOG_DIR}/phpmyadmin-error.log
    CustomLog ${APACHE_LOG_DIR}/phpmyadmin-access.log combined
</VirtualHost>
EOF
a2ensite phpmyadmin > /dev/null 2>&1
 
echo -e "\n--- Configuring apache default site ---\n"
cat > /etc/apache2/sites-available/default <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

	<Directory /vagrant/symfony>
        AllowOverride all
	</Directory>
</VirtualHost>
<VirtualHost *:80>
        ServerAdmin webmaster@localhost

        DocumentRoot /var/www
        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
        <Directory /var/www/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined
        SetEnv APP_ENV $APPENV
        SetEnv DB_HOST $DBHOST
        SetEnv DB_NAME $DBNAME
        SetEnv DB_USER $DBUSER
        SetEnv DB_PASS $DBPASSWD
</VirtualHost>
EOF

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart > /dev/null 2>&1
 
echo -e "\n--- Installing Composer for PHP package management ---\n"
curl --silent https://getcomposer.org/installer | php > /dev/null 2>&1
mv composer.phar /usr/local/bin/composer
 
if [ ! -d /vagrant/symfony ]; then 
  echo -e "\n--- Initialise Symfony project ---\n"
  sudo -u vagrant -H sh -c "echo -e 'y\n' | composer create-project symfony/framework-standard-edition /vagrant/symfony/ $SF_VERSION" > /dev/null 2>&1
fi

echo -e "\n--- Configuring Symfony ---\n"
sudo -u vagrant -H sh -c "cp /vagrant/symfony/app/config/parameters.yml.dist /vagrant/symfony/app/config/parameters.yml"
sudo -u vagrant -H sh -c "sed -i \"s/database_host: .*/database_host: $DBHOST/\" /vagrant/symfony/app/config/parameters.yml"
sudo -u vagrant -H sh -c "sed -i \"s/database_port: .*/database_port: 3306/\" /vagrant/symfony/app/config/parameters.yml"
sudo -u vagrant -H sh -c "sed -i \"s/database_name: .*/database_name: $DBNAME/\" /vagrant/symfony/app/config/parameters.yml"
sudo -u vagrant -H sh -c "sed -i \"s/database_user: .*/database_user: $DBUSER/\" /vagrant/symfony/app/config/parameters.yml"
sudo -u vagrant -H sh -c "sed -i \"s/database_password: .*/database_password: $DBPASSWD/\" /vagrant/symfony/app/config/parameters.yml"
sudo -u vagrant -H sh -c "sed -i \"s/secret: .*/secret: $SF_SECRET/\" /vagrant/symfony/app/config/parameters.yml"

echo -e "\n--- Updating Symfony ---\n"
sudo -u vagrant -H sh -c "cd /vagrant/symfony && composer update" > /dev/null 2>&1

echo -e "\n--- Setting apache document root to symfony web directory ---\n"
rm -rf /var/www
ln -fs /vagrant/symfony/web /var/www

echo -e "\n--- Add environment variables locally for artisan ---\n"
cat >> /home/vagrant/.bashrc <<EOF
# Set envvars
export APP_ENV=$APPENV
export DB_HOST=$DBHOST
export DB_NAME=$DBNAME
export DB_USER=$DBUSER
export DB_PASS=$DBPASSWD

#Alias
lsa="ls -lah"
EOF
