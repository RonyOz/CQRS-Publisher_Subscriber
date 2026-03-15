# ── Stage 1: Build ─────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies (package-lock.json garantiza versiones exactas)
COPY package*.json ./
RUN npm ci

# Copiar código fuente y compilar TypeScript → JavaScript
COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build

# ── Stage 2: Runtime ────────────────────────────────────
FROM node:18-alpine AS runtime

WORKDIR /app

# Solo dependencias de producción
COPY package*.json ./
RUN npm ci --only=production

# Copiar artefactos compilados desde el stage anterior
COPY --from=builder /app/dist ./dist

# Puerto expuesto por el Command Service
EXPOSE 3001

# Usuario no-root para mayor seguridad
USER node

# Arrancar el servicio compilado
CMD ["node", "dist/index.js"]
