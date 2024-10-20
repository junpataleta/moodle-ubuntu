source "$(pwd)/config.sh"

cd $APPS_DIR

# Download Chrome.
echo "----------------------------------------"
echo "Setting up Chrome..."
echo "----------------------------------------"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Install Chrome.
sudo dpkg -i ./google-chrome-stable_current_amd64.deb

# Tidy up.
rm ./google-chrome-stable_current_amd64.deb

# Extract version of Chrome.
CHROME_VER=$(google-chrome --version | cut -d ' ' -f 3 | cut -d '.' -f 1,2,3 --output-delimiter='.')

echo "----------------------------------------"
echo "Setting up ChromeDriver..."
echo "----------------------------------------"

# Download/update the latest stable version of Chromedriver.
if [ ! -d "$APPS_DIR/chrome-for-testing" ]; then
  git clone https://github.com/GoogleChromeLabs/chrome-for-testing.git
  cd $APPS_DIR/chrome-for-testing
  nvm install
  npm install
else
  cd $APPS_DIR/chrome-for-testing
  git fetch origin
  git reset --hard origin/main
  npm install
fi

CHROMEDRIVER_URL=$(npm run find | grep "$CHROME_VER.*chromedriver-linux64" | cut -d ' ' -f 1)

cd $APPS_DIR

# Download the zip file of the chromedriver.
echo "Downloading Chromedriver from $CHROMEDRIVER_URL..."
wget $CHROMEDRIVER_URL

# Extract it.
unzip -o -p chromedriver-linux64.zip chromedriver-linux64/chromedriver >chromedriver

# Ensure ChromeDriver is executable.
if [[ ! -x "chromedriver" ]]; then
  chmod +x chromedriver
fi

# Link it to /usr/local/bin, if necessary.
if [ ! -f "/usr/local/bin/chromedriver" ]; then
    sudo ln -s "$APPS_DIR/chromedriver" /usr/local/bin/chromedriver
fi

# Tidy up.
rm chromedriver-linux64.zip

# Go back to the source home.
cd $SOURCE_HOME
