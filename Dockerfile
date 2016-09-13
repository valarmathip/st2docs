FROM centos:centos6
MAINTAINER valarmathi

ENV user=appadmin
ENV  build=p2a-ui-1.0.0.964-b619(20160802130400)_app.zip

RUN yum install -y unzip httpd

####### SALT-MINION
RUN rpm -Uvh http://ftp.linux.ncsu.edu/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum install -y salt-minion --enablerepo=epel-testing
RUN [ ! -d /etc/salt/minion.d ] && mkdir /etc/salt/minion.d
RUN sed -i '16 a master: 10.0.0.251' /etc/salt/minion
RUN echo "docker-minion-ui" >> /etc/salt/minion_id

RUN groupadd $user
RUN useradd -g $user $user

####APACHE####

ADD httpd.conf /etc/httpd/conf/httpd.conf
RUN chown -Rf root.root /etc/httpd/conf/httpd.conf
RUN chmod -R 644 /etc/httpd/conf/httpd.conf

RUN mkdir /home/version/ 
RUN echo "Test version v_1" > /home/version/version.txt
RUN mkdir -p /var/www/html/app
RUN chown -Rf appadmin.appadmin /var/www/html/app
RUN chmod -R 755 /var/www/html/app

COPY deploy.sh /home/appadmin/
RUN chown -Rf appadmin.appadmin /home/appadmin/deploy.sh
RUN chmod -R 755 /home/appadmin/deploy.sh

RUN mkdir -p /home/appadmin/build_temp
RUN chown -Rf appadmin.appadmin /home/appadmin/build_temp
RUN chmod -R 777 /home/appadmin/build_temp

RUN mkdir -p /home/appadmin/config
RUN chown -Rf appadmin.appadmin /home/appadmin/config
RUN chmod -R 755 /home/appadmin/config


COPY env.html /home/appadmin/config/
RUN chown -Rf appadmin.appadmin /home/appadmin/config/env.html
RUN chmod -R 644 /home/appadmin/config/env.html

EXPOSE 80

# Add startup file
ADD ./launch.sh /bin/launch.sh
RUN chmod +x /bin/launch.sh

####HR UI#####
ADD $build /home/appadmin/build_temp/
RUN chown -Rf appadmin.appadmin /home/appadmin/build_temp/$build
RUN chmod -R 644 /home/appadmin/build_temp/$build


COPY idp_htaccess /var/www/html/app/idp/.htaccess
RUN chown -Rf appadmin.appadmin /var/www/html/app/idp/.htaccess
RUN chmod -R 644 /var/www/html/app/idp/.htaccess

COPY logout_htaccess /var/www/html/app/logout/.htaccess
RUN chown -Rf appadmin.appadmin /var/www/html/app/logout/.htaccess
RUN chmod -R 644 /var/www/html/app/logout/.htaccess

RUN chown -Rf appadmin.appadmin /home/appadmin/
RUN chown -Rf appadmin.appadmin /var/www/html/app
RUN chmod -R 755 /var/www/html/app
RUN chmod -R 755 /home/appadmin/
RUN su $user
WORKDIR /home/appadmin/
RUN sh deploy.sh
RUN sed -i -e 's/devinthr/devint4hr/g' -e 's/buildint/devint4/g' /var/www/html/app/idp/.htaccess
RUN sed -i 's/devinthr/devint4hr/g' /var/www/html/app/logout/.htaccess


ENTRYPOINT ["/bin/launch.sh"]