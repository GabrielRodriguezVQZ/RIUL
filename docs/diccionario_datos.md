# RIUL – Diccionario de datos

**Sistema:** Red de Investigación Universidad Libre (RIUL)
**Motor:** MySQL 8.0 · **Código de caracteres:** utf8mb4
**Archivos relacionados:** `database/schema.sql`, `database/seed.sql`

---

## 1. Módulo: Usuarios

| Entidad | Descripción | Requerimiento |
|---|---|---|
| `facultades` | Facultades institucionales | RF-29 |
| `programas` | Programas académicos por facultad | RF-29 |
| `usuarios` | Cuentas de todos los actores del sistema | RF-02, RF-03, RF-05, RF-06, RF-28 |
| `solicitudes_registro` | Solicitud y validación institucional de cuentas | RF-04 |
| `sesiones` | Sesiones activas de autenticación | RF-03, RNF-01 |
| `notificaciones` | Notificaciones generadas por el sistema | RF-19 |

### `usuarios`
| Campo | Tipo | Clave | Restricciones / Descripción |
|---|---|---|---|
| id | INT AUTO_INCREMENT | PK | Identificador único del usuario |
| programa_id | INT | FK → programas(id) | ON DELETE SET NULL |
| identificacion | VARCHAR(20) | UK | Documento de identidad |
| nombre / apellido | VARCHAR(80) | – | Datos personales |
| email | VARCHAR(150) | UK | Correo institucional (RF-03) |
| password_hash | VARCHAR(255) | – | Hash de contraseña, nunca texto legible (RNF-02) |
| rol | ENUM | – | administrador / docente_lider / estudiante_investigador / visitante (RF-05) |
| estado | ENUM | – | pendiente / activo / rechazado / suspendido (RF-04, RF-28) |
| xp_acumulado | INT | – | XP total validado (RF-22, RF-25) |
| nivel | INT | – | Nivel alcanzado (RF-25) |
| estrellas | TINYINT | – | Escala 1 a 5 (RF-24) |
| posicion_ranking | INT | – | Posición en ranking (RF-26) |
| fecha_registro / ultimo_acceso | TIMESTAMP / DATETIME | – | Auditoría básica |

---

## 2. Módulo: Investigación

| Entidad | Descripción | Requerimiento |
|---|---|---|
| `semilleros` | Semilleros de investigación | RF-07, RF-10, RF-30 |
| `semillero_integrantes` | Vinculación estudiantes ↔ semilleros con estado | RF-08, RF-09 |
| `seguimientos_semillero` | Usuarios que siguen un semillero | RF-18 |
| `proyectos` | Proyectos de investigación | RF-11 |
| `avances_proyecto` | Avances/publicaciones de avances | RF-12 |
| `productos_investigacion` | Productos asociados a usuario/semillero/proyecto | RF-13 |
| `eventos` | Eventos investigativos | RF-16 |
| `participaciones_evento` | Inscripción y asistencia a eventos | RF-16 |
| `convocatorias` | Convocatorias publicadas por el administrador | RF-17 |
| `postulaciones` | Postulaciones de usuarios a convocatorias | RF-17 |
| `hoja_vida_investigativa` | Hoja de vida investigativa consolidada | RF-27 |

Relaciones clave:
- `semilleros.docente_lider_id` → `usuarios.id` (1:N obligatoria: cada semillero tiene un docente líder).
- `semillero_integrantes` es la **tabla intermedia** N:N entre `semilleros` y `usuarios`, con estados `solicitado/aprobado/rechazado/retirado`.
- `productos_investigacion` admite asociación a proyecto, semillero o usuario (CHECK garantiza al menos una).
- `proyectos` ⊆ `semilleros`; `avances_proyecto` ⊆ `proyectos`.

---

## 3. Módulo: Comunidad

| Entidad | Descripción | Requerimiento |
|---|---|---|
| `categorias_publicacion` | Categorías de publicación | RF-14 |
| `publicaciones` | Publicaciones de la comunidad | RF-14, RF-01, RF-33 |
| `reacciones` | Reacciones (me gusta, me inspira, apoyo, destacado) | RF-15 |
| `comentarios` | Comentarios con respuestas (autorreferencia) | RF-15 |
| `compartidos` | Compartir publicaciones | RF-15 |

- `publicaciones.visibilidad = 'publica'` alimenta la **consulta pública del visitante (RF-01)**.
- `publicaciones.vistas` + `reacciones` + `comentarios` + `compartidos` alimentan la **vista `vw_indicadores_publicaciones` (RF-33)**.

---

## 4. Módulo: Gamificación

| Entidad | Descripción | Requerimiento |
|---|---|---|
| `logros` | Logros/actividades con validación administrativa | RF-20, RF-21 |
| `niveles` | Configuración de niveles y XP requerida | RF-25 |
| `insignias` | Catálogo de insignias | RF-23 |
| `insignias_usuario` | Otorgamiento de insignias a usuarios | RF-23 |
| `movimientos_experiencia` | Historial de puntos XP otorgados | RF-22 |
| `criterios_progresion` | Criterios de estrellas, niveles y ranking | RF-24, RF-25, RF-26 |

Flujo: `logros.estado = pendiente` → administrador valida (`RF-21`) → si `aprobado`, se escribe en `movimientos_experiencia` (**RF-22**) → se actualiza `usuarios.xp_acumulado`, `nivel`, `estrellas` (**RF-24, RF-25**) → se otorgan `insignias_usuario` (**RF-23**) → se recalcula `posicion_ranking` (**RF-26**).

---

## 5. Módulo: Analítica y trazabilidad

| Entidad | Descripción | Requerimiento |
|---|---|---|
| `bitacora_acciones` | Registro de operaciones críticas | RNF-13 |
| `reportes` | Reportes generados por el administrador | RF-32 |
| `vw_ranking_usuarios` | Ranking de investigadores por XP | RF-26 |
| `vw_indicadores_publicaciones` | Métricas de impacto por publicación | RF-32, RF-33 |
| `vw_dashboard_administrador` | Indicadores globales del panel admin | RF-31, RF-32 |

---

## Resumen del modelo

| Métrica | Cantidad |
|---|---|
| Tablas | 30 |
| Vistas de indicadores | 3 |
| Relaciones FK | 49 |
| Restricciones UNIQUE / INDEX | 5 / 13 |
| Módulos cubiertos | 5 (Usuarios, Investigación, Comunidad, Gamificación, Analítica) |
| Requerimientos funcionales con soporte en BD | 33 de 33 |

**Normalización:** todas las entidades se encuentran en **3FN**; las dependencias parciales se resolvieron con catálogos (`facultades`, `programas`, `categorias_publicacion`, `niveles`, `insignias`) y tablas intermedias (`semillero_integrantes`, `seguimientos_semillero`, `participaciones_evento`, `postulaciones`, `insignias_usuario`, `reacciones`).
