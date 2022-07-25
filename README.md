# moodle-ubuntu

A script that sets up a Moodle development environment in Ubuntu

**Disclaimer:** This is only meant for use on development and testing environments. Do **NOT** use this for production environments!

## Setup

1. Download and install [Ubuntu Desktop](https://ubuntu.com/download/desktop).

    - If you're setting up an Ubuntu virtual machine using VirtualBox, follow [these instructions](https://ubuntu.com/tutorials/how-to-run-ubuntu-desktop-on-a-virtual-machine-using-virtualbox#1-overview).

2. Open a terminal and install `git`

    ```bash
    sudo apt update && sudo apt install -y git
    ```

3. Clone this repository and make the script executable.

    ```bash
    git clone https://github.com/junpataleta/moodle-ubuntu.git
    cd moodle-ubuntu
    chmod +x setup.sh 
    ```

    - **Note:** If you're using VirtualBox, this is a good point to [take a snapshot](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/snapshots.html) of the machine first so it would be easier to reset in case you need to reinstall when the setup script gets updated in the future.

4. Run the script

    ```bash
    ./setup.sh
    ```

5. Grab some coffee, walk the dog, cook your lunch, do the laundry, or whatever.😛

## After setup

After the installation, you should have the following:

- Apache server
- PHP versions supported by the lowest security-supported version of Moodle and the next major Moodle version (master).
  - Current PHP versions installed:
    - PHP 7.3 (Moodle 3.9+)
    - PHP 7.4 (Moodle 4.0+)
    - PHP 8.0 (Moodle 3.11.8+, 4.0.2+)
    - PHP 8.1 (master, tentative)
  - To switch PHP versions, open a terminal and run `~/apps/switchphp.sh PHPVER` where `PHPVER` is any of the installed PHP version numbers. e.g. to switch to PHP 7.4

    ```bash
    ~/apps/switchphp.sh 7.4
    ```

- PostgreSQL server version supported by your Ubuntu distribution.
  - Username: `postgres`
  - Password: `moodle`
- MySQL server version supported by your Ubuntu distribution.
- MDK
  - Two instances are created by MDK during setup:
    - An `moodle.git` instance based on the `master` branch: `http://localhost/stable_master`
    - An `integration.git` instance based on the `master` branch: `http://localhost/integration_master`
  - Default `admin` password for both instances is `test`.
  - Default database engine is `pgsql`.
- Behat-related stuff:
  - [moodle-browser-config](https://github.com/andrewnicols/moodle-browser-config)
  - Chromedriver
  - Geckodriver
  - Selenium
  - xvfb
- Docker with Docker compose
- Ngrok

Enjoy!
