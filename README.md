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
├── docker-compose.yml            ← Orquestación web + MySQL
├── docker/
│   └── nginx.conf                ← Configuración del servidor web
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
    └── css/
        └── styles.css            ← Hoja de estilos compartida
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
| `riul-web` | http://localhost:8080 | Interfaces HTML/CSS (Nginx) |
| `riul-db`  | localhost:3306 | MySQL 8.0 con `schema.sql` y `seed.sql` cargados al iniciar |

- La base de datos se **crea y puebla automáticamente** en el primer arranque (carpetas `docker-entrypoint-initdb.d`).
- Para detener: `docker compose down`
- Para reiniciar **desde cero** (borra los datos): `docker compose down -v`

## Ejecución sin Docker

```bash
# Abrir directamente en el navegador
start src\index.html
```

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
