# Quick Start Guide

## ⚡ 5-Minute Setup

### CQRS Module (No external dependencies)

```bash
# Terminal 1
cd cqrs/command-service
npm install
npm run dev

# Terminal 2
cd cqrs/query-service
npm install
npm run dev

# Terminal 3 - Test
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{"id": "user-001", "name": "John Doe"}'

curl http://localhost:3002/query
```

---

## Azure Service Bus Setup (5 minutes)

### Prerequisites
- Azure CLI installed (`az --version`)
- Azure subscription

### Commands

```bash
# 1. Login to Azure
az login

# 2. Create resource group
az group create --name cloud-patterns --location eastus

# 3. Create Service Bus namespace
az servicebus namespace create \
  --resource-group cloud-patterns \
  --name cloud-patterns-sb \
  --location eastus

# 4. Create topic
az servicebus topic create \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb \
  --name demo-topic

# 5. Create subscriptions
az servicebus topic subscription create \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb \
  --topic-name demo-topic \
  --name subscription-a

az servicebus topic subscription create \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb \
  --topic-name demo-topic \
  --name subscription-b

# 6. Get connection string
az servicebus namespace authorization-rule keys list \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb \
  --name RootManageSharedAccessKey \
  --query primaryConnectionString \
  --output tsv
```

### Pub/Sub Module (After Azure setup)

```bash
# 1. Set environment variable
export SERVICE_BUS_CONNECTION_STRING="<paste-connection-string-here>"

# 2. Start subscribers (Terminal 1 & 2)
cd pubsub/subscriber-a && npm install && npm run dev
cd pubsub/subscriber-b && npm install && npm run dev

# 3. Publish messages (Terminal 3)
cd pubsub/publisher && npm install && npm run dev
```

---

## File Structure

```
├── cqrs/
│   ├── command-service/    # Port 3001 (Write)
│   └── query-service/      # Port 3002 (Read)
├── pubsub/
│   ├── publisher/          # Sends to Topic
│   ├── subscriber-a/       # Listens to subscription-a
│   └── subscriber-b/       # Listens to subscription-b
└── README.md              # Full documentation
```

---

## Common Commands

### Terminal Operations
```bash
# Kill all node processes
pkill -f node

# Kill specific port
lsof -ti:3001 | xargs kill -9
```

### Testing CQRS
```bash
# Send command
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{"id": "1", "name": "Test"}'

# Query all
curl http://localhost:3002/query

# Query specific
curl http://localhost:3002/query/1

# Health
curl http://localhost:3001/health
curl http://localhost:3002/health
```

---

## Troubleshooting

### Port in use
```bash
lsof -i :3001
# Then kill the process
```

### Service Bus connection
```bash
# Verify connection string
echo $SERVICE_BUS_CONNECTION_STRING

# List topics
az servicebus topic list \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb
```

### Node modules issues
```bash
# Clean and reinstall
rm -rf node_modules package-lock.json
npm install
```

---

## Resources

- **CQRS Pattern**: https://martinfowler.com/bliki/CQRS.html
- **Azure Service Bus**: https://docs.microsoft.com/azure/service-bus-messaging/
- **Event-Driven Architecture**: https://microservices.io/patterns/db/event-sourcing.html

---

**Ready to explore cloud patterns? 🚀**
