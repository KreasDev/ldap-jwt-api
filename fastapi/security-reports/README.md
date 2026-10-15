# Análisis de vulnerabilidades con Nuclei — LDAP / JWT API (dvj-api)

## Datos del análisis

| Campo | Valor |
|---|---|
| Fecha | 2026-10-14 22:08:35 -06:00 → 22:15:04 |
| Objetivo analizado | `http://api:8000` (URL interna de la red Docker bridge `security-stack_appnet`) |
| Herramienta | ProjectDiscovery Nuclei (imagen `projectdiscovery/nuclei:latest` del laboratorio) |
| Versión de Nuclei | v3.11.1 |
| Versión de plantillas | nuclei-templates v10.5.0 (actualizadas con `-ut` antes del análisis); 10160 plantillas cargadas |
| Severidades | `info,low,medium,high,critical` |
| Plantillas excluidas | etiquetas `dos, intrusive, fuzz, fuzzing, bruteforce, brute-force, default-login` |
| Otras opciones | interactsh desactivado (`-ni`), rate limit 50 req/s, timeout 10 s, 1 reintento |
| Código de salida | 0 (escaneo completado) |
| Errores de petición reportados | 239 (contador de peticiones fallidas de Nuclei; incluye plantillas que prueban otros puertos, p. ej. `:4040` y `:5814`, con conexión rechazada. No afectó al análisis: el puerto objetivo respondió y el escaneo terminó con código 0) |
| Resultados completos | [`nuclei-results.jsonl`](nuclei-results.jsonl) |

## Resumen por severidad

| Severidad | Hallazgos |
|---|---|
| critical | 0 |
| high | 0 |
| medium | 0 |
| low | 0 |
| info | 14 |
| **Total** | **14** |

Nuclei no reportó hallazgos de severidad low, medium, high ni critical; todos los resultados son informativos.

## Hallazgos reportados por Nuclei

| # | Severidad | Plantilla | Nombre | Detalle | Ubicación |
|---|---|---|---|---|---|
| 1 | info | `swagger-api` | Public Swagger API - Detect | — | `http://api:8000/docs` |
| 2 | info | `redoc-api-docs` | ReDoc API Docs - Detect | — | `http://api:8000/redoc` |
| 3 | info | `http-missing-security-headers` | HTTP Missing Security Headers | cross-origin-opener-policy | `http://api:8000` |
| 4 | info | `http-missing-security-headers` | HTTP Missing Security Headers | cross-origin-resource-policy | `http://api:8000` |
| 5 | info | `http-missing-security-headers` | HTTP Missing Security Headers | strict-transport-security | `http://api:8000` |
| 6 | info | `http-missing-security-headers` | HTTP Missing Security Headers | permissions-policy | `http://api:8000` |
| 7 | info | `http-missing-security-headers` | HTTP Missing Security Headers | x-frame-options | `http://api:8000` |
| 8 | info | `http-missing-security-headers` | HTTP Missing Security Headers | x-permitted-cross-domain-policies | `http://api:8000` |
| 9 | info | `http-missing-security-headers` | HTTP Missing Security Headers | referrer-policy | `http://api:8000` |
| 10 | info | `http-missing-security-headers` | HTTP Missing Security Headers | content-security-policy | `http://api:8000` |
| 11 | info | `http-missing-security-headers` | HTTP Missing Security Headers | x-content-type-options | `http://api:8000` |
| 12 | info | `http-missing-security-headers` | HTTP Missing Security Headers | cross-origin-embedder-policy | `http://api:8000` |
| 13 | info | `tech-detect` | Wappalyzer Technology Detection | uvicorn | `http://api:8000` |
| 14 | info | `openapi` | OpenAPI - Detect | — | `http://api:8000/openapi.json` |

## Notas

- El escaneo se ejecutó contra el contenedor del servicio directamente por la red interna, no a través del proxy `dvj-proxy`, porque este aplica Fail2Ban (límite de peticiones por segundo) y habría bloqueado al escáner.
- Este informe solo documenta los resultados obtenidos; todavía no se ha corregido ninguna vulnerabilidad.
- Los resultados no incluyen credenciales, JWT ni tokens: el análisis se realizó sin autenticación.
