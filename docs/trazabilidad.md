# RIUL – Matriz de trazabilidad (Segundo corte)

Relación entre **requerimientos → prototipo (1er corte) → base de datos → interfaces HTML/CSS**.

| # | Prototipo (captura) | Requerimiento | Entidades en BD | Interfaz HTML |
|---|---|---|---|---|
| 1 | Inicio RIUL no. 1 | RF-01 | `publicaciones`, `semilleros`, `eventos`, `convocatorias` | `index.html` |
| 2 | Acceso y Registro RIUL no. 2 | RF-02, RF-03, RF-04 | `usuarios`, `solicitudes_registro`, `sesiones` | `login.html`, `registro.html` |
| 3 | Dashboard RIUL no. 3 | RF-31 | `vw_dashboard_administrador`, `notificaciones` | `dashboard.html` |
| 4 | Perfil RIUL no. 4 | RF-06, RF-27 | `usuarios`, `hoja_vida_investigativa`, `insignias_usuario` | `perfil.html` |
| 5 | Semilleros RIUL no. 5 | RF-07, RF-08, RF-09, RF-10, RF-18, RF-30 | `semilleros`, `semillero_integrantes`, `seguimientos_semillero` | `semilleros.html` |
| 6 | Proyectos RIUL no. 6 | RF-11, RF-12, RF-13 | `proyectos`, `avances_proyecto`, `productos_investigacion` | `proyectos.html` |
| 7 | Publicaciones RIUL no. 7 | RF-14, RF-15, RF-33 | `publicaciones`, `categorias_publicacion`, `reacciones`, `comentarios`, `compartidos` | `publicaciones.html` |
| 8 | Eventos RIUL no. 8 | RF-16, RF-17 | `eventos`, `participaciones_evento`, `convocatorias`, `postulaciones` | `eventos.html` |
| 9 | Logros RIUL no. 9 | RF-20 a RF-26 | `logros`, `movimientos_experiencia`, `insignias`, `niveles`, `criterios_progresion` | `logros.html` |
| 10 | Panel Admin RIUL no. 10 | RF-04, RF-28, RF-29, RF-30, RF-32 | `solicitudes_registro`, `usuarios`, `facultades`, `programas`, `semilleros`, `reportes`, `bitacora_acciones` | `admin.html` |

## Cobertura por criterio de evaluación

| Criterio | Peso | Evidencia en el proyecto |
|---|---|---|
| 1. Diseño de la base de datos | 1.50 | `database/schema.sql` (30 tablas, 3 vistas, 49 FK), `docs/diccionario_datos.md` |
| 2. Implementación HTML y CSS | 1.50 | `src/*.html` (11 pantallas), `src/css/styles.css` |
| 3. Estructura y organización | 0.75 | `docs/`, `database/`, `src/`, `README.md` |
| 4. Implementación con Docker | 0.75 | `Dockerfile`, `docker-compose.yml` |
| 5. Coherencia e integración | 0.50 | Esta matriz de trazabilidad |

## Coherencia con actores (RF-05)

| Rol | Interfaces que usa |
|---|---|
| Visitante | `index.html`, `login.html`, `registro.html`, `publicaciones.html` (visibilidad pública) |
| Estudiante investigador | `dashboard.html`, `semilleros.html`, `proyectos.html`, `publicaciones.html`, `eventos.html`, `logros.html`, `perfil.html` |
| Docente líder | + gestión de semillero y avances en `semilleros.html` y `proyectos.html` |
| Administrador | `admin.html` + todas las anteriores |
