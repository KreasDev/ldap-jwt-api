# Reverse proxy + Fail2Ban, reusing the professor's victim-protected pattern
# (fail2ban-ddos/victim-protected): nginx writes real log files that Fail2Ban
# polls, and bans happen inside this container's own network namespace via
# iptables (requires NET_ADMIN/NET_RAW from docker-compose).
FROM nginx:1.27-alpine
RUN apk add --no-cache fail2ban bash iptables iproute2

COPY nginx.conf /etc/nginx/nginx.conf
COPY jail.local /etc/fail2ban/jail.local
COPY filter-http-flood.conf /etc/fail2ban/filter.d/http-flood.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5173 3000 8000
ENTRYPOINT ["/entrypoint.sh"]
