# ── Stage 1: Build ─────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build

# ── Stage 2: Runtime ────────────────────────────────────
FROM node:18-alpine AS runtime

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY --from=builder /app/dist ./dist

# Subscriber A - proceso daemon, sin puerto HTTP
USER node

CMD ["node", "dist/index.js"]
