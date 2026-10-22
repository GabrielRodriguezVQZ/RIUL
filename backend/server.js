'use strict';

// =====================================================================
// RIUL - API (registro y acceso de usuarios)
//   POST /api/registro  -> RF-02 / RF-04: crea usuario 'pendiente' + solicitud
//   POST /api/login     -> RF-03 / RNF-02: valida credenciales (bcrypt)
//   GET  /api/health    -> verificación de que la API y la BD responden
//   GET  /api/docs      -> documentación Swagger UI (OpenAPI)
// =====================================================================

const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const swaggerUi = require('swagger-ui-express');
const openapi = require('./openapi');

const PORT = Number(process.env.PORT || 3000);

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || 'riul',
    password: process.env.DB_PASSWORD || 'riul2026',
    database: process.env.DB_NAME || 'riul',
    charset: 'utf8mb4',
    waitForConnections: true,
    connectionLimit: 10
});

// Solo estos roles se pueden solicitar desde el registro público.
// 'administrador' y 'visitante' NUNCA se asignan desde aquí.
const ROLES_PERMITIDOS = new Set(['estudiante_investigador', 'docente_lider']);

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const DOC_RE = /^[0-9A-Za-z-]{5,20}$/;

// Hash falso para que /login tarde parecido exista o no el correo
const HASH_FALSO = bcrypt.hashSync('contrasena-inexistente', 10);

const texto = (v) => (typeof v === 'string' ? v.trim() : '');

const app = express();
app.disable('x-powered-by');
app.use(express.json({ limit: '10kb' }));

// ---------------------------------------------------------------------
// Documentación Swagger UI  ->  /api/docs   (especificación: /api/openapi.json)
// ---------------------------------------------------------------------
app.get('/api/openapi.json', (_req, res) => res.json(openapi));
// /api/docs -> /api/docs/ con redirección relativa (funciona detrás de Nginx)
app.get('/api/docs', (req, res, next) => {
    if (req.path.endsWith('/')) return next();   // Express ignora la barra final: dejar pasar a Swagger UI
    res.redirect('/api/docs/');
});
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(openapi, {
    customSiteTitle: 'RIUL API · Documentación'
}));

// ---------------------------------------------------------------------
// GET /api/health
// ---------------------------------------------------------------------
app.get('/api/health', async (_req, res) => {
    try {
        await pool.query('SELECT 1');
        res.json({ ok: true, bd: 'conectada' });
    } catch (err) {
        console.error('Health:', err.message);
        res.status(503).json({ ok: false, bd: 'sin conexión' });
    }
});

