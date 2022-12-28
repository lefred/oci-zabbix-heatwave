#!/bin/bash


mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE DATABASE ${zabbix_schema} character set utf8mb4 collate utf8mb4_bin;"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE USER ${zabbix_name} identified by '${zabbix_password}';"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "GRANT ALL PRIVILEGES ON ${zabbix_schema}.* TO ${zabbix_name};"

echo "Zabbix Database and User created !"
echo "ZABBIX USER = ${zabbix_name}"
echo "ZABBIX SCHEMA = ${zabbix_schema}"

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --database zabbix --sql 

echo "DBHost=${mds_ip}" >>/etc/zabbix/zabbix_server.conf
echo "DBName=${zabbix_schema}" >>/etc/zabbix/zabbix_server.conf
echo "DBUser=${zabbix_name}" >>/etc/zabbix/zabbix_server.conf
echo "DBPassword=${zabbix_password}" >>/etc/zabbix/zabbix_server.conf
echo "DBTLSConnect=required" >>/etc/zabbix/zabbix_server.conf


echo """
<?php
// Zabbix GUI configuration file.

\$DB['TYPE']			= 'MYSQL';
\$DB['SERVER']			= '${mds_ip}';
\$DB['PORT']			= '3306';
\$DB['DATABASE']		= '${zabbix_schema}';
\$DB['USER']			= '${zabbix_name}';
\$DB['PASSWORD']		= '${zabbix_password}';

// Schema name. Used for PostgreSQL.
\$DB['SCHEMA']			= '';

// Used for TLS connection.
\$DB['ENCRYPTION']		= true;
\$DB['KEY_FILE']			= '';
\$DB['CERT_FILE']		= '';
\$DB['CA_FILE']			= '';
\$DB['VERIFY_HOST']		= false;
\$DB['CIPHER_LIST']		= '';

// Vault configuration. Used if database credentials are stored in Vault secrets manager.
\$DB['VAULT']			= '';
\$DB['VAULT_URL']		= '';
\$DB['VAULT_DB_PATH']		= '';
\$DB['VAULT_TOKEN']		= '';
\$DB['VAULT_CERT_FILE']		= '';
\$DB['VAULT_KEY_FILE']		= '';
\$DB['DOUBLE_IEEE754']		= true;

\$ZBX_SERVER_NAME		= 'zabbix';

\$IMAGE_FORMAT_DEFAULT	= IMAGE_FORMAT_PNG;
""" > /etc/zabbix/web/zabbix.conf.php

chown apache. /etc/zabbix/web/zabbix.conf.php

systemctl restart zabbix-server zabbix-agent httpd php-fpm
systemctl enable zabbix-server zabbix-agent httpd php-fpm

echo "Zabbix installed and Apache started !"

