// =====================================================================
// RIUL - Registro de usuarios (RF-02 / RF-04)
// Envía el formulario a POST /api/registro
// =====================================================================
(function () {
    'use strict';

    var form = document.getElementById('form-registro');
    var aviso = document.getElementById('aviso');
    if (!form || !aviso) return;

    var boton = form.querySelector('button[type="submit"]');
    var textoBoton = boton.textContent;

    function mostrar(tipo, mensaje) {
        aviso.textContent = mensaje;
        aviso.className = 'aviso aviso-' + tipo;
        aviso.hidden = false;
        aviso.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }

    function valor(id) {
        return document.getElementById(id).value.trim();
    }

    form.addEventListener('submit', async function (e) {
        e.preventDefault();
        aviso.hidden = true;

        var password = document.getElementById('password').value;
        var password2 = document.getElementById('password2').value;

        if (password.length < 8) {
            return mostrar('error', 'La contraseña debe tener mínimo 8 caracteres.');
        }
        if (password !== password2) {
            return mostrar('error', 'Las contraseñas no coinciden.');
        }

        var datos = {
            nombre: valor('nombre'),
            apellido: valor('apellido'),
            identificacion: valor('identificacion'),
            telefono: valor('telefono'),
            email: valor('email'),
            programa: valor('programa'),
            rol: valor('rol'),
            password: password,
            password2: password2,
            motivacion: valor('motivacion'),
            aceptoDatos: document.getElementById('acepto').checked
        };

        boton.disabled = true;
        boton.textContent = 'Enviando…';

        try {
            var resp = await fetch('/api/registro', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(datos)
            });
            var data = await resp.json().catch(function () { return {}; });

            if (resp.ok && data.ok) {
                form.reset();
                mostrar('exito', data.mensaje + ' Te llevaremos al inicio de sesión…');
                setTimeout(function () { window.location.href = 'login.html'; }, 4000);
                return;
            }

            mostrar('error', data.mensaje || 'No se pudo completar el registro.');
        } catch (err) {
            mostrar('error', 'No se pudo conectar con el servidor. Abre la plataforma desde http://localhost:8080 e inténtalo de nuevo.');
        } finally {
            boton.disabled = false;
            boton.textContent = textoBoton;
        }
    });
})();
