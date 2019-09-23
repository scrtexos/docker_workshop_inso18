#!/bin/bash

if [ ! -f /.root_pw_set ]; then
    /set_root_pw.sh
fi
cd /app/ && git pull
cp /root/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /tmp/phantomjs
ln -s /tmp/phantomjs /usr/bin/phantomjs
find /app/ -name db -exec rm {}/.htdb.db \;
find /app/ -name db -exec chown -R www-data:www-data {} \;
/usr/sbin/sshd
/etc/init.d/mysql start
mysql -uroot -e "CREATE DATABASE twittbook;"
mysql -uroot twittbook < /var/www/html/twittbook/install.sql
exec supervisord -n
