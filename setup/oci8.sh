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

cd ~/apps
mkdir oci8
cd oci8

# Install the oci8 extension for each supported PHP version.
# Check out https://pecl.php.net/package/oci8.
for phpver in "${PHP_VERSIONS[@]}"
do
    ~/apps/switchphp.sh $phpver
    # Default oci8 version for the latest versions of PHP.
    OCI8_VER=""
    if [ $(echo "$phpver < 8.0"|bc -l) -eq 1 ]; then
        OCI8_VER="-2.2.0"
    elif [ $(echo "$phpver == 8.0"|bc -l) -eq 1 ]; then
        OCI8_VER="-3.0.1"
    elif [ $(echo "$phpver == 8.1"|bc -l) -eq 1 ]; then
        OCI8_VER="-3.2.1"
    fi

    echo "Installing OCI8 extension ($OCI8) for PHP $phpver..."

    # Install the oci8 extension via pecl...
    # sudo pear config-set php_ini /etc/php/$phpver/php.ini
    # sudo pecl config-set bin_dir /usr/bin/
    # sudo bash -c "echo 'instantclient,/opt/oracle/$INSTANTCLIENT_DIR' | pecl install $OCI8"

    # Install oci8 extension via phpize. This seems to work better than using pecl.
    wget https://pecl.php.net/get/oci8$OCI8_VER.tgz

    tar -xzf oci8-$OCI8_VER.tgz
    cd oci8-$OCI8_VER
    phpize
    ./configure -with-oci8=shared,instantclient,/opt/oracle/$INSTANTCLIENT_DIR
    sudo make install

    # Create an ini file for the extension.
    sudo bash -c "echo 'extension=oci8.so' > /etc/php/$phpver/mods-available/oci8.ini"

    # Enable the OCI8 extension.
    echo "Enabling oci8 extension for $phpver..."
    sudo phpenmod -v $phpver oci8

    # Tidy up.
    cd ..
    rm oci8-$OCI8_VER.tgz
done

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