// ---------------------------------------------------------------------
// POST /api/registro
// ---------------------------------------------------------------------
app.post('/api/registro', async (req, res) => {
    const b = req.body || {};

    const nombre = texto(b.nombre);
    const apellido = texto(b.apellido);
    const identificacion = texto(b.identificacion);
    const telefono = texto(b.telefono);
    const email = texto(b.email).toLowerCase();
    const programa = texto(b.programa);        // código del programa (IS-01, ...)
    const rol = texto(b.rol);
    const motivacion = texto(b.motivacion);
    const password = typeof b.password === 'string' ? b.password : '';
    const password2 = typeof b.password2 === 'string' ? b.password2 : '';

    // --- Validaciones ---
    const errores = [];
    if (!nombre || nombre.length > 80) errores.push('Los nombres son obligatorios (máx. 80 caracteres).');
    if (!apellido || apellido.length > 80) errores.push('Los apellidos son obligatorios (máx. 80 caracteres).');
    if (!DOC_RE.test(identificacion)) errores.push('El documento de identidad no es válido.');
    if (telefono.length > 20) errores.push('El teléfono es demasiado largo (máx. 20 caracteres).');
    if (!EMAIL_RE.test(email) || email.length > 150) errores.push('El correo no es válido.');
    if (!programa) errores.push('Selecciona tu programa.');
    if (!ROLES_PERMITIDOS.has(rol)) errores.push('El rol solicitado no es válido.');
    if (password.length < 8) errores.push('La contraseña debe tener mínimo 8 caracteres.');
    if (password.length > 72) errores.push('La contraseña es demasiado larga (máx. 72 caracteres).');
    if (password !== password2) errores.push('Las contraseñas no coinciden.');
    if (motivacion.length > 2000) errores.push('La motivación es demasiado larga (máx. 2000 caracteres).');
    if (b.aceptoDatos !== true) errores.push('Debes aceptar el tratamiento de datos personales.');

    if (errores.length) {
        return res.status(400).json({ ok: false, mensaje: errores[0], errores });
    }

    let conn;
    try {
        conn = await pool.getConnection();

        const [programas] = await conn.query(
            "SELECT id FROM programas WHERE codigo = ? AND estado = 'activo'",
            [programa]
        );
        if (programas.length === 0) {
            return res.status(400).json({ ok: false, mensaje: 'El programa seleccionado no existe.' });
        }

        const hash = await bcrypt.hash(password, 10);   // RNF-02

        await conn.beginTransaction();

        const [usuario] = await conn.query(
            `INSERT INTO usuarios
                (programa_id, identificacion, nombre, apellido, email, password_hash, telefono, rol, estado)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pendiente')`,
            [programas[0].id, identificacion, nombre, apellido, email, hash, telefono || null, rol]
        );

        await conn.query(
            'INSERT INTO solicitudes_registro (usuario_id, motivacion) VALUES (?, ?)',
            [usuario.insertId, motivacion || null]
        );

        await conn.commit();

        return res.status(201).json({
            ok: true,
            mensaje: 'Solicitud enviada. Un administrador la revisará y activará tu cuenta.'
        });
    } catch (err) {
        if (conn) await conn.rollback().catch(() => {});

        if (err.code === 'ER_DUP_ENTRY') {
            const campo = /email/i.test(err.sqlMessage || '') ? 'correo' : 'documento de identidad';
            return res.status(409).json({ ok: false, mensaje: `Ya existe una cuenta con ese ${campo}.` });
        }

        console.error('Registro:', err);
        return res.status(500).json({ ok: false, mensaje: 'Error interno del servidor.' });
    } finally {
        if (conn) conn.release();
    }
});

// ---------------------------------------------------------------------
// POST /api/login
// ---------------------------------------------------------------------
app.post('/api/login', async (req, res) => {
    const email = texto(req.body && req.body.email).toLowerCase();
    const password = req.body && typeof req.body.password === 'string' ? req.body.password : '';

    if (!email || !password) {
        return res.status(400).json({ ok: false, mensaje: 'Ingresa tu correo y tu contraseña.' });
    }

    try {
        const [filas] = await pool.query(
            'SELECT id, nombre, apellido, email, password_hash, rol, estado FROM usuarios WHERE email = ?',
            [email]
        );
        const u = filas[0];

        // Se compara siempre, exista o no el usuario
        const coincide = await bcrypt.compare(password, u ? u.password_hash : HASH_FALSO);

        if (!u || !coincide) {
            return res.status(401).json({ ok: false, mensaje: 'Correo o contraseña incorrectos.' });
        }

        if (u.estado === 'pendiente') {
            return res.status(403).json({ ok: false, mensaje: 'Tu solicitud aún está pendiente de aprobación por el administrador.' });
        }
        if (u.estado !== 'activo') {
            return res.status(403).json({ ok: false, mensaje: 'Tu cuenta no está activa. Contacta al administrador.' });
        }

        await pool.query('UPDATE usuarios SET ultimo_acceso = NOW() WHERE id = ?', [u.id]);

        return res.json({
            ok: true,
            usuario: { id: u.id, nombre: u.nombre, apellido: u.apellido, email: u.email, rol: u.rol }
        });
    } catch (err) {
        console.error('Login:', err);
        return res.status(500).json({ ok: false, mensaje: 'Error interno del servidor.' });
    }
});

// ---------------------------------------------------------------------
// Errores (JSON mal formado, rutas inexistentes)
// ---------------------------------------------------------------------
app.use('/api', (_req, res) => {
    res.status(404).json({ ok: false, mensaje: 'Ruta no encontrada.' });
});

app.use((err, _req, res, _next) => {
    if (err.type === 'entity.parse.failed' || err.type === 'entity.too.large') {
        return res.status(400).json({ ok: false, mensaje: 'Solicitud inválida.' });
    }
    console.error(err);
    res.status(500).json({ ok: false, mensaje: 'Error interno del servidor.' });
});

app.listen(PORT, () => console.log(`RIUL API escuchando en el puerto ${PORT}`));
