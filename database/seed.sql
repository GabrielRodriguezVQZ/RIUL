-- =====================================================================
-- RIUL - Datos de ejemplo (seed)
-- Permite verificar el modelo y poblar las interfaces HTML/CSS
-- =====================================================================
USE riul;

-- Catálogos
INSERT INTO facultades (nombre) VALUES
('Facultad de Ingeniería'),
('Facultad de Ciencias Sociales'),
('Facultad de Salud'),
('Facultad de Derecho y Ciencias Políticas');

INSERT INTO programas (facultad_id, nombre, codigo) VALUES
(1, 'Ingeniería de Sistemas', 'IS-01'),
(1, 'Ingeniería Industrial', 'II-02'),
(2, 'Psicología', 'PS-03'),
(2, 'Administración de Empresas', 'AE-04'),
(3, 'Enfermería', 'EN-05'),
(4, 'Derecho', 'DE-06');

INSERT INTO categorias_publicacion (nombre, color) VALUES
('Artículo científico', '#1e3a8a'),
('Noticia de semillero', '#047857'),
('Convocatoria', '#b45309'),
('Evento', '#7c3aed'),
('Reflexión investigativa', '#be123c'),
('Resultados de proyecto', '#0e7490');

INSERT INTO usuarios (programa_id, identificacion, nombre, apellido, email, password_hash, telefono, biografia, rol, estado, xp_acumulado, nivel, estrellas, posicion_ranking, fecha_registro) VALUES
(1, '1001234567', 'María Angel', 'Duque Polo', 'maria.duque@unilibre.edu.co', '$2y$10$ejemploHashSeguro000000000000000000000000000000000000', '3001112233', 'Estudiante investigadora interesada en inteligencia artificial aplicada.', 'estudiante_investigador', 'activo', 2450, 5, 4, 1, '2026-02-01 08:00:00'),
(1, '1007654321', 'Gabriel Enrique', 'Rodríguez Vásquez', 'gabriel.rodriguez@unilibre.edu.co', '$2y$10$ejemploHashSeguro000000000000000000000000000000000000', '3012223344', 'Focos de interés: desarrollo web y datos abiertos.', 'estudiante_investigador', 'activo', 2180, 4, 4, 2, '2026-02-01 08:10:00'),
(2, '80123456', 'William Ricardo', 'Insignares Conde', 'william.insignares@unilibre.edu.co', '$2y$10$ejemploHashSeguro000000000000000000000000000000000000', '3103334455', 'Docente líder del semillero RIUL, líneas de investigación en innovación educativa.', 'docente_lider', 'activo', 3120, 5, 5, NULL, '2026-01-15 07:30:00'),
(3, '79988776', 'Laura Marcela', 'Gómez Ríos', 'laura.gomez@unilibre.edu.co', '$2y$10$ejemploHashSeguro000000000000000000000000000000000000', '3124445566', 'Administradora de la plataforma RIUL.', 'administrador', 'activo', 900, 2, 3, NULL, '2026-01-10 07:00:00'),
(1, '1009998887', 'Juan David', 'Berrocal Sanchez', 'juan.berrocal@unilibre.edu.co', '$2y$10$ejemploHashSeguro000000000000000000000000000000000000', '3135556677', NULL, 'estudiante_investigador', 'pendiente', 0, 1, 0, NULL, '2026-08-20 18:00:00'),
(2, '1004443332', 'Carolina', 'Mejía Torres', 'carolina.mejia@unilibre.edu.co', '$2y$10$ejemploHashSeguro000000000000000000000000000000000000', '3157778899', 'Interés en metodologías cualitativas.', 'estudiante_investigador', 'activo', 1760, 4, 3, 3, '2026-03-05 09:00:00'),
(3, '1003332221', 'Diego Alonso', 'Patiño Ruiz', 'diego.patino@unilibre.edu.co', '$2y$10$ejemploHashSeguro000000000000000000000000000000000000', '3168889900', NULL, 'estudiante_investigador', 'activo', 1540, 3, 3, 4, '2026-03-12 11:00:00'),
(1, '1002221110', 'Sofía', 'Hernández Díaz', 'sofia.hernandez@unilibre.edu.co', '$2y$10$ejemploHashSeguro000000000000000000000000000000000000', '3179990011', 'Semillero de software libre.', 'estudiante_investigador', 'activo', 1320, 3, 3, 5, '2026-04-02 14:00:00'),
(2, '1001110009', 'Camilo', 'Ortega Vela', 'camilo.ortega@unilibre.edu.co', '$2y$10$ejemploHashSeguro000000000000000000000000000000000000', '3180001122', NULL, 'estudiante_investigador', 'pendiente', 0, 1, 0, NULL, '2026-08-22 16:30:00'),
(4, '1005556664', 'Andrés Felipe', 'Castro León', 'andres.castro@unilibre.edu.co', '$2y$10$ejemploHashSeguro000000000000000000000000000000000000', '3146667788', 'Visitante de la plataforma.', 'visitante', 'activo', 0, 1, 0, NULL, '2026-08-21 10:00:00');
-- RF-04 Solicitudes de registro pendientes
INSERT INTO solicitudes_registro (usuario_id, motivacion, estado, fecha_solicitud) VALUES
(5, 'Estudiante de ingeniería de sistemas interesado en participar en el semillero de inteligencia artificial.', 'pendiente', '2026-08-20 18:05:00'),
(9, 'Estudiante de administración con interés en investigación social aplicada.', 'pendiente', '2026-08-22 16:35:00');

