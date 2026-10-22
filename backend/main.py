"""
RIUL - API (registro y acceso de usuarios) · Python + FastAPI

  POST /api/registro  -> RF-02 / RF-04: crea usuario 'pendiente' + solicitud
  POST /api/login     -> RF-03 / RNF-02: valida credenciales (bcrypt)
  GET  /api/health    -> verificación de que la API y la BD responden
  GET  /api/docs      -> documentación Swagger UI (OpenAPI generado automáticamente)
"""

import os
import re
from contextlib import contextmanager
from typing import Optional

import bcrypt
import pymysql
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.openapi.utils import get_openapi
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, StrictBool, StrictStr
from starlette.exceptions import HTTPException as StarletteHTTPException

# ---------------------------------------------------------------------
# Configuración (variables de entorno definidas en docker-compose.yml)
# ---------------------------------------------------------------------
DB_CONFIG = dict(
    host=os.getenv("DB_HOST", "localhost"),
    port=int(os.getenv("DB_PORT", "3306")),
    user=os.getenv("DB_USER", "riul"),
    password=os.getenv("DB_PASSWORD", "riul2026"),
    database=os.getenv("DB_NAME", "riul"),
    charset="utf8mb4",
    cursorclass=pymysql.cursors.DictCursor,
    autocommit=False,
    connect_timeout=5,
)

# Solo estos roles se pueden solicitar desde el registro público.
# 'administrador' y 'visitante' NUNCA se asignan desde aquí.
ROLES_PERMITIDOS = {"estudiante_investigador", "docente_lider"}

EMAIL_RE = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")
DOC_RE = re.compile(r"^[0-9A-Za-z-]{5,20}$")

# Hash falso para que /login tarde parecido exista o no el correo
HASH_FALSO = bcrypt.hashpw(b"contrasena-inexistente", bcrypt.gensalt(10))


@contextmanager
def conexion():
    """Abre una conexión a MySQL y la cierra siempre al terminar."""
    con = pymysql.connect(**DB_CONFIG)
    try:
        yield con
    finally:
        con.close()


# ---------------------------------------------------------------------
# Modelos (alimentan la documentación Swagger)
# ---------------------------------------------------------------------
class RegistroRequest(BaseModel):
    nombre: StrictStr = Field("", description="Máx. 80 caracteres.", examples=["Ana María"])
    apellido: StrictStr = Field("", description="Máx. 80 caracteres.", examples=["Pérez Gil"])
    identificacion: StrictStr = Field(
        "", description="Documento de identidad (5 a 20 caracteres, letras, números o guion).",
        examples=["1098765432"])
    telefono: StrictStr = Field("", description="Opcional. Máx. 20 caracteres.", examples=["300 111 2233"])
    email: StrictStr = Field("", description="Correo; se guarda en minúsculas.",
                             examples=["ana.perez@unilibre.edu.co"])
    programa: StrictStr = Field(
        "", description="Código del programa académico.",
        json_schema_extra={"enum": ["IS-01", "II-02", "PS-03", "AE-04", "EN-05", "DE-06"]},
        examples=["IS-01"])
    rol: StrictStr = Field(
        "", description="Rol solicitado. El rol de administrador no se puede pedir por este medio.",
        json_schema_extra={"enum": ["estudiante_investigador", "docente_lider"]},
        examples=["estudiante_investigador"])
    password: StrictStr = Field("", description="Entre 8 y 72 caracteres.", examples=["MiClave123"],
                                json_schema_extra={"format": "password"})
    password2: StrictStr = Field("", description="Confirmación; debe ser igual a `password`.",
                                 examples=["MiClave123"], json_schema_extra={"format": "password"})
    motivacion: StrictStr = Field(
        "", description="Opcional. Apoya la revisión institucional (RF-04). Máx. 2000 caracteres.",
        examples=["Me interesa la investigación en inteligencia artificial."])
    aceptoDatos: StrictBool = Field(
        False, description="Debe ser `true` (tratamiento de datos personales, RNF-03).", examples=[True])


