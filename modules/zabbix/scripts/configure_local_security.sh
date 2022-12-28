#!/bin/bash
#set -x

firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --zone=public --permanent --add-port=10050/tcp
firewall-cmd --zone=public --permanent --add-port=10051/tcp
firewall-cmd --reload

chcon --type httpd_sys_rw_content_t /var/www/html
chcon --type httpd_sys_rw_content_t /var/www/html/sites/*
chcon --type httpd_sys_rw_content_t /var/www/html/*
setsebool -P httpd_can_network_connect_db 1
setsebool -P zabbix_can_network 1

echo "Local Security Granted !"
