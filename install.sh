#!/bin/bash
# -----------------------------------------------------------
# Install OpenDMARC-Reports script, systemd service & timer
#
# Author : Esa Jokinen (oh2fih)
# Home   : https://github.com/oh2fih/OpenDMARC-Reports
# -----------------------------------------------------------

# Destination directories
SCRIPT_DST=/usr/local/bin
UNIT_DST=/etc/systemd/system
ENV_DST=/etc

# Check for requirements

required_command() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "\033[0;31mIncompatible system: missing command ${1}!\033[0m" >&2
    ((UNMET=UNMET+1))
  fi
}

required_directory() {
  if ! [[ -d "$1" ]] &> /dev/null; then
    echo -e "\033[0;31mIncompatible system: missing directory ${1}!\033[0m" >&2
    ((UNMET=UNMET+1))
  fi
}

required_file() {
  if ! [[ -f "$1" ]]; then
    echo -e "\033[0;31mMissing file ${1}; wrong working directory?\033[0m" >&2
    ((UNMET=UNMET+1))
  fi
}

UNMET=0

required_command "/usr/sbin/opendmarc-import"
required_command "/usr/sbin/opendmarc-reports"
required_command "/usr/sbin/opendmarc-expire"
required_command "systemctl"

required_directory "$SCRIPT_DST"
required_directory "$UNIT_DST"
required_directory "$ENV_DST"

required_file "bin/dmarc-report.sh"

if [ "$EUID" -ne 0 ]; then
  echo -e "\033[0;31mThis script requires sudo privileges.\033[0m" >&2
  ((UNMET=UNMET+1))
fi

if [ "$UNMET" -gt 0 ]; then
  echo
  echo -e "\033[0;31mFix unmet requirements & run from the root of\033[0m" >&2
  echo -e "\033[0;31mthe repository with 'sudo ./install.sh'\033[0m" >&2
  exit 1
fi

# Install

set -e
trap 'echo -e "\033[0;31m*** ERROR: Installation not successful.\033[0m"' ERR

echo "Installing OpenDMARC-Reports script, systemd service & timer"

echo
echo "Installing script to ${SCRIPT_DST}/dmarc-report.sh"
cp "bin/dmarc-report.sh" "${SCRIPT_DST}/dmarc-report.sh"
chown root:root "${SCRIPT_DST}/dmarc-report.sh"
chmod 755 "${SCRIPT_DST}/dmarc-report.sh"
echo -e "\033[0;32mDone.\033[0m"

echo
echo "Installing SystemD service to ${UNIT_DST}/dmarc-report.service"
cp "systemd/dmarc-report.service" "${UNIT_DST}/dmarc-report.service"
chown root:root "${UNIT_DST}/dmarc-report.service"
chmod 644 "${UNIT_DST}/dmarc-report.service"
echo -e "\033[0;32mDone.\033[0m"

echo
echo "Installing SystemD timer to ${UNIT_DST}/dmarc-report.timer"
cp "systemd/dmarc-report.timer" "${UNIT_DST}/dmarc-report.timer"
chown root:root "${UNIT_DST}/dmarc-report.timer"
chmod 644 "${UNIT_DST}/dmarc-report.timer"
echo -e "\033[0;32mDone.\033[0m"

echo
INSTALL_ENV=true
if [[ -f "${ENV_DST}/opendmarc.private.env" ]]; then
  echo
  read -r -n1 -p "Configuration already found; overwrite? [y/N]: " resp
  echo
  case "$resp" in
    [yY])
      INSTALL_ENV=true
      ;;
    *)
      INSTALL_ENV=false
      echo "Keeping the current configuration ${ENV_DST}/opendmarc.private.env"
      echo "Ensuring secure private configuration file permissions"
      chown root:root "${ENV_DST}/opendmarc.private.env"
      chmod 600 "${ENV_DST}/opendmarc.private.env"
  esac
fi

if $INSTALL_ENV; then
  echo "Installing private configuration to ${ENV_DST}/opendmarc.private.env"
  cp "etc/opendmarc.private.env" "${ENV_DST}/opendmarc.private.env"
  chown root:root "${ENV_DST}/opendmarc.private.env"
  chmod 600 "${ENV_DST}/opendmarc.private.env"
  echo -e "\033[0;32mDone.\033[0m"
fi

echo
echo "Reloading SystemD units"
systemctl daemon-reload
echo -e "\033[0;32mDone.\033[0m"

echo
echo "Enabling SystemD timer"
systemctl enable dmarc-report.timer
systemctl start dmarc-report.timer
echo -e "\033[0;32mDone.\033[0m"

echo
echo "Status:"
echo
systemctl status dmarc-report.service || true
echo
systemctl status dmarc-report.timer
echo
echo -e "\033[0;32mInstallation successful.\033[0m"
echo "Complete setup by editing ${ENV_DST}/opendmarc.private.env"
