#!/usr/bin/env bash
set -euo pipefail

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
fail() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    fail "Run as root: sudo ./ubuntu24.sh"
  fi
}

refresh_apt_indexes() {
  info "Refreshing apt package indexes"
  if ! apt-get update -y; then
    fail "apt-get update failed. Check connectivity and apt sources."
  fi
}

install_optional_package() {
  local pkg="$1"
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    info "Installing optional package: $pkg"
    apt-get install -y "$pkg"
  else
    warn "Optional package not available: $pkg"
  fi
}

install_database_server() {
  info "Installing database server (mysql-server preferred)"
  if apt-cache show mysql-server >/dev/null 2>&1; then
    apt-get install -y mysql-server
    info "Database engine installed: mysql-server"
    return 0
  fi

  warn "mysql-server package unavailable, falling back to mariadb-server"
  if apt-cache show mariadb-server >/dev/null 2>&1; then
    apt-get install -y mariadb-server
    info "Database engine installed: mariadb-server"
    return 0
  fi

  fail "Neither mysql-server nor mariadb-server is available"
}

install_composer_securely() {
  local expected actual installer
  installer="/tmp/composer-setup.php"

  info "Installing Composer with signature verification"
  expected="$(curl -fsSL https://composer.github.io/installer.sig)"
  curl -fsSL https://getcomposer.org/installer -o "$installer"

  actual="$(php -r "echo hash_file('sha384', '$installer');")"
  if [[ "$expected" != "$actual" ]]; then
    rm -f "$installer"
    fail "Composer installer signature verification failed"
  fi

  php "$installer" --install-dir=/usr/local/bin --filename=composer
  rm -f "$installer"
  info "Composer installed at /usr/local/bin/composer"
}

main() {
  require_root
  refresh_apt_indexes

  info "Installing base tools"
  apt-get install -y zip curl unzip ca-certificates

  info "Installing Apache"
  apt-get install -y apache2

  info "Installing PHP (Ubuntu 24 default)"
  apt-get install -y php php-cli

  info "Installing PHP extensions for Laravel"
  apt-get install -y php-bcmath php-mbstring php-xml php-mysql php-curl php-zip
  install_optional_package php-apcu
  install_optional_package php-imagick

  info "Installing Apache PHP module when available"
  install_optional_package libapache2-mod-php

  info "Enabling Apache rewrite module"
  a2enmod rewrite

  install_database_server
  install_composer_securely

  info "Restarting Apache"
  systemctl restart apache2

  info "Ubuntu 24 LAMP setup finished"
}

main "$@"
