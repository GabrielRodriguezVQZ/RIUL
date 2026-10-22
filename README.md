# RIUL – Red de Investigación Universidad Libre

Prototipo técnico del **segundo corte**: estructura de base de datos, interfaces HTML/CSS, organización del proyecto y entorno de ejecución con Docker.

> Sistema de Investigación – Universidad Libre · Programación Web
> Estudiantes: María Angel Duque Polo, Gabriel Enrique Rodríguez Vásquez, Juan David Berrocal Sanchez

---

## Estructura del proyecto

```
RIUL/
├── README.md                     ← Este documento
├── Dockerfile                    ← Imagen Docker (Nginx + interfaces)
├── docker-compose.yml            ← Orquestación web + api + MySQL
├── docker/
│   └── nginx.conf                ← Configuración del servidor web (y proxy /api)
├── backend/
│   ├── Dockerfile                ← Imagen Docker de la API
│   ├── requirements.txt          ← Dependencias Python (fastapi, uvicorn, PyMySQL, bcrypt)
│   └── main.py                   ← API Python/FastAPI: registro, login y Swagger
├── database/
│   ├── schema.sql                ← Modelo de datos (30 tablas, 3 vistas)
│   └── seed.sql                  ← Datos de ejemplo coherentes
├── docs/
│   ├── diccionario_datos.md      ← Entidades, atributos, claves y relaciones
│   └── trazabilidad.md           ← Requerimientos ↔ prototipo ↔ BD ↔ interfaces
└── src/
    ├── index.html                ← 1. Inicio (consulta pública)
    ├── login.html                ← 2. Acceso
    ├── registro.html             ← 2. Registro
    ├── dashboard.html            ← 3. Dashboard por rol
    ├── perfil.html               ← 4. Perfil y hoja de vida
    ├── semilleros.html           ← 5. Semilleros
    ├── proyectos.html            ← 6. Proyectos
    ├── publicaciones.html        ← 7. Publicaciones
    ├── eventos.html              ← 8. Eventos y convocatorias
    ├── logros.html               ← 9. Logros y gamificación
    ├── admin.html                ← 10. Panel de administración
    ├── css/
    │   └── styles.css            ← Hoja de estilos compartida
    └── js/
        ├── registro.js           ← Envía el registro a /api/registro
        └── login.js              ← Envía el acceso a /api/login
```

---

## Ejecución con Docker (recomendada)

**Requisitos:** Docker Desktop instalado y en ejecución.

```bash
cd RIUL
docker compose up --build
```

| Servicio | URL / Puerto | Contenido |
|---|---|---|
| `riul-web` | http://localhost:8080 | Interfaces HTML/CSS (Nginx) y proxy de `/api/` hacia la API |
| `riul-api` | http://localhost:3000 | API Python/FastAPI (registro y login) · Swagger en `/api/docs` |
| `riul-db`  | localhost:3306 | MySQL 8.0 con `schema.sql` y `seed.sql` cargados al iniciar |

- La base de datos se **crea y puebla automáticamente** en el primer arranque (carpetas `docker-entrypoint-initdb.d`).
- Para detener: `docker compose down`
- Para reiniciar **desde cero** (borra los datos): `docker compose down -v`

## Registro y acceso de usuarios

El formulario de registro guarda en MySQL y el login valida contra la base de datos.

| Método | Ruta | Qué hace |
|---|---|---|
| POST | `/api/registro` | Crea el usuario con estado `pendiente` y su solicitud en `solicitudes_registro` (RF-02, RF-04) |
| POST | `/api/login` | Valida correo y contraseña (bcrypt). Solo entran usuarios `activo` (RF-03, RNF-02) |
| GET | `/api/health` | Comprueba que la API y la base de datos responden |
| GET | `/api/docs` | Documentación interactiva **Swagger UI** (especificación en `/api/openapi.json`) |

- **Swagger UI:** http://localhost:8080/api/docs (o http://localhost:3000/api/docs). Permite probar cada endpoint con el botón *Try it out*. La especificación se genera sola a partir de `backend/main.py` (modelos y decoradores de cada endpoint), así que siempre coincide con el código. La interfaz de Swagger carga sus archivos desde internet (CDN), por lo que necesita conexión.
- Las contraseñas se guardan con **bcrypt**, nunca en texto legible.
- Desde el registro público solo se pueden solicitar los roles *estudiante investigador* y *docente líder*.
- Una cuenta nueva queda `pendiente` hasta que un administrador la apruebe. Para que quede registrado **quién** la aprobó y **cuándo** (RNF-13), se actualizan las dos tablas:
  ```sql
  START TRANSACTION;
  UPDATE solicitudes_registro
     SET estado = 'aprobada',
         revisado_por = (SELECT id FROM (SELECT id FROM usuarios WHERE rol = 'administrador' LIMIT 1) a),
         fecha_respuesta = NOW()
   WHERE usuario_id = (SELECT id FROM (SELECT id FROM usuarios WHERE email = 'correo@unilibre.edu.co') b);
  UPDATE usuarios SET estado = 'activo' WHERE email = 'correo@unilibre.edu.co';
  COMMIT;
  ```
- **Cuentas de prueba** (seed): contraseña `Riul2026*` para todas. Por ejemplo `maria.duque@unilibre.edu.co` (activa). Los usuarios con estado `pendiente` en el seed no pueden iniciar sesión.

## Ejecución sin Docker

```bash
# Abrir directamente en el navegador (solo para ver las interfaces)
start src\index.html
```

> Sin Docker el registro y el login no funcionan, porque necesitan la API y la base de datos. Usa `docker compose up --build` y abre http://localhost:8080.

---

## Base de datos

- **Motor:** MySQL 8.0 (`utf8mb4`)
- **Tablas:** 30 · **Vistas de indicadores:** 3 · **Relaciones FK:** 49
- **Normalización:** 3FN (catálogos y tablas intermedias)
- Documentación completa en [`docs/diccionario_datos.md`](docs/diccionario_datos.md)

Consulta rápida de las vistas:

```sql
USE riul;
SELECT * FROM vw_ranking_usuarios;
SELECT * FROM vw_indicadores_publicaciones;
SELECT * FROM vw_dashboard_administrador;
```

---

## Interfaces HTML/CSS

11 pantallas estáticas fieles al prototipo del primer corte, con datos de ejemplo provenientes del `seed.sql`.

| Captura del prototipo | Interfaz |
|---|---|
| Inicio RIUL no. 1 | `src/index.html` |
| Acceso y Registro no. 2 | `src/login.html`, `src/registro.html` |
| Dashboard no. 3 | `src/dashboard.html` |
| Perfil no. 4 | `src/perfil.html` |
| Semilleros no. 5 | `src/semilleros.html` |
| Proyectos no. 6 | `src/proyectos.html` |
| Publicaciones no. 7 | `src/publicaciones.html` |
| Eventos no. 8 | `src/eventos.html` |
| Logros no. 9 | `src/logros.html` |
| Panel Admin no. 10 | `src/admin.html` |

Características: diseño adaptable (RNF-07), contraste accesible (RNF-06), navegación consistente (RNF-15) y un único CSS compartido para toda la plataforma.

---

## Trazabilidad

La matriz completa requerimientos → prototipo → BD → interfaces está en [`docs/trazabilidad.md`](docs/trazabilidad.md).
