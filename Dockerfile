FROM ubuntu:trusty
MAINTAINER clz

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install supervisor git apache2 libapache2-mod-php5 pwgen imagemagick sqlite3 openssh-server

RUN apt-get -y install php5-sqlite

#RUN apt-get -y install phantomjs
ADD phantomjs-2.1.1-linux-x86_64.tar.bz2 /root/

#Install ssh
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Add image configuration and scripts
ADD set_root_pw.sh /set_root_pw.sh
ADD start-apache2.sh /start-apache2.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir -p /app
RUN echo 1
RUN git clone https://github.com/scrtexos/workshop-inso18.git /app
RUN rm -rf /var/www/html && ln -s /app /var/www/html
RUN find /app/ -name db -exec chown -R www-data:www-data {} \;

RUN apt-get -y install php5-mcrypt
RUN php5enmod mcrypt

RUN apt-get update && apt-get install -y php5-xsl
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y mysql-server-5.6
RUN apt-get install -y php5-mysql php5-curl

RUN echo "allow_url_include = On" >> /etc/php5/apache2/php.ini

EXPOSE 80 22
CMD ["/run.sh"]
