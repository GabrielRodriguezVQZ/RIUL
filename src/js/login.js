// =====================================================================
// RIUL - Inicio de sesión (RF-03 / RNF-02)
// Envía el formulario a POST /api/login
// =====================================================================
(function () {
    'use strict';

    var form = document.getElementById('form-login');
    var aviso = document.getElementById('aviso');
    if (!form || !aviso) return;

    var boton = form.querySelector('button[type="submit"]');
    var textoBoton = boton.textContent;

    function mostrar(mensaje) {
        aviso.textContent = mensaje;
        aviso.className = 'aviso aviso-error';
        aviso.hidden = false;
    }

    form.addEventListener('submit', async function (e) {
        e.preventDefault();
        aviso.hidden = true;

        boton.disabled = true;
        boton.textContent = 'Verificando…';

        try {
            var resp = await fetch('/api/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: document.getElementById('email').value.trim(),
                    password: document.getElementById('password').value
                })
            });
            var data = await resp.json().catch(function () { return {}; });

            if (resp.ok && data.ok) {
                sessionStorage.setItem('riul_usuario', JSON.stringify(data.usuario));
                window.location.href = 'dashboard.html';
                return;
            }

            mostrar(data.mensaje || 'No se pudo iniciar sesión.');
        } catch (err) {
            mostrar('No se pudo conectar con el servidor. Abre la plataforma desde http://localhost:8080 e inténtalo de nuevo.');
        } finally {
            boton.disabled = false;
            boton.textContent = textoBoton;
        }
    });
})();
