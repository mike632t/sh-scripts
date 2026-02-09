#!/bin/bash
#
#  sh-cleanup.sh
#
#  Removes 'unwanted' files and cleans up history.
#
#  This  program is free software: you can redistribute it and/or modify it
#  under  the terms of the GNU General Public License as published  by  the
#  Free  Software Foundation, either version 3 of the License, or (at  your
#  option) any later version.
#
#  This  program  is distributed in the hope that it will  be  useful,  but
#  WITHOUT   ANY   WARRANTY;   without even   the   implied   warranty   of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#  Public License for more details.
#
#  You  should have received a copy of the GNU General Public License along
#  with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  28 Nov 16 - 0.1   - Initial version - MT
#            - 0.2   - Deletes login history - MT
#  03 Jul 17 - 0.3   - Stops any common display managers before rotating
#                      log files - MT
#
apt-get autoremove --purge; apt-get autoclean; apt-get clean
find /var/lib/apt/lists/ -type f -delete -print; apt-get clean
find /var/cache/ -type f -not -name localelist -delete -print
#
/etc/init.d/gdm stop || /etc/init.d/gdm3 stop || /etc/init.d/kdm stop || /etc/init.d/xdm stop || /etc/init.d/lightdm stop
#
logrotate -f /etc/logrotate.conf; logrotate -f /etc/logrotate.conf
logrotate -f /etc/logrotate.conf; logrotate -f /etc/logrotate.conf
logrotate -f /etc/logrotate.conf; logrotate -f /etc/logrotate.conf
logrotate -f /etc/logrotate.conf; logrotate -f /etc/logrotate.conf
find /var/log -name '*.[0-9]*' -delete -print
#
find /etc/udev/rules.d -name '70-per*-*.rules' -delete -print
#
rm -f /var/log/wtmp; touch /var/log/wtmp
rm -f /var/log/btmp; touch /var/log/btmp
#
find / -name '*~' -delete -print
history -c ;find / -name '.bash_history' -delete -print
#
# Comment out the next line if running this on a VM that is thin provisioned.
history -c;dd if=/dev/zero of=/nul;sync;sync;sync;rm -f /nul;sync
#
history -c;poweroff
