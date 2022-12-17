#!/bin/bash
# -----------------------------------------------------------
# Uninstall OpenDMARC-Reports script, systemd service & timer
#
# Author : Esa Jokinen (oh2fih)
# Home   : https://github.com/oh2fih/OpenDMARC-Reports
# -----------------------------------------------------------

# Destination directories
SCRIPT_DST=/usr/local/bin
UNIT_DST=/etc/systemd/system
ENV_DST=/etc

if [ "$EUID" -ne 0 ]; then
  echo -e "\033[0;31mThis script requires sudo privileges.\033[0m" >&2
  exit 1
fi

echo "Uninstalling OpenDMARC-Reports script, systemd service & timer"

TIMER="${UNIT_DST}/dmarc-report.timer"
if [[ -f "${TIMER}" ]]; then
  echo
  read -r -n1 -p "${TIMER} found; remove? [y/N]: " resp
  echo
  case "$resp" in
    [yY])
      systemctl stop dmarc-report.timer \
        && systemctl disable dmarc-report.timer \
        && rm "${TIMER}" \
        && systemctl daemon-reload \
        && systemctl reset-failed \
        && echo -e "\033[0;32mTimer removed.\033[0m"
      ;;
    *)
      echo -e "\033[0;31mUninstallation interrupted.\033[0m" >&2
      exit 1
  esac
else
  echo -e "\033[0;33m${TIMER} not found; skipping.\033[0m" >&2
fi

SERVICE="${UNIT_DST}/dmarc-report.service"
if [[ -f "${SERVICE}" ]]; then
  echo
  read -r -n1 -p "${SERVICE} found; remove? [y/N]: " resp
  echo
  case "$resp" in
    [yY])
      systemctl stop dmarc-report.service \
        && systemctl disable dmarc-report.service \
        && rm "${SERVICE}" \
        && systemctl daemon-reload \
        && systemctl reset-failed \
        && echo -e "\033[0;32mService removed.\033[0m"
      ;;
    *)
      echo -e "\033[0;31mUninstallation interrupted.\033[0m" >&2
      exit 1
  esac
else
  echo -e "\033[0;33m${SERVICE} not found; skipping.\033[0m" >&2
fi

SCRIPT="${SCRIPT_DST}/dmarc-report.sh"
if [[ -f "${SCRIPT}" ]]; then
  echo
  read -r -n1 -p "${SCRIPT} found; remove? [y/N]: " resp
  echo
  case "$resp" in
    [yY])
        rm "${SCRIPT}" \
        && echo -e "\033[0;32mScript removed.\033[0m"
      ;;
    *)
      echo -e "\033[0;31mUninstallation interrupted.\033[0m" >&2
      exit 1
  esac
else
  echo -e "\033[0;33m${SCRIPT} not found; skipping.\033[0m" >&2
fi

ENV_FILE="${ENV_DST}/opendmarc.private.env"
if [[ -f "${ENV_FILE}" ]]; then
  echo
  read -r -n1 -p "${ENV_FILE} found; remove? [y/N]: " resp
  echo
  case "$resp" in
    [yY])
        rm "${ENV_FILE}" \
        && echo -e "\033[0;32mScript removed.\033[0m"
      ;;
    *)
      echo -e "\033[0;33mKeeping environment file.\033[0m" >&2
  esac
else
  echo -e "\033[0;33m${ENV_FILE} not found; skipping.\033[0m" >&2
fi

echo -e "\033[0;32mUnistallation completed.\033[0m"
