#!/bin/bash

if [ -z "$1" ]
then
    echo "Please provide a PHP version to switch to (e.g. 7.1)"
    exit 1
fi

# Get the current PHP version.
PHPVER=$(php -v | cut -d' ' -f 2)
# Extract the major version.
MAJORVER=$(echo $PHPVER | cut -d'.' -f 1 -s)
# Extract the minor version.
MINORVER=$(echo $PHPVER | cut -d'.' -f 2 -s)

OLDVER="$MAJORVER.$MINORVER"

# Check if we're already on the version we're switching to.
if [ "$1" == "$OLDVER" ]
then
    echo "You are already on PHP $1"
    exit 1
fi

echo "Switching to PHP $1 from PHP $OLDVER"

# Try to enable the new PHP version.
sudo a2enmod php$1

if [ $? -eq 0 ]
then
    # Disable the old PHP version.
    sudo a2dismod php$OLDVER

    # Update paths.
    sudo update-alternatives --set php /usr/bin/php$1
    sudo update-alternatives --set php-config /usr/bin/php-config$1
    sudo update-alternatives --set phpize /usr/bin/phpize$1  

    # Restart Apache.
    sudo service apache2 restart

    echo "You are now using PHP $1"
fi
