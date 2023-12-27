#!/bin/bash
# ------------------------------------------------------------------------------
# Automation script for sending DMARC reports generated from the data collected
# by OpenDMARC. Designed to be executed using SystemD unit & timer. Remember to 
# pass sensitive environment variables like $OPENDMARC_PASSWORD securely!
#
# Author : Esa Jokinen (oh2fih)
# Home   : https://github.com/oh2fih/OpenDMARC-Reports
# ------------------------------------------------------------------------------

required_command() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "\033[0;31mThis script requires ${1}!\033[0m" >&2
    ((UNMET=UNMET+1))
  fi
}

required_envvar() {
  if [[ ! -v $1 ]]; then
    if [ -z ${2+x} ]; then
      echo -e "\033[0;31mMissing required environment variable ${1}!\033[0m" >&2
      ((UNMET=UNMET+1))
    else
      echo -e "\033[0;33mMissing environment variable ${1} (default: ${2})\033[0m" >&2
    fi
  fi
}

UNMET=0

# Required tools
required_command "/usr/sbin/opendmarc-import"
required_command "/usr/sbin/opendmarc-reports"
required_command "/usr/sbin/opendmarc-expire"

# Environment variables required by this script
required_envvar "REPORT_EMAIL" # email address to use in the From header
required_envvar "REPORT_ORG" # domain; organization responsible for the report
required_envvar "SMTP_SERVER" # SMTP server to use
required_envvar "SMTP_PORT" # SMTP port to use

# Environment variables used by the tools
required_envvar "OPENDMARC_DBHOST" "localhost"
required_envvar "OPENDMARC_PORT" "3306"
required_envvar "OPENDMARC_DB" "opendmarc"
required_envvar "OPENDMARC_USER" "opendmarc"
required_envvar "OPENDMARC_PASSWORD" "opendmarc"

if [ "$UNMET" -gt 0 ]; then
  exit 1
fi

set -e

echo "Moving opendmarc.dat for import..."
mv opendmarc.dat opendmarc_import.dat -f
touch opendmarc.dat
echo "New opendmarc.dat initialized, reporting..."

/usr/sbin/opendmarc-import --verbose < opendmarc_import.dat

rm opendmarc_import.dat

/usr/sbin/opendmarc-reports \
  --verbose \
  --interval=86400 \
  --report-email "$REPORT_EMAIL" \
  --report-org "$REPORT_ORG" \
  --smtp-server="$SMTP_SERVER" \
  --smtp-port="$SMTP_PORT"

/usr/sbin/opendmarc-expire --verbose

echo "DMARC reporting finished."
