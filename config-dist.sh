#!/bin/bash

export APPS_DIR=$HOME/apps

# List supported PHP versions of supported Moodle versions (even security ones).
# - 404 and 405 support 8.1 up to 8.3.
# - 500 supports 8.2 up to 8.4.
# - 501 supports 8.2 and up.
# - 502 supports 8.3 and up.
export PHP_VERSIONS=("8.1" "8.2" "8.3" "8.4")
export DEFAULT_PHP_VERSION="8.3"
# List required PHP extensions.
export PHP_EXTS=(dev pgsql intl mysqli xml mbstring curl zip gd soap xmlrpc)

# PostgreSQL variables.
# Minimum supported PostgreSQL version by the main branch.
export PGSQL_TAG=16
# Password.
export PGSQL_PASSWD=moodle

# MariaDB variables.
# Minimum supported MariaDB version by the main branch.
export MARIADB_TAG=10.11
# Password.
export MARIADB_PASSWD=moodle
export MARIADB_PORT=3306

# MySQL variables.
# Minimum supported MySQL version by the main branch.
export MYSQLI_TAG=8.4
# Password.
export MYSQLI_PASSWD=moodle
# To use MySQL together with MariaDB, they need to run on different ports.
export MYSQLI_PORT=3307

# php-sqlsrv extension version. Check https://pecl.php.net/package/sqlsrv.
export SQLSRV_VER=5.10.1

# Oracle Instantclient URLS (v21.8)
export INSTANTCLIENT_BASIC_URL=https://download.oracle.com/otn_software/linux/instantclient/218000/instantclient-basic-linux.x64-21.8.0.0.0dbru.zip
export INSTANTCLIENT_SDK_URL=https://download.oracle.com/otn_software/linux/instantclient/218000/instantclient-sdk-linux.x64-21.8.0.0.0dbru.zip
export ORACLE_DB_TAG=21
# Change to 1 if you want to install Oracle PHP extensions and run a container via docker during setup.
export INSTALL_ORACLE=0

# Git variables. Change these variables to configure global Git variables with your details.
export GIT_EMAIL=""
export GIT_NAME=""

# Variables for MDK.
# Change this to configure MDK with your GitHub username.
export MDK_GITHUB_USER=""
# Change this to configure MDK with your Tracker username.
export MDK_TRACKER_USER=""
# Change this to set the `www` folder for MDK (`dirs.www`).
export MDK_WWW_DIR=""
# Change this to set the `moodles` folder for MDK (`dirs.storage`).
export MDK_MOODLES_DIR=""
