#!/bin/bash

exec /sbin/init

### Configure MySQL:
# Ensure MySQL directories have correct permissions
/usr/bin/mkdir -p /var/run/mysqld
/usr/bin/chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

# Initialize and start MySQL
if [ ! -d '/var/lib/mysql/mysql' ]; then
  /usr/bin/mysqld --initialize-insecure;
fi;

# Wait for MySQL to completely start up
/usr/bin/systemctl start mysqld.service

# Wait for MySQL to fully boot up
/usr/bin/echo "Waiting for MySQL to start..."
until mysqladmin ping &>/dev/null; do
    /usr/bin/sleep 1
done

# Secure / set root password if needed (Optional: change 'secretpassword')
/usr/bin/mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'secretpassword'; FLUSH PRIVILEGES;"
