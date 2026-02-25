# Multi-Version Ubuntu LAMP Setup Scripts

This repository provides separate setup scripts for Ubuntu 14.04, 16.04, 17.10, and 24.04. Each script installs Apache, PHP, database server packages, and common extensions for Laravel/PHP projects while keeping version-specific package behavior.

## Supported Scripts

| Script | Target Ubuntu | PHP Policy | Database Policy | EOL Mirror Handling |
| --- | --- | --- | --- | --- |
| `ubuntu14.sh` | 14.04 (Trusty) | PHP 5 family (`php5`, `php5-*`) | `mysql-server` then `mariadb-server` fallback | Rewrites to `old-releases.ubuntu.com` |
| `ubuntu16.sh` | 16.04 (Xenial) | Distro-default PHP packages (`php`, `php-*`) | `mysql-server` then `mariadb-server` fallback | Rewrites to `old-releases.ubuntu.com` |
| `ubuntu16-PHP7.sh` | 16.04 (Xenial) | Explicit PHP 7.0 packages (`php7.0-*`) | `mysql-server` then `mariadb-server` fallback | Rewrites to `old-releases.ubuntu.com` |
| `ubuntu17.sh` | 17.10 (Artful) | Explicit PHP 7.1 packages (`php7.1-*`) | `mysql-server` then `mariadb-server` fallback | Rewrites to `old-releases.ubuntu.com` |
| `ubuntu24.sh` | 24.04 (Noble) | Modern repo-native PHP packages (`php`, `php-*`) | `mysql-server` then `mariadb-server` fallback | Not needed |

## Usage

1. Clone this repository on the target server.
2. Make the script executable.
3. Run the script as root.

Example:

```bash
chmod +x ubuntu24.sh
sudo ./ubuntu24.sh
```

## Behavior Notes

- All scripts require root and will fail fast on errors (`set -euo pipefail`).
- Legacy scripts (14/16/17) are best-effort because packages are served from archived repositories and may disappear or change metadata.
- For legacy scripts, Composer installation is intentionally skipped by default to avoid compatibility failures with old PHP runtimes.
- `mysql-server` is attempted first; scripts automatically fall back to `mariadb-server` when needed.
- Optional PHP extensions (for example, APCu/Imagick/mcrypt depending on release) are installed only when available.

## Ubuntu 24 Composer Security

`ubuntu24.sh` installs Composer with SHA-384 signature verification instead of piping the installer directly to PHP.

## Caveats

- Archived Ubuntu releases can have intermittent mirror/package issues.
- Package names differ by release; each script uses version-specific package lists to reduce breakage.
- If Apache is not managed by `systemctl` on a legacy host, use `service apache2 restart` manually after script completion.
