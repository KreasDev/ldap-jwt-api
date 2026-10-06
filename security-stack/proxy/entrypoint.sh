#!/bin/bash
set -e
mkdir -p /var/log/nginx /var/run/fail2ban

# Fail2Ban needs real, readable log files (not the image's stdout symlinks),
# one per protected service.
rm -f /var/log/nginx/*.log
touch \
  /var/log/nginx/frontend_access.log /var/log/nginx/frontend_error.log \
  /var/log/nginx/backend_access.log  /var/log/nginx/backend_error.log \
  /var/log/nginx/fastapi_access.log  /var/log/nginx/fastapi_error.log \
  /var/log/fail2ban.log
rm -f /var/run/fail2ban/fail2ban.sock /var/run/fail2ban/fail2ban.pid

nginx -g 'daemon off;' &
sleep 1
fail2ban-client -x start

echo "[proxy] nginx + fail2ban running. Following fail2ban log..."
exec tail -F /var/log/fail2ban.log
