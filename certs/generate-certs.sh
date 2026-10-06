#!/usr/bin/env bash
# Regenerate the lab TLS material for OpenLDAP (LDAPS/636).
#
# Why this exists: osixia/openldap:1.5.0 ships a CA that already expired
# (2026-01-15), which breaks the TLS handshake. These are throwaway LAB certs;
# the private keys are git-ignored, so run this once after cloning, before
# `docker compose up`.
#
# Output (in this folder): ca.key, ca.crt, ldap.key, ldap.crt (+ reuses
# dhparam.pem). Uses a disposable Alpine+OpenSSL container, so no local openssl
# is required.
set -e
cd "$(dirname "$0")"
HERE="$(pwd)"

docker run --rm -v "${HERE}:/out" alpine:3.20 sh -c '
set -e
apk add --no-cache openssl >/dev/null
cd /out
openssl genrsa -out ca.key 2048 2>/dev/null
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 \
  -subj "/C=MX/O=Seguridad Lab/CN=lab-openldap-ca" -out ca.crt
openssl genrsa -out ldap.key 2048 2>/dev/null
openssl req -new -key ldap.key -subj "/C=MX/O=Seguridad Lab/CN=openldap" -out ldap.csr
printf "subjectAltName=DNS:openldap,DNS:localhost,IP:127.0.0.1\n" > san.ext
openssl x509 -req -in ldap.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -days 3650 -sha256 -extfile san.ext -out ldap.crt
[ -f dhparam.pem ] || openssl dhparam -out dhparam.pem 2048 2>/dev/null
rm -f ldap.csr san.ext ca.srl
chmod 644 ca.crt ldap.crt dhparam.pem
chmod 640 ca.key ldap.key
'
echo "Lab certs generated in ${HERE}:"
ls -1 "${HERE}"/*.crt "${HERE}"/*.key "${HERE}"/dhparam.pem
