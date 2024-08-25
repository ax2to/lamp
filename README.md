# Ubuntu 24.04 Server Setup Script for Laravel 11

This script automates the installation and configuration of essential packages required to set up a web server for running a Laravel 11 project on Ubuntu 24.04. The script installs Apache, PHP 8.2, MySQL, and all the necessary PHP extensions. It also sets up Composer, the dependency manager for PHP, which is essential for Laravel.

## How to Use the Script

1. Clone or download this repository to your Ubuntu 24.04 server.

2. Open a terminal and navigate to the directory containing the script.

3. Make the script executable:

    ```bash
    chmod +x ubuntu24.sh
    ```

4. Run the script with superuser permissions:

    ```bash
    sudo ./ubuntu24.sh
    ```

5. The script will automatically install and configure the server for Laravel 11.

## Script Contents

The script performs the following steps:

1. **Updates package lists:**
    - Ensures that all packages are up to date.

2. **Installs essential tools:**
    - `zip`, `curl`, and `unzip`, which are commonly needed in Laravel projects.

3. **Installs Apache2:**
    - Sets up the Apache web server.

4. **Installs PHP 8.2 and PHP CLI:**
    - PHP 8.2 is the default version on Ubuntu 24.04 and is fully compatible with Laravel 11.

5. **Installs MySQL Server:**
    - Sets up MySQL for database management.

6. **Installs required PHP extensions:**
    - Includes all the necessary extensions for Laravel 11, such as `BCMath`, `Ctype`, `Fileinfo`, `JSON`, `Mbstring`, `OpenSSL`, `PDO`, `Tokenizer`, `XML`, `MySQL`, `Curl`, and `Zip`.

7. **Enables Apache and PHP modules:**
    - Enables `mod_rewrite` for Apache, which is required for Laravel routing.

8. **Installs Composer:**
    - Downloads and installs Composer, the PHP dependency manager required by Laravel.

9. **Restarts Apache2:**
    - Restarts Apache to apply all the changes.

## Optional Packages

The script also installs the following optional PHP extensions:

- **`php-apcu`**: Useful for caching if you plan to use APCu.
- **`php-imagick`**: Required if your Laravel project handles image processing.

If you don't need these extensions, you can remove them from the script.

## Notes

- Ensure that your server is connected to the internet to allow the installation of packages.
- After running the script, your server will be ready to deploy and run Laravel 11 projects.