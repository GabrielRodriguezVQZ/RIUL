# =====================================================================
# RIUL - Imagen Docker de la interfaz web
# Sirve las interfaces HTML/CSS mediante Nginx
# =====================================================================
FROM nginx:1.27-alpine

# Contenido estático de la aplicación
COPY src/ /usr/share/nginx/html/

# Configuración de Nginx (compresión, cache ligera y charset UTF-8)
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -qO- http://localhost/ >/dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
