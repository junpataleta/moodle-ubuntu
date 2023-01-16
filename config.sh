#!/bin/bash

# List supported PHP versions of supported Moodle versions (even security ones).
# - 39 supports 7.3.
# - 311 supports min 7.3 up to 8.0.
# - 400 supports min 7.4 up to 8.0.
# - 401 supports 7.4 up to 8.1
# - 402 will support 8.0 and up
export PHP_VERSIONS=("8.0" "7.3" "7.4" "8.1")
export DEFAULT_PHP_VERSION="8.0"
# List required PHP extensions.
export PHP_EXTS=(dev pgsql intl mysqli xml mbstring curl zip gd soap xmlrpc)

# Oracle Instantclient URLS (v21.8)
export INSTANTCLIENT_BASIC_URL=https://download.oracle.com/otn_software/linux/instantclient/218000/instantclient-basic-linux.x64-21.8.0.0.0dbru.zip
export INSTANTCLIENT_SDK_URL=https://download.oracle.com/otn_software/linux/instantclient/218000/instantclient-sdk-linux.x64-21.8.0.0.0dbru.zip
export ORACLE_DB_TAG=21
# Change to 1 if you want to install Oracle via docker during setup.
export INSTALL_ORACLE=0
