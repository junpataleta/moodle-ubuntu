#!/bin/bash

source "$(pwd)/config.sh"

cd ~/Downloads

# Download Oracle Instantclient Basic package.
wget -O instantclient-basic.zip $INSTANTCLIENT_BASIC_URL
# Download Oracle Instantclient SDK package.
wget -O instantclient-sdk.zip $INSTANTCLIENT_SDK_URL 

# Unzip the instantclient packages.
ORACLE_DIR=/opt/oracle
if [ ! -d "$ORACLE_DIR" ]; then
    sudo mkdir $ORACLE_DIR
fi
cd $ORACLE_DIR
sudo unzip ~/Downloads/instantclient-basic.zip
sudo unzip ~/Downloads/instantclient-sdk.zip

# Update the runtime link path.
INSTANTCLIENT_DIR=$(ls | grep instantclient)
sudo bash -c "echo /opt/oracle/$INSTANTCLIENT_DIR > /etc/ld.so.conf.d/oracle-instantclient.conf"
sudo ldconfig

# Install the oci8 extension for each supported PHP version.
# Check out https://pecl.php.net/package/oci8.
for phpver in "${PHP_VERSIONS[@]}"
do
    # Default oci8 version for the latest versions of PHP.
    OCI8="oci8"
    ~/apps/switchphp.sh $phpver
    if [ $(echo "$phpver < 8.0"|bc -l) -eq 1 ]; then
        OCI8="oci8-2.2.0"
    elif [ $(echo "$phpver == 8.0"|bc -l) -eq 1 ]; then
        OCI8="oci8-3.0.1"
    fi
    # Install the oci8 extension.
    echo "Installing OCI8 extension ($OCI8) for PHP $phpver..."
    sudo bash -c "echo 'instantclient,/opt/oracle/$INSTANTCLIENT_DIR' | pecl install $OCI8"
    # Create an ini file for the extension.
    sudo bash -c "echo 'extension=oci8.so' > /etc/php/$phpver/mods-available/oci8.ini"
done

# Enable the OCI8 extension.
echo "Enabling oci8 extension..."
sudo phpenmod oci8

# Install an Oracle XE DB via docker.
if [ $INSTALL_ORACLE -eq 1 ]; then
    docker run --name oracle_$ORACLE_DB_TAG -p 1521:1521 moodlehq/moodle-db-oracle-r2:$ORACLE_DB_TAG
fi

# Tidy up.
echo "Tidying up..."
rm ~/Downloads/instantclient-basic.zip
rm ~/Downloads/instantclient-sdk.zip

# Switch back to default PHP version.
~/apps/switchphp.sh $DEFAULT_PHP_VERSION
