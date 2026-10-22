# =====================================================================
# RIUL - Imagen Docker de la API (Node.js + Express)
# =====================================================================
FROM node:22-alpine

WORKDIR /app

# Dependencias primero (aprovecha la caché de capas)
COPY package*.json ./
RUN npm install --omit=dev && npm cache clean --force

COPY server.js openapi.js ./

ENV NODE_ENV=production
EXPOSE 3000

# Sin privilegios de root
USER node

CMD ["node", "server.js"]