-- Semilleros (RF-07 a RF-10)
INSERT INTO semilleros (docente_lider_id, facultad_id, nombre, descripcion, lineas_investigacion, estado, xp_acumulado, nivel, estrellas, fecha_creacion) VALUES
(3, 1, 'Semillero RIUL - Innovación Educativa', 'Espacio de formación investigativa orientado a la innovación pedagógica y el uso de tecnologías en la educación.', 'Innovación educativa; Tecnología; Didáctica', 'activo', 6400, 7, 5, '2025-08-15 08:00:00'),
(3, 1, 'Semillero Datos y Ciudadanía', 'Investigación sobre datos abiertos, transparencia y participación ciudadana.', 'Datos abiertos; Políticas públicas', 'activo', 3900, 5, 4, '2025-11-03 08:00:00'),
(3, 3, 'Semillero Salud Comunitaria', 'Aborda problemáticas de salud pública desde el territorio.', 'Salud pública; Epidemiología', 'en_formacion', 1200, 3, 3, '2026-05-20 08:00:00');

-- Integrantes (RF-08 / RF-09)
INSERT INTO semillero_integrantes (semillero_id, usuario_id, rol_semillero, estado, fecha_solicitud, fecha_respuesta, respondido_por) VALUES
(1, 3, 'lider', 'aprobado', '2025-08-15 08:00:00', '2025-08-15 08:00:00', 3),
(1, 1, 'integrante', 'aprobado', '2026-02-02 09:00:00', '2026-02-03 10:00:00', 3),
(1, 2, 'integrante', 'aprobado', '2026-02-02 09:15:00', '2026-02-03 10:05:00', 3),
(1, 7, 'integrante', 'aprobado', '2026-03-13 11:00:00', '2026-03-14 09:00:00', 3),
(1, 8, 'integrante', 'aprobado', '2026-04-03 15:00:00', '2026-04-04 09:30:00', 3),
(1, 5, 'aspirante', 'solicitado', '2026-08-21 19:00:00', NULL, NULL),
(2, 3, 'lider', 'aprobado', '2025-11-03 08:00:00', '2025-11-03 08:00:00', 3),
(2, 6, 'integrante', 'aprobado', '2026-03-06 10:00:00', '2026-03-07 10:00:00', 3),
(3, 7, 'integrante', 'solicitado', '2026-08-18 12:00:00', NULL, NULL);

-- RF-18 Seguimientos
INSERT INTO seguimientos_semillero (usuario_id, semillero_id) VALUES
(1, 2), (2, 1), (6, 1), (8, 1), (8, 2);

-- Proyectos (RF-11)
INSERT INTO proyectos (semillero_id, responsable_id, titulo, descripcion, objetivos, estado, fecha_inicio, fecha_fin) VALUES
(1, 3, 'Plataforma RIUL: red de investigación universitaria', 'Diseño e implementación de una plataforma para centralizar y visibilizar la actividad investigativa de la Universidad Libre.', 'Centralizar la actividad investigativa; Gamificar la participación; Generar indicadores de impacto.', 'en_desarrollo', '2026-02-01', NULL),
(1, 1, 'Inteligencia artificial aplicada a la evaluación académica', 'Exploración de modelos de lenguaje para apoyar la evaluación formativa.', 'Comparar modelos; Validar con docentes; Publicar resultados.', 'en_desarrollo', '2026-04-01', NULL),
(2, 6, 'Datos abiertos y transparencia en el territorio', 'Estudio sobre el uso de portales de datos abiertos por parte de las ciudadanías.', 'Mapear portales; Analizar cobertura; Proponer lineamientos.', 'planificacion', '2026-09-01', NULL),
(1, 8, 'Comunidad de software libre en el aula', 'Caracterización de la adopción de software libre en cursos de programación.', 'Encuestar estudiantes; Proponer guía de adopción.', 'finalizado', '2025-09-01', '2026-06-30');