class LoginRequest(BaseModel):
    email: StrictStr = Field("", examples=["maria.duque@unilibre.edu.co"])
    password: StrictStr = Field("", examples=["Riul2026*"], json_schema_extra={"format": "password"})


class RegistroOk(BaseModel):
    ok: bool = True
    mensaje: str = "Solicitud enviada. Un administrador la revisará y activará tu cuenta."


class Usuario(BaseModel):
    id: int = Field(examples=[1])
    nombre: str = Field(examples=["María Angel"])
    apellido: str = Field(examples=["Duque Polo"])
    email: str = Field(examples=["maria.duque@unilibre.edu.co"])
    rol: str = Field(examples=["estudiante_investigador"],
                     json_schema_extra={"enum": ["estudiante_investigador", "docente_lider",
                                                 "administrador", "visitante"]})


class LoginOk(BaseModel):
    ok: bool = True
    usuario: Usuario


class ErrorResp(BaseModel):
    ok: bool = False
    mensaje: str = Field(description="Mensaje listo para mostrar al usuario.")
    errores: Optional[list[str]] = Field(
        None, description="Todos los errores de validación (solo en respuestas 400 del registro).")


class HealthResp(BaseModel):
    ok: bool
    bd: str


def ejemplo_error(mensaje: str) -> dict:
    return {"application/json": {"example": {"ok": False, "mensaje": mensaje}}}


# ---------------------------------------------------------------------
# Aplicación
# ---------------------------------------------------------------------
app = FastAPI(
    title="RIUL API",
    version="1.0.0",
    description=(
        "API de **RIUL – Red de Investigación Universidad Libre**.\n\n"
        "Cubre el registro de usuarios con validación institucional (RF-02, RF-04) "
        "y el acceso a la plataforma (RF-03, RNF-02).\n\n"
        "**Flujo:** una cuenta nueva queda en estado `pendiente` hasta que un administrador "
        "la active; solo las cuentas `activo` pueden iniciar sesión.\n\n"
        "**Cuentas de prueba (seed):** contraseña `Riul2026*`, por ejemplo "
        "`maria.duque@unilibre.edu.co` (activa)."
    ),
    docs_url="/api/docs",
    redoc_url=None,
    openapi_url="/api/openapi.json",
    openapi_tags=[
        {"name": "Registro", "description": "Solicitud de cuenta (RF-02, RF-04)"},
        {"name": "Acceso", "description": "Autenticación (RF-03, RNF-02)"},
        {"name": "Sistema", "description": "Estado del servicio"},
    ],
)


def openapi_personalizado():
    """OpenAPI sin el 422 automático de FastAPI: esta API responde 400 con {ok, mensaje}."""
    if app.openapi_schema:
        return app.openapi_schema
    esquema = get_openapi(title=app.title, version=app.version, description=app.description,
                          routes=app.routes, tags=app.openapi_tags)
    for operaciones in esquema["paths"].values():
        for operacion in operaciones.values():
            operacion["responses"].pop("422", None)
    for nombre in ("HTTPValidationError", "ValidationError"):
        esquema.get("components", {}).get("schemas", {}).pop(nombre, None)
    app.openapi_schema = esquema
    return esquema


app.openapi = openapi_personalizado


def error(status: int, mensaje: str, **extra) -> JSONResponse:
    return JSONResponse(status_code=status, content={"ok": False, "mensaje": mensaje, **extra})


# --- Errores con el mismo formato {ok, mensaje} que usa el frontend ---
@app.exception_handler(RequestValidationError)
async def validacion_handler(_req: Request, _exc: RequestValidationError):
    return error(400, "Solicitud inválida.")


@app.exception_handler(StarletteHTTPException)
async def http_handler(_req: Request, exc: StarletteHTTPException):
    mensajes = {404: "Ruta no encontrada.", 405: "Método no permitido."}
    return error(exc.status_code, mensajes.get(exc.status_code, "Error en la solicitud."))


