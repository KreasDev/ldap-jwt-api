# Validación de correcciones — LDAP / JWT API (dvj-api)

Este documento es independiente del análisis inicial: los archivos `../nuclei-results.jsonl` y `../README.md` se conservan sin cambios.

## Metodología

Para cada hallazgo, en un commit independiente:

1. Se aplicó la corrección en el código o la configuración.
2. Se reconstruyó y recreó **solo** el contenedor afectado (`docker compose up -d --build --no-deps`), sin tocar `dvj-openldap`, `dvj-ldap-fail2ban` ni los volúmenes.
3. Se comprobó la conectividad desde un contenedor Nuclei conectado a la red bridge `security-stack_appnet` (`http://api:8000`).
4. Se ejecutaron las pruebas: compilación de la imagen (incluye `tsc`/`vite build` en los servicios Node) y 12 pruebas funcionales de extremo a extremo a través del proxy (frontend, rutas SPA, login LDAP válido/incorrecto → JWT, `/api/games` con y sin token, validación 400, preflight CORS).
5. Se volvió a ejecutar Nuclei contra el servicio con la plantilla del hallazgo y se comprobó que el hallazgo desapareció **antes** de hacer el commit.

La evidencia de cada paso (salida de Nuclei y JSONL con los hallazgos que quedaban en ese momento) está en esta carpeta.

## Resultado por hallazgo

| # | Hallazgo original (Nuclei) | Severidad | Estado | Commit | Evidencia | Re-escaneo final |
|---|---|---|---|---|---|---|
| 1 | `swagger-api` | info | Corregido y verificado | `5ab8cee` | [`01-swagger-api.nuclei-output.txt`](01-swagger-api.nuclei-output.txt) | No detectado |
| 2 | `redoc-api-docs` | info | Corregido y verificado | `b5aa2a9` | [`02-redoc-api-docs.nuclei-output.txt`](02-redoc-api-docs.nuclei-output.txt) | No detectado |
| 3 | `http-missing-security-headers:cross-origin-opener-policy` | info | Corregido y verificado | `85fa833` | [`05-http-missing-security-headers-cross-origin-opener-policy.nuclei-output.txt`](05-http-missing-security-headers-cross-origin-opener-policy.nuclei-output.txt) | No detectado |
| 4 | `http-missing-security-headers:cross-origin-resource-policy` | info | Corregido y verificado | `6175d87` | [`06-http-missing-security-headers-cross-origin-resource-policy.nuclei-output.txt`](06-http-missing-security-headers-cross-origin-resource-policy.nuclei-output.txt) | No detectado |
| 5 | `http-missing-security-headers:strict-transport-security` | info | Corregido y verificado | `9ca71a6` | [`07-http-missing-security-headers-strict-transport-security.nuclei-output.txt`](07-http-missing-security-headers-strict-transport-security.nuclei-output.txt) | No detectado |
| 6 | `http-missing-security-headers:permissions-policy` | info | Corregido y verificado | `85e918a` | [`08-http-missing-security-headers-permissions-policy.nuclei-output.txt`](08-http-missing-security-headers-permissions-policy.nuclei-output.txt) | No detectado |
| 7 | `http-missing-security-headers:x-frame-options` | info | Corregido y verificado | `b8195f7` | [`09-http-missing-security-headers-x-frame-options.nuclei-output.txt`](09-http-missing-security-headers-x-frame-options.nuclei-output.txt) | No detectado |
| 8 | `http-missing-security-headers:x-permitted-cross-domain-policies` | info | Corregido y verificado | `b7e22a2` | [`10-http-missing-security-headers-x-permitted-cross-domain-policies.nuclei-output.txt`](10-http-missing-security-headers-x-permitted-cross-domain-policies.nuclei-output.txt) | No detectado |
| 9 | `http-missing-security-headers:referrer-policy` | info | Corregido y verificado | `b4e071f` | [`11-http-missing-security-headers-referrer-policy.nuclei-output.txt`](11-http-missing-security-headers-referrer-policy.nuclei-output.txt) | No detectado |
| 10 | `http-missing-security-headers:content-security-policy` | info | Corregido y verificado | `f44070b` | [`12-http-missing-security-headers-content-security-policy.nuclei-output.txt`](12-http-missing-security-headers-content-security-policy.nuclei-output.txt) | No detectado |
| 11 | `http-missing-security-headers:x-content-type-options` | info | Corregido y verificado | `a83e185` | [`13-http-missing-security-headers-x-content-type-options.nuclei-output.txt`](13-http-missing-security-headers-x-content-type-options.nuclei-output.txt) | No detectado |
| 12 | `http-missing-security-headers:cross-origin-embedder-policy` | info | Corregido y verificado | `46b5b72` | [`14-http-missing-security-headers-cross-origin-embedder-policy.nuclei-output.txt`](14-http-missing-security-headers-cross-origin-embedder-policy.nuclei-output.txt) | No detectado |
| 13 | `tech-detect:uvicorn` | info | Corregido y verificado | `ff2ccc9` | [`04-tech-detect-uvicorn.nuclei-output.txt`](04-tech-detect-uvicorn.nuclei-output.txt) | No detectado |
| 14 | `openapi` | info | Corregido y verificado | `2dea77d` | [`03-openapi.nuclei-output.txt`](03-openapi.nuclei-output.txt) | No detectado |

