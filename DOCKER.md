# CQRS and Pub/Sub Patterns - Docker Deployment Guide

## 🐳 Docker Setup

This guide helps you containerize and run the services using Docker.

### Prerequisites

- Docker installed (https://www.docker.com/products/docker-desktop)
- Docker Compose (usually included with Docker Desktop)

---

## CQRS Module - Dockerized

### Single Service Dockerfile

Create `cqrs/command-service/Dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source
COPY . .

# Build TypeScript
RUN npm run build

# Expose port
EXPOSE 3001

# Start
CMD ["npm", "start"]
```

### docker-compose.yml for CQRS

```yaml
version: '3.8'

services:
  command-service:
    build:
      context: ./cqrs/command-service
    ports:
      - "3001:3001"
    environment:
      - PORT=3001
    container_name: cqrs-command

  query-service:
    build:
      context: ./cqrs/query-service
    ports:
      - "3002:3002"
    environment:
      - PORT=3002
      - COMMAND_SERVICE_URL=http://command-service:3001
    depends_on:
      - command-service
    container_name: cqrs-query
```

### Run CQRS

```bash
# Build and start
docker-compose up --build

# Just start (if already built)
docker-compose up

# Stop
docker-compose down

# View logs
docker-compose logs -f
```

---

## Pub/Sub Module - Dockerized

### Multi-service docker-compose.yml

```yaml
version: '3.8'

services:
  publisher:
    build:
      context: ./pubsub/publisher
    environment:
      - SERVICE_BUS_CONNECTION_STRING=${SERVICE_BUS_CONNECTION_STRING}
    container_name: pubsub-publisher
    dns: 8.8.8.8

  subscriber-a:
    build:
      context: ./pubsub/subscriber-a
    environment:
      - SERVICE_BUS_CONNECTION_STRING=${SERVICE_BUS_CONNECTION_STRING}
    container_name: pubsub-subscriber-a
    dns: 8.8.8.8

  subscriber-b:
    build:
      context: ./pubsub/subscriber-b
    environment:
      - SERVICE_BUS_CONNECTION_STRING=${SERVICE_BUS_CONNECTION_STRING}
    container_name: pubsub-subscriber-b
    dns: 8.8.8.8
```

### Run Pub/Sub

```bash
# Start subscribers first
docker-compose up subscriber-a subscriber-b

# In another terminal, start publisher
docker-compose up publisher

# View all logs
docker-compose logs -f

# Clean up
docker-compose down
```

---

## Complete docker-compose.yml (All Services)

```yaml
version: '3.8'

services:
  # CQRS Services
  command-service:
    build:
      context: ./cqrs/command-service
    ports:
      - "3001:3001"
    environment:
      - PORT=3001
    container_name: cqrs-command
    networks:
      - cloud-patterns

  query-service:
    build:
      context: ./cqrs/query-service
    ports:
      - "3002:3002"
    environment:
      - PORT=3002
      - COMMAND_SERVICE_URL=http://command-service:3001
    depends_on:
      - command-service
    container_name: cqrs-query
    networks:
      - cloud-patterns

  # Pub/Sub Services
  publisher:
    build:
      context: ./pubsub/publisher
    environment:
      - SERVICE_BUS_CONNECTION_STRING=${SERVICE_BUS_CONNECTION_STRING}
    container_name: pubsub-publisher
    networks:
      - cloud-patterns

  subscriber-a:
    build:
      context: ./pubsub/subscriber-a
    environment:
      - SERVICE_BUS_CONNECTION_STRING=${SERVICE_BUS_CONNECTION_STRING}
    container_name: pubsub-subscriber-a
    networks:
      - cloud-patterns

  subscriber-b:
    build:
      context: ./pubsub/subscriber-b
    environment:
      - SERVICE_BUS_CONNECTION_STRING=${SERVICE_BUS_CONNECTION_STRING}
    container_name: pubsub-subscriber-b
    networks:
      - cloud-patterns

networks:
  cloud-patterns:
    driver: bridge
```

### Dockerfile for All Services

Each service needs this `Dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source
COPY . .

# Build TypeScript
RUN npm run build

# For dev: use ts-node
# For prod: use npm start

EXPOSE 3001

CMD ["npm", "start"]
```

---

## Docker Compose Commands

### Start All Services

```bash
# Build and start
docker-compose up -d --build

# Follow logs
docker-compose logs -f

# Stop all
docker-compose down
```

### Start Individual Services

```bash
# Just CQRS
docker-compose up command-service query-service

# Just Pub/Sub
docker-compose up subscriber-a subscriber-b publisher
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f command-service

# Last 50 lines
docker-compose logs --tail 50
```

### Manage Containers

```bash
# List running containers
docker-compose ps

# Enter a container
docker-compose exec command-service sh

# Rebuild a service
docker-compose build --no-cache command-service

# Remove all volumes
docker-compose down -v
```

---

## .dockerignore Files

Add `.dockerignore` to each service directory:

```
node_modules
npm-debug.log
.git
.gitignore
.DS_Store
dist
*.log
```

---

## Environment Configuration

### .env.example

```bash
# Azure Service Bus (for Pub/Sub)
SERVICE_BUS_CONNECTION_STRING=Endpoint=sb://...

# CQRS Ports
COMMAND_SERVICE_PORT=3001
QUERY_SERVICE_PORT=3002

# Service URLs
COMMAND_SERVICE_URL=http://command-service:3001
QUERY_SERVICE_URL=http://query-service:3002
```

### Load .env

```bash
# Create .env from example
cp .env.example .env

# Edit with your values
nano .env

# Docker Compose reads .env automatically
docker-compose up
```

---

## Docker Network

### Custom Network

```yaml
networks:
  cloud-patterns:
    driver: bridge
```

### Service Discovery

Services can communicate using service names:

```
command-service (hostname)
http://command-service:3001 (internal URL)
```

---

## Production Considerations

### Multi-stage Build

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production
EXPOSE 3001
CMD ["npm", "start"]
```

### Registry Push

```bash
# Tag image
docker tag cqrs-command myregistry.azurecr.io/cloud-patterns/command:latest

# Push to Azure Container Registry
docker push myregistry.azurecr.io/cloud-patterns/command:latest
```

### Health Checks

```yaml
services:
  command-service:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
```

---

## Kubernetes Deployment

### Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: command-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: command-service
  template:
    metadata:
      labels:
        app: command-service
    spec:
      containers:
      - name: command-service
        image: myregistry.azurecr.io/cloud-patterns/command:latest
        ports:
        - containerPort: 3001
        env:
        - name: PORT
          value: "3001"
        livenessProbe:
          httpGet:
            path: /health
            port: 3001
          initialDelaySeconds: 30
          periodSeconds: 10
```

---

## Troubleshooting

### Container Won't Start

```bash
# View logs
docker-compose logs command-service

# Check exit code
docker-compose ps

# Rebuild
docker-compose build --no-cache command-service
```

### Network Issues

```bash
# Inspect network
docker network inspect cloud-patterns

# Test DNS
docker-compose exec command-service nslookup query-service

# Ping service
docker-compose exec command-service ping query-service
```

### Port Conflicts

```bash
# Find process on port 3001
lsof -i :3001

# Change port in docker-compose.yml
ports:
  - "4001:3001"  # Map 4001 -> 3001
```

---

## Quick Reference

```bash
# Build all
docker-compose build

# Start all
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all
docker-compose stop

# Remove all
docker-compose down

# Clean everything
docker-compose down -v && docker system prune
```

---

**Happy containerizing! 🐳**
