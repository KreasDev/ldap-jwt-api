#!/bin/bash
set -e
mkdir -p /var/run/fail2ban /var/log/slapd
rm -f /var/run/fail2ban/fail2ban.sock /var/run/fail2ban/fail2ban.pid
touch /var/log/fail2ban.log

# Wait until slapd has created its log file in the shared volume.
for i in $(seq 1 30); do
  [ -f /var/log/slapd/slapd.log ] && break
  sleep 1
done

fail2ban-client -x start
echo "[ldap-fail2ban] running in openldap's netns. Following fail2ban log..."
exec tail -F /var/log/fail2ban.log
