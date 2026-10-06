FROM alpine:3.20
RUN apk add --no-cache fail2ban iptables bash
# Remove distro jail.d defaults (e.g. sshd) that would fail without their logs.
RUN rm -f /etc/fail2ban/jail.d/*.conf /etc/fail2ban/jail.d/*.local 2>/dev/null || true
COPY jail.local /etc/fail2ban/jail.local
COPY ldap-auth.conf /etc/fail2ban/filter.d/ldap-auth.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
