FROM rockylinux/rockylinux:9-ubi-init
ENV container=docker

RUN <<EOF
dnf -y update
dnf install -y epel-release dnf-plugins-core
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm
dnf module reset php -y
dnf module enable php:remi-8.4 -y
dnf -y install httpd
dnf -y install mysql-server
dnf -y install php php-cli php-mysqlnd php-zip php-gd php-mcrypt php-mbstring php-xml php-json
#dnf -y install mod_ssl
dnf -y install procps-ng
dnf clean all
EOF

### Configure php-fpm:
# modify /etc/php-fpm.d/www.conf
RUN /usr/bin/sed -i 's/listen.acl_users = apache,nginx/;listen.acl_users = apache,nginx/g' /etc/php-fpm.d/www.conf
RUN /usr/bin/sed -i 's/;listen.owner = nobody/listen.owner = apache/g' /etc/php-fpm.d/www.conf
RUN /usr/bin/sed -i 's/;listen.group = nobody/listen.group = apache/g' /etc/php-fpm.d/www.conf
RUN /usr/bin/sed -i 's/;listen.mode = 0660/listen.mode = 0600/g' /etc/php-fpm.d/www.conf
RUN /usr/bin/systemctl enable php-fpm.service

### Configure MySQL:
# Ensure MySQL directories have correct permissions
RUN /usr/bin/mkdir -p /var/run/mysqld
RUN /usr/bin/chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

# Initialize MySQL
RUN if [ ! -d '/var/lib/mysql/mysql' ]; then \
       /usr/bin/mysqld --initialize-insecure; \
    fi

# Enable mysqld.service
RUN /usr/bin/systemctl enable mysqld.service

# Wait for MySQL to fully boot up
RUN /usr/bin/echo "Waiting for MySQL to start..."
RUN until mysqladmin ping &>/dev/null; do \
      /usr/bin/sleep 1; \
    done

# Secure / set root password if needed (Optional: change 'secretpassword')
RUN /usr/bin/mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'secretpassword'; FLUSH PRIVILEGES;"


### Configure Apache:
# Start Apache HTTPD in the foreground
RUN /usr/bin/echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf
RUN /usr/bin/systemctl enable httpd.service


# Expose HTTP port
EXPOSE 80 443 3306

COPY index.php /var/www/html

VOLUME /sys/fs/cgroup
VOLUME /var/www/html
VOLUME /var/log/httpd
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /etc/apache2

# Systemd handles PID 1 inside the container
CMD ["/sbin/init"]
