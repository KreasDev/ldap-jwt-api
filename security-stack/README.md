# security-stack — integración Docker + Fail2Ban (local)

Infraestructura que pone los tres servicios HTTP detrás de un único proxy nginx
con Fail2Ban, y añade protección Fail2Ban para LDAP/LDAPS (636). Vive dentro del
repo `ldap-jwt-api` porque aquí ya está el compose que une FastAPI + OpenLDAP.

## Expectativa de rutas

Los tres repos deben estar como **carpetas hermanas** dentro de una carpeta común
(p. ej. `Seguridad/`):

```
Seguridad/
├── dashboard-videojuegos-frontend/
├── dashboard-videojuegos-backend/
└── ldap/ (repo ldap-jwt-api)
    └── security-stack/   <-- este compose
```

El compose construye el frontend/backend desde `../../dashboard-videojuegos-*`
(NO duplica su código) y FastAPI/OpenLDAP desde el propio repo.

## Componentes

```
security-stack/
├── docker-compose.yml      # 3 apps + openldap + proxy + ldap-fail2ban
├── proxy/                  # nginx + fail2ban (http-frontend/backend/fastapi)
│   ├── Dockerfile  nginx.conf  jail.local  filter-http-flood.conf  entrypoint.sh
└── ldap-fail2ban/          # fail2ban sidecar (ldap-auth) en el netns de openldap
    ├── Dockerfile  jail.local  ldap-auth.conf  entrypoint.sh  enable-ldap-logging.sh
```

## Puesta en marcha (PowerShell), orden exacto

```powershell
# 0) Certs de laboratorio (la CA de osixia venía caducada). Una vez:
bash ../certs/generate-certs.sh

cd security-stack
# 1) Levantar OpenLDAP primero
docker compose up -d --build openldap
# 2) Habilitar el log de slapd que lee Fail2Ban (cn=config es efímero en osixia)
bash ldap-fail2ban/enable-ldap-logging.sh
# 3) Levantar el resto (apps, proxy, sidecar)
docker compose up -d --build
docker compose ps
```

Vuelve a ejecutar `enable-ldap-logging.sh` si recreas `dvj-openldap`.

Consulta el README principal del repo (`../README.md`, sección
**Protección Fail2Ban**) para puertos, validación, TLS 636 y detención.