-- RF-12 Avances
INSERT INTO avances_proyecto (proyecto_id, autor_id, titulo, descripcion, fecha) VALUES
(1, 3, 'Levantamiento de requerimientos', 'Se consolidó el documento de requerimientos funcionales y no funcionales con 33 RF y 15 RNF.', '2026-08-18 10:00:00'),
(1, 2, 'Prototipo de interfaz', 'Se construyó el prototipo interactivo con 10 pantallas para el primer corte.', '2026-08-24 15:00:00'),
(2, 1, 'Revisión de literatura', 'Se revisaron 18 artículos sobre evaluación formativa asistida por IA.', '2026-05-12 09:00:00'),
(4, 8, 'Encuesta de adopción', 'Se aplicó la encuesta a 120 estudiantes de programación.', '2026-03-20 14:00:00');

-- RF-13 Productos
INSERT INTO productos_investigacion (proyecto_id, semillero_id, usuario_id, tipo, titulo, descripcion, fecha, doi) VALUES
(1, 1, 3, 'articulo', 'RIUL: una arquitectura para visibilizar la investigación universitaria', 'Artículo sometido a congreso institucional.', '2026-07-15', NULL),
(NULL, 1, 1, 'ponencia', 'IA y evaluación formativa: una revisión sistemática', 'Ponencia presentada en el seminario de innovación.', '2026-06-10', NULL),
(NULL, 2, 6, 'informe', 'Radiografía de los portales de datos abiertos', 'Informe técnico interno.', '2026-05-30', NULL),
(4, 1, 8, 'software', 'Guía interactiva de software libre', 'Repositorio y guía publicada.', '2026-06-30', NULL);

-- RF-16 Eventos
INSERT INTO eventos (organizador_id, nombre, descripcion, tipo, modalidad, lugar, fecha_inicio, fecha_fin, cupo_maximo, estado) VALUES
(4, 'Semilleros en acción 2026', 'Encuentro institucional donde los semilleros presentan sus resultados investigativos.', 'jornada', 'mixta', 'Auditorio Mayor - Sede Bogotá', '2026-09-18 08:00:00', '2026-09-18 17:00:00', 200, 'programado'),
(3, 'Taller de escritura científica', 'Taller práctico para redacción de artículos científicos.', 'taller', 'virtual', 'Meet', '2026-10-03 09:00:00', '2026-10-03 12:00:00', 50, 'programado'),
(4, 'Congreso de investigación estudiantil', 'Congreso anual de proyectos de investigación estudiantil.', 'congreso', 'presencial', 'Sede Pereira', '2026-11-12 08:00:00', '2026-11-14 18:00:00', 300, 'programado'),
(3, 'Seminario de metodologías mixtas', 'Seminario introductorio a diseños de investigación mixtos.', 'seminario', 'virtual', 'Meet', '2026-07-10 14:00:00', '2026-07-10 17:00:00', 100, 'finalizado');

-- Participaciones (RF-16)
INSERT INTO participaciones_evento (evento_id, usuario_id, semillero_id, estado, fecha_inscripcion) VALUES
(1, 1, 1, 'inscrito', '2026-08-25 10:00:00'),
(1, 2, 1, 'confirmado', '2026-08-25 10:10:00'),
(2, 1, 1, 'confirmado', '2026-08-26 11:00:00'),
(3, 7, NULL, 'inscrito', '2026-08-27 12:00:00'),
(4, 1, 1, 'asistio', '2026-07-01 08:00:00'),
(4, 8, 1, 'asistio', '2026-07-01 08:30:00');

-- RF-17 Convocatorias y postulaciones
INSERT INTO convocatorias (publicada_por, titulo, descripcion, requisitos, fecha_publicacion, fecha_cierre, estado) VALUES
(4, 'Semilleros XL 2026', 'Convocatoria para la creación y fortalecimiento de semilleros de investigación.', 'Ser docente o estudiante de la Universidad Libre; presentar plan de trabajo a 6 meses.', '2026-08-01', '2026-09-30', 'abierta'),
(4, 'Incentivo a publicaciones indexadas', 'Reconimiento económico a publicaciones en revistas indexadas.', 'Ser autor de una publicación indexada en el periodo.', '2026-06-01', '2026-07-15', 'cerrada');

