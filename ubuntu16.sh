#!/usr/bin/env bash
set -euo pipefail

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
fail() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    fail "Run as root: sudo ./ubuntu16.sh"
  fi
}

ensure_old_releases_mirror_if_needed() {
  local version_id=""
  local codename=""

  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    version_id="${VERSION_ID:-}"
    codename="${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}"
  fi

  if [[ -z "$codename" ]] && command -v lsb_release >/dev/null 2>&1; then
    codename="$(lsb_release -sc || true)"
  fi

  if [[ "$version_id" != "16.04" && "$codename" != "xenial" ]]; then
    return 0
  fi

  info "Ubuntu 16 detected; switching apt sources to old-releases.ubuntu.com"

  cat > /etc/apt/sources.list <<'SRC'
deb http://old-releases.ubuntu.com/ubuntu/ xenial main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse
SRC
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

enable_php_module_if_present() {
  local module="$1"
  if command -v phpenmod >/dev/null 2>&1; then
    if phpenmod "$module"; then
      info "Enabled PHP module: $module"
    else
      warn "Unable to enable PHP module: $module"
    fi
  else
    warn "phpenmod not found; skipping module enable for $module"
  fi
}

main() {
  require_root
  ensure_old_releases_mirror_if_needed
  refresh_apt_indexes

  info "Installing base tools"
  apt-get install -y zip curl unzip

  info "Installing Apache"
  apt-get install -y apache2

  info "Installing distro-default PHP for Ubuntu 16"
  apt-get install -y php php-cli

  info "Installing PHP extensions"
  apt-get install -y php-mbstring php-xml php-mysql php-curl php-zip
  install_optional_package php-apcu
  install_optional_package php-imagick
  install_optional_package php-mcrypt

  enable_php_module_if_present mcrypt

  info "Installing Apache PHP integration when available"
  install_optional_package libapache2-mod-php

  info "Enabling Apache rewrite module"
  a2enmod rewrite

  install_database_server

  info "Composer is skipped on Ubuntu 16 by default due to compatibility constraints"

  info "Restarting Apache"
  service apache2 restart

  info "Ubuntu 16 (default PHP) LAMP setup finished"
}

main "$@"
