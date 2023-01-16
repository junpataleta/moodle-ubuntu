#!/bin/bash

source "$(pwd)/config.sh"

# Download Microsoft's key.
sudo wget https://packages.microsoft.com/keys/microsoft.asc -O /usr/share/keyrings/microsoft.asc

# Update sources.list.d entry.
echo "deb [arch=amd64,armhf,arm64 signed-by=/usr/share/keyrings/microsoft.asc] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null

sudo apt update
# For bcp and sqlcmd.
sudo ACCEPT_EULA=Y apt install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
sudo apt install -y unixodbc-dev

# Install php-sqlsrv extension for all supported versions.
cd $APPS_DIR
for phpver in "${PHP_VERSIONS[@]}"
do
    ~/apps/switchphp.sh $phpver

    # sudo pecl install sqlsrv
    if [ ! -f "$APPS_DIR/sqlsrv-$SQLSRV_VER.tgz" ]; then
        wget https://pecl.php.net/get/sqlsrv-$SQLSRV_VER.tgz
    fi
    if [ ! -d "$APPS_DIR/sqlsrv-$SQLSRV_VER" ]; then
        tar -xzf sqlsrv-$SQLSRV_VER.tgz
    fi
    cd $APPS_DIR/sqlsrv-$SQLSRV_VER
    phpize
    ./configure
    sudo make install -B
    sudo bash -c "echo 'extension=sqlsrv.so' > /etc/php/$phpver/mods-available/sqlsrv.ini"
    sudo phpenmod -v $phpver sqlsrv
done
# Tidy up.
rm $APPS_DIR/sqlsrv-$SQLSRV_VER.tgz

# Install SQL Server via docker.
SQLSRV_PASSWD=Moodl3P@ssw0rd
docker run --name sqlsrv -e 'ACCEPT_EULA=Y' -e "SA_PASSWORD=$SQLSRV_PASSWD" -p 1433:1433 -d moodlehq/moodle-db-mssql

~/apps/switchphp.sh $DEFAULT_PHP_VERSION