INSERT INTO postulaciones (convocatoria_id, usuario_id, carta_presentacion, estado, fecha) VALUES
(1, 3, 'Plan de trabajo del semillero RIUL.', 'seleccionada', '2026-08-05 09:00:00'),
(1, 6, 'Propuesta de nuevo semillero de datos abiertos.', 'recibida', '2026-08-15 10:00:00'),
(2, 1, 'Publicación en congreso indexado.', 'seleccionada', '2026-06-10 11:00:00');

-- RF-27 Hojas de vida
INSERT INTO hoja_vida_investigativa (usuario_id, resumen, formacion, experiencia, productos, competencias) VALUES
(1, 'Estudiante investigadora de ingeniería de sistemas con interés en inteligencia aplicada a la educación.', 'Ingeniería de Sistemas (en curso)', 'Integrante del semillero RIUL desde 2026', '1 ponencia, 2 avances de proyecto', 'Python, análisis de datos, redacción científica'),
(2, 'Estudiante de ingeniería de sistemas interesado en datos abiertos y desarrollo web.', 'Ingeniería de Sistemas (en curso)', 'Integrante del semillero RIUL desde 2026', '1 prototipo, 1 avance de proyecto', 'HTML/CSS, SQL, visualización de datos'),
(3, 'Docente líder con 12 años de experiencia en investigación educativa.', 'Doctorado en Educación', 'Líder del semillero RIUL', '1 artículo, 2 ponencias', 'Metodologías mixtas, gestión de proyectos');

-- RF-14 / RF-15 Publicaciones e interacción
INSERT INTO publicaciones (autor_id, categoria_id, semillero_id, titulo, contenido, evidencia_url, visibilidad, vistas, fecha) VALUES
(3, 2, 1, 'El semillero RIUL supera los 6.000 puntos de experiencia', 'Nuestro semillero alcanzó un nuevo nivel gracias a la validación de logros de sus integrantes. ¡Gracias a todos por su participación!', NULL, 'publica', 342, '2026-08-10 09:00:00'),
(1, 1, 1, 'Revisión sistemática: IA y evaluación formativa', 'Compartimos los resultados preliminares de la revisión de literatura realizada en el proyecto de investigación.', '/evidencias/revision-ia.pdf', 'publica', 289, '2026-08-12 14:30:00'),
(6, 4, 2, 'Convocatoria: Congreso de investigación estudiantil', 'Ya está abierta la inscripción para el congreso. Postula tu proyecto antes del 30 de septiembre.', NULL, 'publica', 198, '2026-08-14 11:00:00'),
(2, 6, 1, 'Resultados de la encuesta de software libre', '120 estudiantes respondieron nuestra encuesta. El 68% prefiere usar herramientas libres en sus cursos.', NULL, 'publica', 176, '2026-08-16 16:45:00'),
(8, 5, NULL, '¿Cómo validar logros por primera vez?', 'Reflexión sobre el proceso de validación de logros y la asignación de XP en la plataforma.', NULL, 'solo_miembros', 64, '2026-08-18 08:20:00');

INSERT INTO reacciones (publicacion_id, usuario_id, tipo, fecha) VALUES
(1, 1, 'me_gusta', '2026-08-10 10:00:00'),
(1, 2, 'destacado', '2026-08-10 10:30:00'),
(2, 3, 'me_inspira', '2026-08-12 15:00:00'),
(2, 7, 'me_gusta', '2026-08-12 15:30:00'),
(3, 1, 'apoyo', '2026-08-14 12:00:00'),
(4, 8, 'me_gusta', '2026-08-16 17:00:00');

INSERT INTO comentarios (publicacion_id, usuario_id, texto, fecha) VALUES
(1, 2, '¡Gran logro del equipo! Sigue así.', '2026-08-10 11:00:00'),
(2, 3, 'Excelente avance, María. Incluye las referencias APA en la versión final.', '2026-08-12 16:00:00'),
(4, 3, 'Muy buen análisis. Podríamos replicarlo en otros cursos.', '2026-08-16 18:00:00');