# ---------------------------------------------------------------------
# GET /api/health
# ---------------------------------------------------------------------
@app.get("/api/health", tags=["Sistema"], summary="Estado de la API y de la base de datos",
         response_model=HealthResp,
         responses={503: {"description": "La API responde pero no logra conectar con la base de datos.",
                          "model": HealthResp}})
def health():
    try:
        with conexion() as con, con.cursor() as cur:
            cur.execute("SELECT 1")
        return {"ok": True, "bd": "conectada"}
    except Exception as e:  # noqa: BLE001
        print("Health:", e)
        return JSONResponse(status_code=503, content={"ok": False, "bd": "sin conexión"})


# ---------------------------------------------------------------------
# POST /api/registro
# ---------------------------------------------------------------------
@app.post(
    "/api/registro", tags=["Registro"], summary="Solicitar registro de usuario",
    description=("Crea el usuario con estado `pendiente` y su solicitud en `solicitudes_registro`, "
                 "en una sola transacción. La contraseña se almacena cifrada con bcrypt. "
                 "Desde este endpoint **no** se puede solicitar el rol `administrador`."),
    status_code=201, response_model=RegistroOk,
    responses={
        201: {"description": "Solicitud creada; la cuenta queda pendiente de aprobación."},
        400: {"model": ErrorResp,
              "description": "Datos inválidos (campo vacío, contraseñas distintas, rol o programa inexistente, "
                             "datos personales no aceptados, JSON mal formado).",
              "content": {"application/json": {"example": {
                  "ok": False, "mensaje": "Las contraseñas no coinciden.",
                  "errores": ["Las contraseñas no coinciden."]}}}},
        409: {"model": ErrorResp, "description": "Ya existe una cuenta con ese correo o documento de identidad.",
              "content": ejemplo_error("Ya existe una cuenta con ese correo.")},
        500: {"model": ErrorResp, "description": "Error interno del servidor.",
              "content": ejemplo_error("Error interno del servidor.")},
    },
)
def registro(b: RegistroRequest):
    nombre, apellido = b.nombre.strip(), b.apellido.strip()
    identificacion, telefono = b.identificacion.strip(), b.telefono.strip()
    email = b.email.strip().lower()
    programa, rol = b.programa.strip(), b.rol.strip()
    motivacion = b.motivacion.strip()
    password, password2 = b.password, b.password2

    # --- Validaciones ---
    errores = []
    if not nombre or len(nombre) > 80:
        errores.append("Los nombres son obligatorios (máx. 80 caracteres).")
    if not apellido or len(apellido) > 80:
        errores.append("Los apellidos son obligatorios (máx. 80 caracteres).")
    if not DOC_RE.match(identificacion):
        errores.append("El documento de identidad no es válido.")
    if len(telefono) > 20:
        errores.append("El teléfono es demasiado largo (máx. 20 caracteres).")
    if not EMAIL_RE.match(email) or len(email) > 150:
        errores.append("El correo no es válido.")
    if not programa:
        errores.append("Selecciona tu programa.")
    if rol not in ROLES_PERMITIDOS:
        errores.append("El rol solicitado no es válido.")
    if len(password) < 8:
        errores.append("La contraseña debe tener mínimo 8 caracteres.")
    if len(password.encode("utf-8")) > 72:
        errores.append("La contraseña es demasiado larga (máx. 72 caracteres).")
    if password != password2:
        errores.append("Las contraseñas no coinciden.")
    if len(motivacion) > 2000:
        errores.append("La motivación es demasiado larga (máx. 2000 caracteres).")
    if b.aceptoDatos is not True:
        errores.append("Debes aceptar el tratamiento de datos personales.")

    if errores:
        return error(400, errores[0], errores=errores)

    try:
        with conexion() as con:
            with con.cursor() as cur:
                cur.execute("SELECT id FROM programas WHERE codigo = %s AND estado = 'activo'", (programa,))
                prog = cur.fetchone()
                if prog is None:
                    return error(400, "El programa seleccionado no existe.")

                hash_pw = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt(10)).decode("ascii")  # RNF-02

                try:
                    cur.execute(
                        """INSERT INTO usuarios
                               (programa_id, identificacion, nombre, apellido, email,
                                password_hash, telefono, rol, estado)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'pendiente')""",
                        (prog["id"], identificacion, nombre, apellido, email,
                         hash_pw, telefono or None, rol),
                    )
                    usuario_id = cur.lastrowid
                    cur.execute(
                        "INSERT INTO solicitudes_registro (usuario_id, motivacion) VALUES (%s, %s)",
                        (usuario_id, motivacion or None),
                    )
                    con.commit()
                except pymysql.err.IntegrityError as e:
                    con.rollback()
                    if e.args and e.args[0] == 1062:  # entrada duplicada
                        campo = "correo" if "email" in str(e.args[1]).lower() else "documento de identidad"
                        return error(409, f"Ya existe una cuenta con ese {campo}.")
                    raise
                except Exception:
                    con.rollback()
                    raise

        return JSONResponse(status_code=201, content={
            "ok": True,
            "mensaje": "Solicitud enviada. Un administrador la revisará y activará tu cuenta.",
        })
    except Exception as e:  # noqa: BLE001
        print("Registro:", repr(e))
        return error(500, "Error interno del servidor.")


