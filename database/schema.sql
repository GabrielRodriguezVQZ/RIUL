-- =====================================================================
-- RIUL - Red de Investigación Universidad Libre
-- Script de creación de base de datos (MySQL 8.0)
-- Segundo corte - Programación Web
-- Trazabilidad: RF-01 a RF-33, RNF-01 a RNF-15
-- =====================================================================

DROP DATABASE IF EXISTS riul;
CREATE DATABASE riul CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE riul;

-- =====================================================================
-- MÓDULO 1: USUARIOS (RF-02, RF-03, RF-04, RF-05, RF-06, RF-28, RF-29, RF-31)
-- =====================================================================

CREATE TABLE facultades (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(120) NOT NULL UNIQUE,
    estado          ENUM('activa','inactiva') NOT NULL DEFAULT 'activa',
    fecha_creacion  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) COMMENT 'RF-29 Administración institucional';

CREATE TABLE programas (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    facultad_id     INT NOT NULL,
    nombre          VARCHAR(150) NOT NULL,
    codigo          VARCHAR(20) NOT NULL UNIQUE,
    estado          ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
    fecha_creacion  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_programa_facultad FOREIGN KEY (facultad_id)
        REFERENCES facultades(id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT 'RF-29 Administración institucional';

CREATE TABLE usuarios (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    programa_id     INT NULL,
    identificacion  VARCHAR(20) NOT NULL UNIQUE,
    nombre          VARCHAR(80) NOT NULL,
    apellido        VARCHAR(80) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL COMMENT 'RNF-02: nunca texto legible',
    telefono        VARCHAR(20) NULL,
    foto_url        VARCHAR(255) NULL,
    biografia       TEXT NULL,
    rol             ENUM('administrador','docente_lider','estudiante_investigador','visitante') NOT NULL,
    estado          ENUM('pendiente','activo','rechazado','suspendido') NOT NULL DEFAULT 'pendiente' COMMENT 'RF-04 validación institucional',
    xp_acumulado    INT NOT NULL DEFAULT 0 COMMENT 'RF-22 / RF-25',
    nivel           INT NOT NULL DEFAULT 1 COMMENT 'RF-25',
    estrellas       TINYINT NOT NULL DEFAULT 0 COMMENT 'RF-24 escala 1 a 5',
    posicion_ranking INT NULL COMMENT 'RF-26',
    fecha_registro  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso   DATETIME NULL,
    CONSTRAINT fk_usuario_programa FOREIGN KEY (programa_id)
        REFERENCES programas(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_usuarios_rol (rol),
    INDEX idx_usuarios_estado (estado),
    INDEX idx_usuarios_ranking (xp_acumulado DESC)
) COMMENT 'RF-02, RF-03, RF-05, RF-06, RF-28';

CREATE TABLE solicitudes_registro (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id      INT NOT NULL,
    motivacion      TEXT NULL,
    documento_url   VARCHAR(255) NULL,
    estado          ENUM('pendiente','aprobada','rechazada') NOT NULL DEFAULT 'pendiente' COMMENT 'RF-04',
    observacion     VARCHAR(255) NULL,
    revisado_por    INT NULL,
    fecha_solicitud TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta DATETIME NULL,
    CONSTRAINT fk_solicitud_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_admin FOREIGN KEY (revisado_por)
        REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT 'RF-04 Validación de cuentas - RNF-13 trazabilidad';

CREATE TABLE sesiones (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id      INT NOT NULL,
    token           VARCHAR(128) NOT NULL UNIQUE,
    ip              VARCHAR(45) NULL,
    fecha_inicio    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin       DATETIME NULL,
    CONSTRAINT fk_sesion_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'RF-03 Autenticación - RNF-01 control de acceso';

CREATE TABLE notificaciones (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id      INT NOT NULL,
    tipo            ENUM('publicacion','solicitud','validacion','convocatoria','evento','sistema') NOT NULL COMMENT 'RF-19',
    titulo          VARCHAR(150) NOT NULL,
    mensaje         VARCHAR(500) NOT NULL,
    enlace          VARCHAR(255) NULL,
    leida           BOOLEAN NOT NULL DEFAULT FALSE,
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notificacion_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_notificaciones_usuario (usuario_id, leida)
) COMMENT 'RF-19 Notificaciones';

-- =====================================================================
-- MÓDULO 2: INVESTIGACIÓN (RF-07 a RF-13, RF-16 a RF-18, RF-27, RF-30)
-- =====================================================================

CREATE TABLE semilleros (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    docente_lider_id  INT NOT NULL,
    facultad_id       INT NULL,
    nombre            VARCHAR(150) NOT NULL UNIQUE,
    descripcion       TEXT NOT NULL,
    lineas_investigacion VARCHAR(255) NULL,
    url_logo          VARCHAR(255) NULL,
    estado            ENUM('activo','inactivo','en_formacion') NOT NULL DEFAULT 'activo',
    fecha_creacion    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    xp_acumulado      INT NOT NULL DEFAULT 0 COMMENT 'RF-25 niveles de semillero',
    nivel             INT NOT NULL DEFAULT 1,
    estrellas         TINYINT NOT NULL DEFAULT 0,
    CONSTRAINT fk_semillero_lider FOREIGN KEY (docente_lider_id)
        REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_semillero_facultad FOREIGN KEY (facultad_id)
        REFERENCES facultades(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_semilleros_estado (estado)
) COMMENT 'RF-07, RF-10, RF-30';

CREATE TABLE semillero_integrantes (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    semillero_id     INT NOT NULL,
    usuario_id       INT NOT NULL,
    rol_semillero    ENUM('lider','integrante','aspirante') NOT NULL DEFAULT 'aspirante',
    estado           ENUM('solicitado','aprobado','rechazado','retirado') NOT NULL DEFAULT 'solicitado' COMMENT 'RF-08 / RF-09',
    fecha_solicitud  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta  DATETIME NULL,
    respondido_por   INT NULL,
    UNIQUE KEY uq_integrante (semillero_id, usuario_id),
    CONSTRAINT fk_integrante_semillero FOREIGN KEY (semillero_id)
        REFERENCES semilleros(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_integrante_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_integrante_responde FOREIGN KEY (respondido_por)
        REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT 'RF-08 solicitud de vinculación, RF-09 aprobación de integrantes';

CREATE TABLE seguimientos_semillero (
    usuario_id     INT NOT NULL,
    semillero_id   INT NOT NULL,
    fecha          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, semillero_id),
    CONSTRAINT fk_seguimiento_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_seguimiento_semillero FOREIGN KEY (semillero_id)
        REFERENCES semilleros(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'RF-18 Seguimiento de semilleros';

CREATE TABLE proyectos (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    semillero_id    INT NOT NULL,
    responsable_id  INT NOT NULL,
    titulo          VARCHAR(200) NOT NULL,
    descripcion     TEXT NOT NULL,
    objetivos       TEXT NULL,
    estado          ENUM('planificacion','en_desarrollo','finalizado','suspendido') NOT NULL DEFAULT 'planificacion' COMMENT 'RF-11',
    fecha_inicio    DATE NOT NULL,
    fecha_fin       DATE NULL,
    fecha_creacion  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_proyecto_semillero FOREIGN KEY (semillero_id)
        REFERENCES semilleros(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_proyecto_responsable FOREIGN KEY (responsable_id)
        REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_proyectos_estado (estado)
) COMMENT 'RF-11 Gestión de proyectos';

CREATE TABLE avances_proyecto (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    proyecto_id     INT NOT NULL,
    autor_id        INT NOT NULL,
    titulo          VARCHAR(150) NOT NULL,
    descripcion     TEXT NOT NULL,
    evidencia_url   VARCHAR(255) NULL,
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_avance_proyecto FOREIGN KEY (proyecto_id)
        REFERENCES proyectos(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_avance_autor FOREIGN KEY (autor_id)
        REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT 'RF-12 Registro de avances';

CREATE TABLE productos_investigacion (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    proyecto_id     INT NULL,
    semillero_id    INT NULL,
    usuario_id      INT NULL,
    tipo            ENUM('articulo','libro','patente','software','tesis','ponencia','informe','otro') NOT NULL COMMENT 'RF-13',
    titulo          VARCHAR(200) NOT NULL,
    descripcion     TEXT NULL,
    fecha           DATE NOT NULL,
    doi             VARCHAR(100) NULL,
    CONSTRAINT fk_producto_proyecto FOREIGN KEY (proyecto_id)
        REFERENCES proyectos(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_producto_semillero FOREIGN KEY (semillero_id)
        REFERENCES semilleros(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_producto_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT 'RF-13 Productos de investigación';

-- Regla: todo producto debe asociarse al menos a un proyecto, semillero o usuario
-- (reemplaza el CHECK, que MySQL 8.0 no admite junto a FK con SET NULL / CASCADE)
DELIMITER //
CREATE TRIGGER trg_producto_asociacion_ins BEFORE INSERT ON productos_investigacion
FOR EACH ROW
BEGIN
    IF NEW.proyecto_id IS NULL AND NEW.semillero_id IS NULL AND NEW.usuario_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El producto debe asociarse a un proyecto, semillero o usuario';
    END IF;
END//
CREATE TRIGGER trg_producto_asociacion_upd BEFORE UPDATE ON productos_investigacion
FOR EACH ROW
BEGIN
    IF NEW.proyecto_id IS NULL AND NEW.semillero_id IS NULL AND NEW.usuario_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El producto debe asociarse a un proyecto, semillero o usuario';
    END IF;
END//
DELIMITER ;

CREATE TABLE eventos (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    organizador_id  INT NOT NULL,
    nombre          VARCHAR(200) NOT NULL,
    descripcion     TEXT NOT NULL,
    tipo            ENUM('congreso','taller','seminario','simposio','jornada','otro') NOT NULL,
    modalidad       ENUM('presencial','virtual','mixta') NOT NULL DEFAULT 'virtual',
    lugar           VARCHAR(150) NULL,
    fecha_inicio    DATETIME NOT NULL,
    fecha_fin       DATETIME NOT NULL,
    cupo_maximo     INT NULL,
    estado          ENUM('programado','en_curso','finalizado','cancelado') NOT NULL DEFAULT 'programado',
    fecha_creacion  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evento_organizador FOREIGN KEY (organizador_id)
        REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_eventos_fecha (fecha_inicio)
) COMMENT 'RF-16 Eventos';

CREATE TABLE participaciones_evento (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    evento_id       INT NOT NULL,
    usuario_id      INT NOT NULL,
    semillero_id    INT NULL,
    estado          ENUM('inscrito','confirmado','asistio','no_asistio','cancelado') NOT NULL DEFAULT 'inscrito',
    fecha_inscripcion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_participacion (evento_id, usuario_id),
    CONSTRAINT fk_participacion_evento FOREIGN KEY (evento_id)
        REFERENCES eventos(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_participacion_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_participacion_semillero FOREIGN KEY (semillero_id)
        REFERENCES semilleros(id) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT 'RF-16 Registro de participación en eventos';

CREATE TABLE convocatorias (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    publicada_por     INT NOT NULL,
    titulo            VARCHAR(200) NOT NULL,
    descripcion       TEXT NOT NULL,
    requisitos        TEXT NULL,
    fecha_publicacion DATE NOT NULL,
    fecha_cierre      DATE NOT NULL,
    estado            ENUM('abierta','cerrada','finalizada') NOT NULL DEFAULT 'abierta' COMMENT 'RF-17',
    CONSTRAINT fk_convocatoria_admin FOREIGN KEY (publicada_por)
        REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT 'RF-17 Convocatorias';

CREATE TABLE postulaciones (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    convocatoria_id  INT NOT NULL,
    usuario_id       INT NOT NULL,
    carta_presentacion TEXT NULL,
    estado           ENUM('recibida','seleccionada','no_seleccionada') NOT NULL DEFAULT 'recibida',
    fecha            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_postulacion (convocatoria_id, usuario_id),
    CONSTRAINT fk_postulacion_convocatoria FOREIGN KEY (convocatoria_id)
        REFERENCES convocatorias(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_postulacion_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'RF-17 Postulaciones a convocatorias';

CREATE TABLE hoja_vida_investigativa (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id      INT NOT NULL UNIQUE,
    resumen         TEXT NULL,
    formacion       TEXT NULL,
    experiencia     TEXT NULL,
    productos       TEXT NULL,
    competencias    VARCHAR(500) NULL,
    url_documento   VARCHAR(255) NULL,
    actualizada_en  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_hv_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'RF-27 Hoja de vida investigativa';

-- =====================================================================
-- MÓDULO 3: COMUNIDAD (RF-01, RF-14, RF-15, RF-19, RF-33)
-- =====================================================================

CREATE TABLE categorias_publicacion (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(80) NOT NULL UNIQUE,
    color    VARCHAR(20) NOT NULL DEFAULT '#1e3a8a'
) COMMENT 'RF-14 Categorías de publicación';

CREATE TABLE publicaciones (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    autor_id        INT NOT NULL,
    categoria_id    INT NOT NULL,
    semillero_id    INT NULL,
    titulo          VARCHAR(200) NOT NULL,
    contenido       TEXT NOT NULL,
    evidencia_url   VARCHAR(255) NULL,
    visibilidad     ENUM('publica','solo_miembros','borrador') NOT NULL DEFAULT 'publica' COMMENT 'RF-01 consulta pública',
    vistas          INT NOT NULL DEFAULT 0 COMMENT 'RF-33 estadísticas de impacto',
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_publicacion_autor FOREIGN KEY (autor_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_publicacion_categoria FOREIGN KEY (categoria_id)
        REFERENCES categorias_publicacion(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_publicacion_semillero FOREIGN KEY (semillero_id)
        REFERENCES semilleros(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_publicaciones_fecha (fecha DESC),
    INDEX idx_publicaciones_visibilidad (visibilidad)
) COMMENT 'RF-14 Publicaciones';

CREATE TABLE reacciones (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id  INT NOT NULL,
    usuario_id      INT NOT NULL,
    tipo            ENUM('me_gusta','me_inspira','apoyo','destacado') NOT NULL,
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_reaccion (publicacion_id, usuario_id),
    CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (publicacion_id)
        REFERENCES publicaciones(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reaccion_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'RF-15 Reacciones';

CREATE TABLE comentarios (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id  INT NOT NULL,
    usuario_id      INT NOT NULL,
    comentario_padre_id INT NULL,
    texto           VARCHAR(1000) NOT NULL,
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (publicacion_id)
        REFERENCES publicaciones(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comentario_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comentario_padre FOREIGN KEY (comentario_padre_id)
        REFERENCES comentarios(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'RF-15 Comentarios';

CREATE TABLE compartidos (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id  INT NOT NULL,
    usuario_id      INT NOT NULL,
    destino         ENUM('interno','correo','enlace') NOT NULL DEFAULT 'interno',
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_compartido_publicacion FOREIGN KEY (publicacion_id)
        REFERENCES publicaciones(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_compartido_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'RF-15 Compartir publicaciones';

-- =====================================================================
-- MÓDULO 4: GAMIFICACIÓN (RF-20 a RF-26)
-- =====================================================================

CREATE TABLE logros (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id      INT NOT NULL,
    semillero_id    INT NULL,
    tipo            ENUM('actividad','producto','evento','publicacion','docencia','proyecto','otro') NOT NULL COMMENT 'RF-20',
    titulo          VARCHAR(150) NOT NULL,
    descripcion     TEXT NOT NULL,
    evidencia_url   VARCHAR(255) NULL,
    estado          ENUM('pendiente','aprobado','rechazado') NOT NULL DEFAULT 'pendiente' COMMENT 'RF-21 validación por administrador',
    validado_por    INT NULL,
    observacion     VARCHAR(255) NULL,
    xp_otorgada     INT NOT NULL DEFAULT 0 COMMENT 'RF-22',
    fecha_registro  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_validacion DATETIME NULL,
    CONSTRAINT fk_logro_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_logro_semillero FOREIGN KEY (semillero_id)
        REFERENCES semilleros(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_logro_admin FOREIGN KEY (validado_por)
        REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_logros_estado (estado)
) COMMENT 'RF-20 registro de logros, RF-21 validación de logros';

CREATE TABLE niveles (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    nivel        INT NOT NULL UNIQUE,
    nombre       VARCHAR(60) NOT NULL,
    xp_requerido INT NOT NULL COMMENT 'RF-25 criterio de ascenso'
) COMMENT 'RF-25 Configuración de niveles';

CREATE TABLE insignias (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NOT NULL,
    icono       VARCHAR(60) NOT NULL,
    categoria   ENUM('logro','nivel','estrella','actividad','especial') NOT NULL COMMENT 'RF-23'
) COMMENT 'RF-23 Insignias';

CREATE TABLE insignias_usuario (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id     INT NOT NULL,
    insignia_id    INT NOT NULL,
    logro_id       INT NULL,
    fecha_otorgada TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_insignia_usuario (usuario_id, insignia_id, fecha_otorgada),
    CONSTRAINT fk_insignia_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_insignia_badge FOREIGN KEY (insignia_id)
        REFERENCES insignias(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_insignia_logro FOREIGN KEY (logro_id)
        REFERENCES logros(id) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT 'RF-23 Otorgamiento de insignias';

CREATE TABLE movimientos_experiencia (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id   INT NOT NULL,
    logro_id     INT NULL,
    evento_id    INT NULL,
    concepto     VARCHAR(150) NOT NULL,
    puntos       INT NOT NULL COMMENT 'RF-22',
    fecha        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_xp_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_xp_logro FOREIGN KEY (logro_id)
        REFERENCES logros(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_xp_evento FOREIGN KEY (evento_id)
        REFERENCES eventos(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_xp_usuario (usuario_id, fecha DESC)
) COMMENT 'RF-22 Asignación de experiencia (XP)';

CREATE TABLE criterios_progresion (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    ambito         ENUM('usuario','semillero') NOT NULL COMMENT 'RF-24 / RF-25 / RF-26',
    estrellas_min  TINYINT NOT NULL DEFAULT 1,
    nivel_min      INT NOT NULL DEFAULT 1,
    xp_minima      INT NOT NULL DEFAULT 0,
    descripcion    VARCHAR(255) NOT NULL
) COMMENT 'RF-24 estrellas, RF-25 niveles, RF-26 ranking: criterios de progresión';

-- =====================================================================
-- MÓDULO 5: ANALÍTICA (RF-26, RF-32, RF-33) Y TRAZABILIDAD (RNF-13)
-- =====================================================================

CREATE TABLE bitacora_acciones (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id   INT NULL,
    accion       VARCHAR(60) NOT NULL,
    entidad      VARCHAR(60) NOT NULL,
    entidad_id   INT NULL,
    detalle      VARCHAR(500) NULL,
    ip           VARCHAR(45) NULL,
    fecha        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bitacora_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_bitacora_entidad (entidad, entidad_id),
    INDEX idx_bitacora_fecha (fecha DESC)
) COMMENT 'RNF-13 Trazabilidad de operaciones críticas';

CREATE TABLE reportes (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    generado_por   INT NOT NULL,
    tipo           ENUM('usuarios','semilleros','proyectos','publicaciones','logros','ranking','impacto') NOT NULL COMMENT 'RF-32',
    titulo         VARCHAR(150) NOT NULL,
    parametros     JSON NULL,
    fecha          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reporte_usuario FOREIGN KEY (generado_por)
        REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT 'RF-32 Reportes e indicadores';

-- =====================================================================
-- VISTAS DE INDICADORES (RF-26, RF-32, RF-33)
-- =====================================================================

CREATE OR REPLACE VIEW vw_ranking_usuarios AS
SELECT u.id, CONCAT(u.nombre, ' ', u.apellido) AS investigador, u.rol,
       u.xp_acumulado AS xp, u.nivel, u.estrellas,
       RANK() OVER (ORDER BY u.xp_acumulado DESC) AS posicion
FROM usuarios u
WHERE u.estado = 'activo' AND u.rol = 'estudiante_investigador';

CREATE OR REPLACE VIEW vw_indicadores_publicaciones AS
SELECT p.id, p.titulo, c.nombre AS categoria, p.vistas,
       COUNT(DISTINCT r.id) AS reacciones,
       COUNT(DISTINCT cm.id) AS comentarios,
       COUNT(DISTINCT co.id) AS compartidos,
       (COUNT(DISTINCT r.id) + COUNT(DISTINCT cm.id) * 2 + COUNT(DISTINCT co.id) * 3) AS impacto
FROM publicaciones p
JOIN categorias_publicacion c ON c.id = p.categoria_id
LEFT JOIN reacciones r ON r.publicacion_id = p.id
LEFT JOIN comentarios cm ON cm.publicacion_id = p.id
LEFT JOIN compartidos co ON co.publicacion_id = p.id
GROUP BY p.id, p.titulo, c.nombre, p.vistas;

CREATE OR REPLACE VIEW vw_dashboard_administrador AS
SELECT (SELECT COUNT(*) FROM usuarios WHERE estado = 'activo') AS usuarios_activos,
       (SELECT COUNT(*) FROM usuarios WHERE estado = 'pendiente') AS solicitudes_pendientes,
       (SELECT COUNT(*) FROM semilleros WHERE estado = 'activo') AS semilleros_activos,
       (SELECT COUNT(*) FROM proyectos WHERE estado = 'en_desarrollo') AS proyectos_desarrollo,
       (SELECT COUNT(*) FROM publicaciones) AS publicaciones,
       (SELECT COUNT(*) FROM logros WHERE estado = 'pendiente') AS logros_por_validar,
       (SELECT COUNT(*) FROM eventos WHERE estado = 'programado') AS eventos_programados,
       (SELECT COUNT(*) FROM convocatorias WHERE estado = 'abierta') AS convocatorias_abiertas;
