#!/bin/bash

SOURCE_HOME=$(pwd)

# Make all shell script files executable.
find "$SOURCE_HOME" -type f -iname "*.sh" -exec chmod +x {} \;

if [ -e "$SOURCE_HOME/config.sh" ]; then
    source "$SOURCE_HOME/config.sh"
else
    # Load default config.
    source "$SOURCE_HOME/config-dist.sh"
fi

# Disable automatic screen lock.
gsettings set org.gnome.desktop.screensaver lock-enabled false

# Add ondrej/php ppa so we can install other PHP versions.
sudo add-apt-repository ppa:ondrej/php -y

# Update and upgrade.
sudo apt update && sudo apt upgrade -y

# Install docker.
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    uidmap \
    dbus-user-session

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install docker compose.
sudo apt install docker-compose-plugin

# Use docker as non-root user.
dockerd-rootless-setuptool.sh install

# Install ngrok.
snap install ngrok

# Create apps folder.
mkdir "$APPS_DIR"

# Copy scripts to apps folder.
cp ./scripts/* "$APPS_DIR"
chmod +x "$APPS_DIR"/switchphp.sh
chmod +x "$APPS_DIR"/runngrok.sh

# Install mysql and other required programs.
sudo apt install -y mysql-server curl git default-jdk xvfb phppgadmin

# Configure Git.
git config --global core.filemode false
git config --global core.autocrlf false
# Set up Git email.
if [ -n "$GIT_EMAIL" ]; then
  git config --global user.email "$GIT_EMAIL"
fi
# Set up Git name.
if [ -n "$GIT_NAME" ]; then
  git config --global user.name "$GIT_NAME"
fi

# Install PostgreSQL server.
sudo apt install -y postgresql postgresql-contrib

# Set postgres account password.
sudo -u postgres psql -c "ALTER ROLE postgres WITH PASSWORD 'moodle';"

PHP_INSTALL=""
for phpver in "${PHP_VERSIONS[@]}"
do
  # Install supported PHP versions.
  PHP_INSTALL="$PHP_INSTALL php$phpver"

  # Install required PHP extensions per version.
  for j in "${PHP_EXTS[@]}"
  do
      # PHP 8.0+ don't support XMLRPC anymore. Skip...
      if [ "$j" == "xmlrpc" ] && [ $(echo "$phpver >= 8.0"|bc -l) -eq 1 ]
      then
          continue
      fi
      PHP_INSTALL="$PHP_INSTALL php$phpver-$j"
  done
  # Install required PHP extensions.
  sudo apt install -y "$PHP_INSTALL"

  # Set max_input_vars to 5000.
  sudo sed -i_bak "/;max_input_vars.*/a max_input_vars = 5000" /etc/php/"$phpver"/apache2/php.ini
  sudo sed -i_bak "/;max_input_vars.*/a max_input_vars = 5000" /etc/php/"$phpver"/cli/php.ini

  # Reset for the next PHP version.
  PHP_INSTALL=""

done

# Install the ODBC Driver and SQL Command Line Utility for SQL Server.
source "$SOURCE_HOME/setup/sqlsrv.sh"

# Setup Oracle.
source "$SOURCE_HOME/setup/oci8.sh"

# Switch to default PHP version.
"$APPS_DIR"/switchphp.sh "$DEFAULT_PHP_VERSION"

# Create www folder in home (for convenience).
mkdir ~/www
# Point the document root here.
sudo sed -i_bak "/DocumentRoot.*/c DocumentRoot\ \/home\/$(whoami)\/www" /etc/apache2/sites-available/000-default.conf
sudo sed -i_bak "/Directory\ \/var\/www/c <Directory\ \/home\/$(whoami)\/www\/>" /etc/apache2/apache2.conf

# Add the www-data user to the current user's group to gain access to ~/www.
sudo usermod -a -G `whoami` www-data

# Restart apache.
sudo service apache2 restart

cd $APPS_DIR

# Clone moodle-browser-config.
git clone https://github.com/andrewnicols/moodle-browser-config.git $APPS_DIR/moodle-browser-config

# Download latest geckodriver.
curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest \
  | grep browser_download_url \
  | grep linux64 \
  | cut -d '"' -f 4 \
  | wget -qi -

# Extract it.
tar -xvzf "$(ls | grep 'geckodriver.*gz' | head -1)"

# Delete the geckodriver package.
rm geckodriver*.gz*

# Link it to /usr/local/bin.
sudo ln -s "$(pwd)/geckodriver" /usr/local/bin/geckodriver

# MDK.

# Install required packages.
sudo apt install -y python3-pip libmysqlclient-dev libpq-dev python3-dev

# Install MDK.
sudo pip install moodle-sdk

# Reload paths.
source "$HOME"/.profile

# Create MDK config.json.
mkdir ~/.moodle-sdk
touch ~/.moodle-sdk/config.json
# GitHub-related MDK settings.
if [ -n "$MDK_GITHUB_USER" ]; then
  mdk config set remotes.mine "git@github.com:$MDK_GITHUB_USER/moodle.git"
  mdk config set repositoryUrl "https://github.com/$MDK_GITHUB_USER/moodle.git"
  mdk config set diffUrlTemplate "https://github.com/$MDK_GITHUB_USER/moodle/compare/%headcommit%...%branch%"
fi
# Tracker-related MDK settings.
if [ -n "$MDK_TRACKER_USER" ]; then
  mdk config set tracker.username "$MDK_TRACKER_USER"
fi
# dirs.www.
if [ -n "$MDK_WWW_DIR" ]; then
  mdk config set dirs.www "$MDK_WWW_DIR"
fi
# dirs.storage.
if [ -n "$MDK_MOODLES_DIR" ]; then
  mdk config set dirs.storage "$MDK_MOODLES_DIR"
fi
mdk config set defaultEngine pgsql
mdk config set db.pgsql.user postgres
mdk config set db.pgsql.passwd moodle
mdk config set path
mdk config set db.sqlsrv.passwd "$SQLSRV_PASSWD"

# Create moodle instance and symlink folders.
mkdir ~/moodles
mkdir ~/www/mdk

# Create index.php showing phpinfo();
printf '<?php\n    phpinfo();\n' > ~/www/index.php

# Create a moodle.git main instance (stable_main).
mdk create -i -r mindev users

# Create a integration.git main instance (integration_main).
mdk create -i -t -r mindev users

cd ~/moodles/stable_main/moodle

sed -i_bak "/^.*setup\.php.*/i require_once('${HOME}/apps/moodle-browser-config/init.php');" config.php

# Install nvm.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Setup Chrome and Chromedriver.
source "$SOURCE_HOME/setup/chromedriver.sh"

# Initialise Behat
 mdk behat

# Set aliases for selenium pointing to the copy downloaded by MDK.
SEL_CMD="java -jar $HOME/.moodle-sdk/selenium-grid.jar standalone"
echo "alias sel='$SEL_CMD'" >> ~/.bashrc
echo "alias xsel='xvfb-run $SEL_CMD'" >> ~/.bashrc

# Reload bashrc.
source "$HOME"/.bashrc

# Set up parallel run.
# php admin/tool/behat/cli/init.php -j=2 -o