## Análisis completo posterior a las correcciones

Misma configuración que el análisis inicial (severidades `info,low,medium,high,critical`; etiquetas excluidas `dos, intrusive, fuzz, fuzzing, bruteforce, brute-force, default-login`; interactsh desactivado; rate limit 50 req/s).

| Campo | Valor |
|---|---|
| Fecha | 2026-10-19 09:22:42 → 11:02:25 (-06:00); el escaneo en sí duró 5 min según Nuclei |
| Objetivo | `http://api:8000` |
| Versión de Nuclei | v3.11.1 |
| Versión de plantillas | nuclei-templates v10.5.0 (la salida muestra la versión en blanco; ver Notas); 10160 plantillas cargadas |
| Código de salida | 0 |
| Resultado | Scan completed in 5m. 0 matches found. |
| Resultados completos | [`nuclei-results-after.jsonl`](nuclei-results-after.jsonl) · [salida de consola](nuclei-results-after.nuclei-output.txt) |

| Severidad | Antes | Después |
|---|---|---|
| critical | 0 | 0 |
| high | 0 | 0 |
| medium | 0 | 0 |
| low | 0 | 0 |
| info | 14 | 0 |
| **Total** | **14** | **0** |

**Nuclei no reportó hallazgos en el análisis completo posterior a las correcciones.**

## Notas

- **Versión de plantillas:** en la salida del análisis posterior la versión aparece en blanco con "(outdated)" porque la configuración de Nuclei (`~/.config/nuclei`) no persiste entre contenedores. Las plantillas son las del volumen descargado en el análisis inicial (nuclei-templates v10.5.0); `nuclei -ut` confirmó que la última versión publicada sigue siendo v10.5.0, y se cargaron las mismas 10160 plantillas que en el análisis inicial.
- **HSTS:** la cabecera `Strict-Transport-Security` está presente, pero los navegadores solo la aplican sobre HTTPS; en este laboratorio HTTP no tiene efecto práctico hasta que el servicio se publique con TLS.
- **Proxy:** los análisis se hicieron directamente contra el servicio, en la red interna. `dvj-proxy` (nginx con Fail2Ban) no se analizó y añade su propia cabecera `Server` a las respuestas que reenvía.
- **Cero hallazgos verificado:** el análisis posterior ejecutó 17436 de 17486 peticiones y `dvj-api` registró 6489 peticiones procedentes del contenedor de Nuclei; solo se omitieron puertos ajenos (4040, 5814).
- **Documentación de la API:** `/docs`, `/redoc` y `/openapi.json` quedan desactivados por defecto. Para desarrollo local se pueden activar con la variable de entorno `API_DOCS_ENABLED=true`.
- **Usuarios LDAP de prueba:** el directorio de `dvj-openldap` estaba vacío. Con autorización se cargó el seed del repositorio (`ldap/users.ldif`), solo para poder probar el login LDAP → JWT de punta a punta; no se modificó ninguna configuración.
- **Fuera del alcance de Nuclei (sin cambios):** en `/login`, el `username` se concatena en el DN sin escapar (`uid={username},ou=users,...`). Es un posible riesgo de inyección LDAP que Nuclei no reporta y queda pendiente de revisión.
