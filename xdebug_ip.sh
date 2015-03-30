#!/bin/bash
echo -e "\n--- Configure xdegug ip ---\n"

HOST_IP=$(netstat -rn | grep "^0.0.0.0 " | tr -s ' ' | cut -d " " -f2)
sed -i "s/xdebug.remote_host=.*/xdebug.remote_host=$HOST_IP/g" /etc/php5/apache2/conf.d/20-xdebug.ini

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart > /dev/null 2>&1

