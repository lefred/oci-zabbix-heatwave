#!/bin/bash
#set -x

rpm -Uvh https://repo.zabbix.com/zabbix/6.2/rhel/8/x86_64/zabbix-release-6.2-3.el8.noarch.rpm
dnf clean all -y
dnf module switch-to php:7.4 -y
dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent 
dnf install -y mysql-shell
dnf install -y mariadb-connector-odbc mysql-connector-odbc unixODBC unixODBC-devel
