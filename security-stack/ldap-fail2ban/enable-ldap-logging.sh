#!/usr/bin/env bash
# Run ONCE after `docker compose up -d openldap`, BEFORE starting the
# ldap-fail2ban sidecar. Points slapd's stats log at the shared log file that
# Fail2Ban reads. osixia keeps cn=config in an ephemeral layer, so this must be
# re-applied whenever the openldap container is recreated.
set -e
CT="${1:-dvj-openldap}"

# Make the shared log dir writable by the slapd user (uid 911).
docker exec "$CT" sh -c 'mkdir -p /var/log/slapd && chown openldap:openldap /var/log/slapd && chmod 750 /var/log/slapd'

# olcLogFile = real file (hex-epoch prefixed); olcLogLevel stats = conn/BIND/RESULT.
docker exec -i "$CT" ldapmodify -Y EXTERNAL -H ldapi:/// <<'LDIF'
dn: cn=config
changetype: modify
replace: olcLogFile
olcLogFile: /var/log/slapd/slapd.log
-
replace: olcLogLevel
olcLogLevel: stats
LDIF

echo "slapd logging enabled -> /var/log/slapd/slapd.log"
