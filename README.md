# OpenDMARC-Reports

Automating OpenDMARC reports securely using SystemD units.

The instructions on [OpenDMARC/reports/README][1] are a bit open and suggest using cron jobs.
The risk with this approach is passing credentials as command line arguments, which is not secure.

*This example is tested on Debian 11 & Ubuntu 20.04.*

## Prerequisites

1. OpenDMARC
   1. installed with reporting tools.
   1. configured to keep history; `HistoryFile /var/run/opendmarc/opendmarc.dat` in `opendmarc.conf`.

1. MySQL or MariaDB
   1. a database with the [schema][2] from trusteddomainproject / OpenDMARC.
   1. a password authenticated user (e.g. `'opendmarc'@'localhost'`) with read/write access to the database.

## Installation

1. Read the [`install.sh`](install.sh) to ensure it fits your requirements.
1. Run `sudo ./install.sh` on the root directory of this repository.
1. Complete the setup by editing the installed `opendmarc.private.env`.

The [`uninstall.sh`](uninstall.sh) helps reversing the changes made by the installation script in the correct order.

[1]: https://github.com/trusteddomainproject/OpenDMARC/blob/master/reports/README
[1]: https://github.com/trusteddomainproject/OpenDMARC/blob/master/db/schema.mysql