# ---------------------------------------------------------------------
# POST /api/login
# ---------------------------------------------------------------------
@app.post(
    "/api/login", tags=["Acceso"], summary="Iniciar sesión",
    description=("Valida correo y contraseña. Solo los usuarios con estado `activo` pueden entrar. "
                 "Ante credenciales incorrectas responde siempre el mismo mensaje, exista o no el correo."),
    response_model=LoginOk,
    responses={
        200: {"description": "Credenciales correctas."},
        400: {"model": ErrorResp, "description": "Faltan el correo o la contraseña.",
              "content": ejemplo_error("Ingresa tu correo y tu contraseña.")},
        401: {"model": ErrorResp, "description": "Correo o contraseña incorrectos.",
              "content": ejemplo_error("Correo o contraseña incorrectos.")},
        403: {"model": ErrorResp,
              "description": "La cuenta existe pero no está activa (pendiente de aprobación, rechazada o suspendida).",
              "content": ejemplo_error("Tu solicitud aún está pendiente de aprobación por el administrador.")},
        500: {"model": ErrorResp, "description": "Error interno del servidor.",
              "content": ejemplo_error("Error interno del servidor.")},
    },
)
def login(b: LoginRequest):
    email = b.email.strip().lower()
    password = b.password

    if not email or not password:
        return error(400, "Ingresa tu correo y tu contraseña.")

    try:
        with conexion() as con:
            with con.cursor() as cur:
                cur.execute(
                    "SELECT id, nombre, apellido, email, password_hash, rol, estado "
                    "FROM usuarios WHERE email = %s", (email,))
                u = cur.fetchone()

                # Se compara siempre, exista o no el usuario
                hash_guardado = u["password_hash"].encode("utf-8") if u else HASH_FALSO
                try:
                    coincide = bcrypt.checkpw(password.encode("utf-8")[:72], hash_guardado)
                except ValueError:  # hash inválido en BD
                    coincide = False

                if u is None or not coincide:
                    return error(401, "Correo o contraseña incorrectos.")
                if u["estado"] == "pendiente":
                    return error(403, "Tu solicitud aún está pendiente de aprobación por el administrador.")
                if u["estado"] != "activo":
                    return error(403, "Tu cuenta no está activa. Contacta al administrador.")

                cur.execute("UPDATE usuarios SET ultimo_acceso = NOW() WHERE id = %s", (u["id"],))
                con.commit()

                return {"ok": True, "usuario": {
                    "id": u["id"], "nombre": u["nombre"], "apellido": u["apellido"],
                    "email": u["email"], "rol": u["rol"]}}
    except Exception as e:  # noqa: BLE001
        print("Login:", repr(e))
        return error(500, "Error interno del servidor.")
