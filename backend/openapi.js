'use strict';

// =====================================================================
// RIUL - Especificación OpenAPI 3.0 de la API
// Se muestra con Swagger UI en  /api/docs
// =====================================================================

const ejemploError = (mensaje) => ({ ok: false, mensaje });

module.exports = {
    openapi: '3.0.3',
    info: {
        title: 'RIUL API',
        version: '1.0.0',
        description:
            'API de **RIUL – Red de Investigación Universidad Libre**.\n\n' +
            'Cubre el registro de usuarios con validación institucional (RF-02, RF-04) y el acceso a la plataforma (RF-03, RNF-02).\n\n' +
            '**Flujo:** una cuenta nueva queda en estado `pendiente` hasta que un administrador la active; solo las cuentas `activo` pueden iniciar sesión.\n\n' +
            '**Cuentas de prueba (seed):** contraseña `Riul2026*`, por ejemplo `maria.duque@unilibre.edu.co` (activa).'
    },
    // Ruta relativa: "Try it out" funciona tanto en :8080 (Nginx) como en :3000
    servers: [{ url: '/', description: 'Servidor actual' }],
    tags: [
        { name: 'Registro', description: 'Solicitud de cuenta (RF-02, RF-04)' },
        { name: 'Acceso', description: 'Autenticación (RF-03, RNF-02)' },
        { name: 'Sistema', description: 'Estado del servicio' }
    ],
    paths: {
        '/api/registro': {
            post: {
                tags: ['Registro'],
                summary: 'Solicitar registro de usuario',
                description:
                    'Crea el usuario con estado `pendiente` y su solicitud en `solicitudes_registro`, en una sola transacción. ' +
                    'La contraseña se almacena cifrada con bcrypt. Desde este endpoint **no** se puede solicitar el rol `administrador`.',
                requestBody: {
                    required: true,
                    content: {
                        'application/json': {
                            schema: { $ref: '#/components/schemas/RegistroRequest' }
                        }
                    }
                },
                responses: {
                    201: {
                        description: 'Solicitud creada; la cuenta queda pendiente de aprobación.',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/RegistroOk' }
                            }
                        }
                    },
                    400: {
                        description: 'Datos inválidos (campo vacío, contraseñas distintas, rol o programa inexistente, datos personales no aceptados, JSON mal formado).',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Error' },
                                example: {
                                    ok: false,
                                    mensaje: 'Las contraseñas no coinciden.',
                                    errores: ['Las contraseñas no coinciden.']
                                }
                            }
                        }
                    },
                    409: {
                        description: 'Ya existe una cuenta con ese correo o documento de identidad.',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Error' },
                                example: ejemploError('Ya existe una cuenta con ese correo.')
                            }
                        }
                    },
                    500: { $ref: '#/components/responses/ErrorInterno' }
                }
            }
        },

        '/api/login': {
            post: {
                tags: ['Acceso'],
                summary: 'Iniciar sesión',
                description:
                    'Valida correo y contraseña. Solo los usuarios con estado `activo` pueden entrar. ' +
                    'Ante credenciales incorrectas responde siempre el mismo mensaje, exista o no el correo.',
                requestBody: {
                    required: true,
                    content: {
                        'application/json': {
                            schema: { $ref: '#/components/schemas/LoginRequest' }
                        }
                    }
                },
                responses: {
                    200: {
                        description: 'Credenciales correctas.',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/LoginOk' }
                            }
                        }
                    },
                    400: {
                        description: 'Faltan el correo o la contraseña.',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Error' },
                                example: ejemploError('Ingresa tu correo y tu contraseña.')
                            }
                        }
                    },
                    401: {
                        description: 'Correo o contraseña incorrectos.',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Error' },
                                example: ejemploError('Correo o contraseña incorrectos.')
                            }
                        }
                    },
                    403: {
                        description: 'La cuenta existe pero no está activa (pendiente de aprobación, rechazada o suspendida).',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Error' },
                                example: ejemploError('Tu solicitud aún está pendiente de aprobación por el administrador.')
                            }
                        }
                    },
                    500: { $ref: '#/components/responses/ErrorInterno' }
                }
            }
        },

        '/api/health': {
            get: {
                tags: ['Sistema'],
                summary: 'Estado de la API y de la base de datos',
                responses: {
                    200: {
                        description: 'API y base de datos operativas.',
                        content: {
                            'application/json': {
                                schema: {
                                    type: 'object',
                                    properties: {
                                        ok: { type: 'boolean', example: true },
                                        bd: { type: 'string', example: 'conectada' }
                                    }
                                }
                            }
                        }
                    },
                    503: {
                        description: 'La API responde pero no logra conectar con la base de datos.',
                        content: {
                            'application/json': {
                                schema: {
                                    type: 'object',
                                    properties: {
                                        ok: { type: 'boolean', example: false },
                                        bd: { type: 'string', example: 'sin conexión' }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    },

    components: {
        schemas: {
            RegistroRequest: {
                type: 'object',
                required: [
                    'nombre', 'apellido', 'identificacion', 'email', 'programa',
                    'rol', 'password', 'password2', 'aceptoDatos'
                ],
                properties: {
                    nombre: { type: 'string', maxLength: 80, example: 'Ana María' },
                    apellido: { type: 'string', maxLength: 80, example: 'Pérez Gil' },
                    identificacion: {
                        type: 'string',
                        pattern: '^[0-9A-Za-z-]{5,20}$',
                        description: 'Documento de identidad (5 a 20 caracteres).',
                        example: '1098765432'
                    },
                    telefono: { type: 'string', maxLength: 20, example: '300 111 2233' },
                    email: {
                        type: 'string',
                        format: 'email',
                        maxLength: 150,
                        description: 'Se guarda en minúsculas.',
                        example: 'ana.perez@unilibre.edu.co'
                    },
                    programa: {
                        type: 'string',
                        description: 'Código del programa académico.',
                        enum: ['IS-01', 'II-02', 'PS-03', 'AE-04', 'EN-05', 'DE-06'],
                        example: 'IS-01'
                    },
                    rol: {
                        type: 'string',
                        description: 'Rol solicitado. El rol de administrador no se puede pedir por este medio.',
                        enum: ['estudiante_investigador', 'docente_lider'],
                        example: 'estudiante_investigador'
                    },
                    password: { type: 'string', format: 'password', minLength: 8, maxLength: 72, example: 'MiClave123' },
                    password2: {
                        type: 'string',
                        format: 'password',
                        description: 'Confirmación; debe ser igual a `password`.',
                        example: 'MiClave123'
                    },
                    motivacion: {
                        type: 'string',
                        maxLength: 2000,
                        description: 'Apoya la revisión institucional de la solicitud (RF-04).',
                        example: 'Me interesa la investigación en inteligencia artificial.'
                    },
                    aceptoDatos: {
                        type: 'boolean',
                        description: 'Debe ser `true` (tratamiento de datos personales, RNF-03).',
                        example: true
                    }
                }
            },

            RegistroOk: {
                type: 'object',
                properties: {
                    ok: { type: 'boolean', example: true },
                    mensaje: {
                        type: 'string',
                        example: 'Solicitud enviada. Un administrador la revisará y activará tu cuenta.'
                    }
                }
            },

            LoginRequest: {
                type: 'object',
                required: ['email', 'password'],
                properties: {
                    email: { type: 'string', format: 'email', example: 'maria.duque@unilibre.edu.co' },
                    password: { type: 'string', format: 'password', example: 'Riul2026*' }
                }
            },

            LoginOk: {
                type: 'object',
                properties: {
                    ok: { type: 'boolean', example: true },
                    usuario: { $ref: '#/components/schemas/Usuario' }
                }
            },

            Usuario: {
                type: 'object',
                properties: {
                    id: { type: 'integer', example: 1 },
                    nombre: { type: 'string', example: 'María Angel' },
                    apellido: { type: 'string', example: 'Duque Polo' },
                    email: { type: 'string', format: 'email', example: 'maria.duque@unilibre.edu.co' },
                    rol: {
                        type: 'string',
                        enum: ['estudiante_investigador', 'docente_lider', 'administrador', 'visitante'],
                        example: 'estudiante_investigador'
                    }
                }
            },

            Error: {
                type: 'object',
                properties: {
                    ok: { type: 'boolean', example: false },
                    mensaje: { type: 'string', description: 'Mensaje listo para mostrar al usuario.' },
                    errores: {
                        type: 'array',
                        items: { type: 'string' },
                        description: 'Todos los errores de validación (solo en respuestas 400 del registro).'
                    }
                }
            }
        },

        responses: {
            ErrorInterno: {
                description: 'Error interno del servidor.',
                content: {
                    'application/json': {
                        schema: { $ref: '#/components/schemas/Error' },
                        example: ejemploError('Error interno del servidor.')
                    }
                }
            }
        }
    }
};
