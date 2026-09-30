import os
from datetime import datetime, timedelta, timezone

import jwt
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from ldap3 import Server, Connection, ALL

LDAP_HOST = os.getenv("LDAP_HOST", "openldap")
LDAP_PORT = int(os.getenv("LDAP_PORT", "389"))
LDAP_BASE_DN = os.getenv("LDAP_BASE_DN", "dc=example,dc=com")

# The signing key must come from the environment; never fall back to a fixed key.
JWT_SECRET = os.getenv("JWT_SECRET", "").strip()
if not JWT_SECRET:
    raise RuntimeError(
        "JWT_SECRET is not set. Define it in ldap/.env (see .env.example)."
    )
JWT_ALGORITHM = "HS256"
JWT_EXPIRATION = timedelta(hours=1)

# Frontend allowed to call this API from the browser (Vite dev server).
CORS_ALLOWED_ORIGINS = ["http://localhost:5173"]

app = FastAPI(
    title="LDAP Authentication API",
    description="Educational FastAPI + OpenLDAP example",
    version="1.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ALLOWED_ORIGINS,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Content-Type"],
)


class LoginRequest(BaseModel):
    username: str
    password: str


def create_token(username: str, user_dn: str) -> str:
    issued_at = datetime.now(timezone.utc)
    payload = {
        "sub": username,
        "dn": user_dn,
        "iat": issued_at,
        "exp": issued_at + JWT_EXPIRATION,
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/login")
def login(request: LoginRequest):
    # An empty password would make ldap3 fail with a 500 (and some LDAP servers
    # treat it as an anonymous bind), so reject empty input up front.
    if not request.username.strip() or not request.password:
        raise HTTPException(
            status_code=400,
            detail="Username and password are required",
        )

    server = Server(
        LDAP_HOST,
        port=LDAP_PORT,
        get_info=ALL,
    )

    user_dn = (
        f"uid={request.username},"
        f"ou=users,"
        f"{LDAP_BASE_DN}"
    )

    connection = Connection(
        server,
        user=user_dn,
        password=request.password,
        auto_bind=False,
    )

    try:
        if connection.bind():
            return {
                "authenticated": True,
                "username": request.username,
                "dn": user_dn,
                "token": create_token(request.username, user_dn),
            }

        raise HTTPException(
            status_code=401,
            detail="Invalid username or password",
        )

    finally:
        connection.unbind()