INSERT INTO compartidos (publicacion_id, usuario_id, destino, fecha) VALUES
(2, 7, 'interno', '2026-08-12 17:00:00'),
(3, 1, 'enlace', '2026-08-14 13:00:00');

-- RF-20 / RF-21 Logros
INSERT INTO logros (usuario_id, semillero_id, tipo, titulo, descripcion, evidencia_url, estado, validado_por, xp_otorgada, fecha_registro, fecha_validacion) VALUES
(1, 1, 'evento', 'Asistencia al seminario de metodologías mixtas', 'Participación certificada en el seminario virtual.', '/evidencias/cert-seminario.pdf', 'aprobado', 4, 150, '2026-07-10 17:30:00', '2026-07-12 09:00:00'),
(1, 1, 'publicacion', 'Ponencia: IA y evaluación formativa', 'Ponencia presentada en el seminario de innovación.', '/evidencias/ponencia.pdf', 'aprobado', 4, 300, '2026-06-10 18:00:00', '2026-06-12 10:00:00'),
(2, 1, 'producto', 'Prototipo interactivo RIUL', 'Prototipo de las 10 pantallas del sistema para el primer corte.', '/evidencias/prototipo.zip', 'aprobado', 4, 250, '2026-08-24 16:00:00', '2026-08-25 08:00:00'),
(1, 1, 'actividad', 'Levantamiento de requerimientos', 'Participación en la elaboración del documento de requerimientos.', NULL, 'pendiente', NULL, 0, '2026-08-26 09:00:00', NULL),
(7, 1, 'proyecto', 'Encuesta de software libre', 'Aplicación de la encuesta a 120 estudiantes.', '/evidencias/encuesta.xlsx', 'pendiente', NULL, 0, '2026-08-27 10:00:00', NULL),
(1, 1, 'otro', 'Certificado de asistencia duplicado', 'Registro duplicado del seminario.', NULL, 'rechazado', 4, 0, '2026-07-11 10:00:00', '2026-07-13 11:00:00');

-- RF-22 Movimientos de XP
INSERT INTO movimientos_experiencia (usuario_id, logro_id, evento_id, concepto, puntos, fecha) VALUES
(1, 1, NULL, 'Logro validado: seminario de metodologías mixtas', 150, '2026-07-12 09:00:00'),
(1, 2, NULL, 'Logro validado: ponencia IA', 300, '2026-06-12 10:00:00'),
(1, NULL, NULL, 'Participación en proyecto activo', 400, '2026-08-01 08:00:00'),
(1, NULL, 1, 'Inscripción a Semilleros en acción', 100, '2026-08-25 10:00:00'),
(1, NULL, NULL, 'Participación sostenida en el semillero (acumulado)', 1500, '2026-08-01 08:00:00'),
(2, 3, NULL, 'Logro validado: prototipo interactivo', 250, '2026-08-25 08:00:00'),
(2, NULL, NULL, 'Participación en proyecto activo', 350, '2026-08-01 08:00:00'),
(2, NULL, NULL, 'Participación sostenida en el semillero (acumulado)', 1580, '2026-08-01 08:00:00'),
(3, NULL, NULL, 'Liderazgo de semillero', 500, '2026-08-01 08:00:00'),
(3, NULL, NULL, 'Participación sostenida (acumulado)', 2620, '2026-08-01 08:00:00'),
(4, NULL, NULL, 'Gestión administrativa de la plataforma', 900, '2026-08-01 08:00:00'),
(6, NULL, NULL, 'Participación sostenida (acumulado)', 1760, '2026-08-01 08:00:00'),
(7, NULL, NULL, 'Participación sostenida (acumulado)', 1540, '2026-08-01 08:00:00'),
(8, NULL, NULL, 'Participación sostenida (acumulado)', 1320, '2026-08-01 08:00:00');

-- RF-23 Insignias y otorgamientos
INSERT INTO insignias (nombre, descripcion, icono, categoria) VALUES
('Primera publicación', 'Publica tu primera contribución en la comunidad.', 'fa-pen-nib', 'logro'),
('Validado', 'Obtén la aprobación de tu primer logro.', 'fa-certificate', 'logro'),
('Nivel 5', 'Alcanza el nivel 5 de experiencia.', 'fa-star', 'nivel'),
('Investigador activo', 'Registra 5 logros aprobados.', 'fa-award', 'actividad'),
('Cinco estrellas', 'Alcanza las 5 estrellas de progresión.', 'fa-star-half-stroke', 'estrella'),
('Embajador RIUL', 'Insignia especial por contribución destacada a la red.', 'fa-medal', 'especial');

