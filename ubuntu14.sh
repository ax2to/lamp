#!/usr/bin/env bash
set -euo pipefail

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
fail() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    fail "Run as root: sudo ./ubuntu14.sh"
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

  if [[ "$version_id" != "14.04" && "$codename" != "trusty" ]]; then
    return 0
  fi

  info "Ubuntu 14 detected; switching apt sources to old-releases.ubuntu.com"

  cat > /etc/apt/sources.list <<'SRC'
deb http://old-releases.ubuntu.com/ubuntu/ trusty main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse
SRC
}

refresh_apt_indexes() {
  info "Refreshing apt package indexes"
  if ! apt-get update -y; then
    fail "apt-get update failed. Check connectivity and apt sources."
  fi
}

install_or_warn() {
  local pkg="$1"
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    info "Installing optional package: $pkg"
    apt-get install -y "$pkg"
  else
    warn "Optional package not available on this release: $pkg"
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

enable_php5_module_if_present() {
  local module="$1"
  if command -v php5enmod >/dev/null 2>&1; then
    if php5enmod "$module"; then
      info "Enabled PHP5 module: $module"
    else
      warn "Unable to enable PHP5 module: $module"
    fi
  else
    warn "php5enmod not found; skipping module enable for $module"
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

  info "Installing PHP 5"
  apt-get install -y php5 php5-cli

  info "Installing PHP 5 extensions"
  apt-get install -y php5-mysql php5-curl
  install_or_warn php5-apcu
  install_or_warn php5-imagick
  install_or_warn php5-mcrypt

  enable_php5_module_if_present mcrypt

  info "Enabling Apache rewrite module"
  a2enmod rewrite

  install_database_server

  info "Composer is skipped on Ubuntu 14 by default due to compatibility constraints"

  info "Restarting Apache"
  service apache2 restart

  info "Ubuntu 14 LAMP setup finished"
}

main "$@"