INSERT INTO insignias_usuario (usuario_id, insignia_id, logro_id, fecha_otorgada) VALUES
(1, 1, NULL, '2026-08-12 14:30:00'),
(1, 2, 1, '2026-07-12 09:00:00'),
(1, 3, NULL, '2026-08-01 08:00:00'),
(2, 1, NULL, '2026-08-16 16:45:00'),
(2, 2, 3, '2026-08-25 08:00:00'),
(3, 5, NULL, '2026-08-01 08:00:00');

-- RF-25 Niveles y RF-24 criterios
INSERT INTO niveles (nivel, nombre, xp_requerido) VALUES
(1, 'Novato', 0), (2, 'Aprendiz', 500), (3, 'Explorador', 1000),
(4, 'Investigador', 1700), (5, 'Avanzado', 2400), (6, 'Experto', 3200),
(7, 'Maestro', 4500), (8, 'Embajador RIUL', 6000);

INSERT INTO criterios_progresion (ambito, estrellas_min, nivel_min, xp_minima, descripcion) VALUES
('usuario', 1, 1, 0, 'Nivel inicial: registro completo del perfil.'),
('usuario', 2, 2, 500, 'Dos estrellas: primer logro validado y una publicación.'),
('usuario', 3, 3, 1000, 'Tres estrellas: participación en un evento y un proyecto activo.'),
('usuario', 4, 4, 1700, 'Cuatro estrellas: tres logros aprobados y una insignia de nivel.'),
('usuario', 5, 5, 2500, 'Cinco estrellas: liderazgo o participación sostenida en semillero.'),
('semillero', 5, 7, 6000, 'Semillero de excelencia: suma de XP de sus integrantes.');

-- RF-32 Reportes y bitácora (RNF-13)
INSERT INTO reportes (generado_por, tipo, titulo, parametros, fecha) VALUES
(4, 'impacto', 'Impacto de publicaciones - Agosto 2026', '{"mes": "2026-08"}', '2026-08-31 17:00:00'),
(4, 'ranking', 'Ranking de investigadores - Agosto 2026', '{"orden": "xp"}', '2026-08-31 17:05:00'),
(4, 'semilleros', 'Semilleros activos por facultad', '{"estado": "activo"}', '2026-08-31 17:10:00');

INSERT INTO bitacora_acciones (usuario_id, accion, entidad, entidad_id, detalle, fecha) VALUES
(4, 'APROBAR_SOLICITUD', 'solicitudes_registro', 1, 'Aprobación de cuenta de María Duque', '2026-02-01 08:05:00'),
(4, 'VALIDAR_LOGRO', 'logros', 1, 'Logro aprobado con 150 XP', '2026-07-12 09:00:00'),
(3, 'APROBAR_INTEGRANTE', 'semillero_integrantes', 2, 'Vinculación de María Duque al semillero RIUL', '2026-02-03 10:00:00'),
(4, 'PUBLICAR_CONVOCATORIA', 'convocatorias', 1, 'Convocatoria Semilleros XL 2026', '2026-08-01 08:00:00'),
(4, 'VALIDAR_LOGRO', 'logros', 3, 'Logro aprobado con 250 XP', '2026-08-25 08:00:00');

-- RF-19 Notificaciones
INSERT INTO notificaciones (usuario_id, tipo, titulo, mensaje, enlace, leida, fecha) VALUES
(1, 'validacion', 'Logro aprobado', 'Tu logro "Ponencia: IA y evaluación formativa" fue aprobado y otorgó 300 XP.', 'logros.html', TRUE, '2026-06-12 10:00:00'),
(3, 'solicitud', 'Nueva solicitud de vinculación', 'Juan David Berrocal solicitó ingresar al semillero RIUL - Innovación Educativa.', 'semilleros.html', FALSE, '2026-08-21 19:00:00'),
(4, 'validacion', 'Logros pendientes por validar', 'Hay 2 logros esperando revisión.', 'admin.html', FALSE, '2026-08-27 10:05:00'),
(1, 'convocatoria', 'Convocatoria abierta', 'Semilleros XL 2026 está abierta hasta el 30 de septiembre.', 'eventos.html', TRUE, '2026-08-01 08:00:00'),
(1, 'evento', 'Recordatorio de evento', 'Taller de escritura científica inicia el 3 de octubre.', 'eventos.html', TRUE, '2026-09-30 08:00:00');