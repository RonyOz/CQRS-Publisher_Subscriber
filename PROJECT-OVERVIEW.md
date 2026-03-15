# 📚 Project Overview

## ✅ What's Been Created

Your educational repository is now complete with two architectural pattern demonstrations:

### Project Statistics
- **2 Complete Modules**: CQRS and Pub/Sub
- **5 Microservices**: 2 (CQRS) + 3 (Pub/Sub)
- **21 Core Files**: Configuration + Implementation
- **4 Comprehensive Guides**: Setup, Quick Start, CQRS docs, Pub/Sub docs
- **100% TypeScript**: Modern, type-safe implementations

---

## 📂 Complete File Structure

```
CQRS-Publisher_Subscriber/
│
├── 📖 Documentation
│   ├── README.md                 ← Start here (comprehensive guide)
│   ├── QUICKSTART.md             ← 5-minute setup
│   ├── DOCKER.md                 ← Containerization guide
│   ├── PROJECT-OVERVIEW.md       ← This file
│   └── .env.example              ← Environment template
│
├── 📦 CQRS Module
│   ├── README.md                 ← CQRS pattern explanation
│   │
│   ├── command-service/          ← Write-side (Port 3001)
│   │   ├── src/index.ts          ← Implementation
│   │   ├── package.json          ← Dependencies
│   │   └── tsconfig.json         ← TypeScript config
│   │
│   └── query-service/            ← Read-side (Port 3002)
│       ├── src/index.ts          ← Implementation
│       ├── package.json          ← Dependencies
│       └── tsconfig.json         ← TypeScript config
│
├── 📡 Pub/Sub Module
│   ├── README.md                 ← Pub/Sub pattern explanation
│   │
│   ├── publisher/                ← Message sender
│   │   ├── src/index.ts          ← Implementation
│   │   ├── package.json          ← Dependencies
│   │   └── tsconfig.json         ← TypeScript config
│   │
│   ├── subscriber-a/             ← First receiver
│   │   ├── src/index.ts          ← Implementation
│   │   ├── package.json          ← Dependencies
│   │   └── tsconfig.json         ← TypeScript config
│   │
│   └── subscriber-b/             ← Second receiver
│       ├── src/index.ts          ← Implementation
│       ├── package.json          ← Dependencies
│       └── tsconfig.json         ← TypeScript config
│
├── .gitignore                    ← Git configuration
└── setup.sh                      ← Automated setup script
```

---

## 🎯 Quick Reference

### CQRS Pattern (No External Dependencies)

**What it demonstrates**: Separating Read (Query) and Write (Command) operations

```bash
# Terminal 1: Start Command Service (Writer)
cd cqrs/command-service
npm install && npm run dev    # Runs on port 3001

# Terminal 2: Start Query Service (Reader)
cd cqrs/query-service
npm install && npm run dev    # Runs on port 3002

# Terminal 3: Test it
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{"id": "user-001", "name": "John"}'

curl http://localhost:3002/query
```

**Key Files**:
- [cqrs/command-service/src/index.ts](../cqrs/command-service/src/index.ts) - Write service
- [cqrs/query-service/src/index.ts](../cqrs/query-service/src/index.ts) - Read service
- [cqrs/README.md](../cqrs/README.md) - Detailed pattern explanation

---

### Pub/Sub Pattern (Azure Service Bus)

**What it demonstrates**: Asynchronous message distribution to multiple independent subscribers

```bash
# Setup: Create Azure Service Bus resources (one-time)
RESOURCE_GROUP="cloud-patterns"
NAMESPACE_NAME="cloud-patterns-sb"

az group create --name $RESOURCE_GROUP --location eastus
az servicebus namespace create --resource-group $RESOURCE_GROUP --name $NAMESPACE_NAME
az servicebus topic create --resource-group $RESOURCE_GROUP --namespace-name $NAMESPACE_NAME --name demo-topic
az servicebus topic subscription create --resource-group $RESOURCE_GROUP --namespace-name $NAMESPACE_NAME --topic-name demo-topic --name subscription-a
az servicebus topic subscription create --resource-group $RESOURCE_GROUP --namespace-name $NAMESPACE_NAME --topic-name demo-topic --name subscription-b

# Get connection string
CONNECTION_STRING=$(az servicebus namespace authorization-rule keys list \
  --resource-group $RESOURCE_GROUP \
  --namespace-name $NAMESPACE_NAME \
  --name RootManageSharedAccessKey \
  --query primaryConnectionString \
  --output tsv)

# Set environment
export SERVICE_BUS_CONNECTION_STRING=$CONNECTION_STRING

# Terminal 1: Start Subscriber A
cd pubsub/subscriber-a
npm install && npm run dev

# Terminal 2: Start Subscriber B
cd pubsub/subscriber-b
npm install && npm run dev

# Terminal 3: Publish messages
cd pubsub/publisher
npm install && npm run dev

# Result: Both subscribers receive all messages independently!
```

**Key Files**:
- [pubsub/publisher/src/index.ts](../pubsub/publisher/src/index.ts) - Publisher
- [pubsub/subscriber-a/src/index.ts](../pubsub/subscriber-a/src/index.ts) - Subscriber A
- [pubsub/subscriber-b/src/index.ts](../pubsub/subscriber-b/src/index.ts) - Subscriber B
- [pubsub/README.md](../pubsub/README.md) - Detailed pattern explanation

---

## 🚀 Getting Started (3 Steps)

### Step 1: Clone and Navigate
```bash
cd CQRS-Publisher_Subscriber
```

### Step 2: Run Setup (Optional)
```bash
chmod +x setup.sh
./setup.sh    # Installs all dependencies automatically
```

### Step 3: Choose Your Path

**Option A: Learn CQRS** (5 minutes, no external setup)
```bash
# Follow the CQRS Pattern section above
```

**Option B: Learn Pub/Sub** (20 minutes, requires Azure)
```bash
# Follow the Pub/Sub Pattern section above
```

**Option C: Learn Both** (25 minutes total)
```bash
# Run CQRS first, then Pub/Sub
```

---

## 📚 Documentation Roadmap

### For Beginners
1. Start here: [README.md](../README.md) - Full overview
2. Quick setup: [QUICKSTART.md](../QUICKSTART.md) - Fastest path
3. Pick a pattern:
   - CQRS: [cqrs/README.md](../cqrs/README.md)
   - Pub/Sub: [pubsub/README.md](../pubsub/README.md)

### For Advanced Users
1. Understanding patterns: Main [README.md](../README.md)
2. Container setup: [DOCKER.md](../DOCKER.md)
3. Production ready: Review `Dockerfile` and `docker-compose.yml` templates
4. Azure Kubernetes: See [DOCKER.md](../DOCKER.md) for K8s manifests

### For Developers
- Study the source code:
  - [cqrs/command-service/src/index.ts](../cqrs/command-service/src/index.ts)
  - [cqrs/query-service/src/index.ts](../cqrs/query-service/src/index.ts)
  - [pubsub/publisher/src/index.ts](../pubsub/publisher/src/index.ts)
  - [pubsub/subscriber-a/src/index.ts](../pubsub/subscriber-a/src/index.ts)
  - [pubsub/subscriber-b/src/index.ts](../pubsub/subscriber-b/src/index.ts)

---

## 🎓 Learning Objectives

### By completing CQRS module, you'll understand:
- ✅ Separation of read and write concerns
- ✅ Independent scaling of services
- ✅ Service-to-service HTTP communication
- ✅ In-memory data storage patterns
- ✅ When to apply CQRS pattern

### By completing Pub/Sub module, you'll understand:
- ✅ Event-driven architecture
- ✅ Publisher-Subscriber messaging pattern
- ✅ Azure Service Bus concepts (Topics, Subscriptions)
- ✅ Decoupling of services
- ✅ Asynchronous message processing
- ✅ When to apply Pub/Sub pattern

---

## 🔧 Tech Stack

- **Runtime**: Node.js 16+
- **Language**: TypeScript 5.0+
- **Framework**: Express.js (HTTP APIs)
- **Azure Service**: Azure Service Bus
- **Deployment**: Docker/Kubernetes (optional)

### Dependencies by Service

**CQRS Services**:
- `express` - HTTP framework
- `axios` - HTTP client (Query Service)
- `@types/express`, `@types/node` - Type definitions
- `ts-node`, `typescript` - Development

**Pub/Sub Services**:
- `@azure/service-bus` - Azure SDK
- `@types/node` - Type definitions
- `ts-node`, `typescript` - Development

---

## 📊 Service Ports

| Service | Port | URL | Purpose |
|---------|------|-----|---------|
| Command Service | 3001 | http://localhost:3001 | CQRS Write-side |
| Query Service | 3002 | http://localhost:3002 | CQRS Read-side |
| Publisher | N/A | Azure Topic | Sends messages |
| Subscriber A | N/A | Azure Service Bus | Receives messages |
| Subscriber B | N/A | Azure Service Bus | Receives messages |

---

## ✨ Key Features

### CQRS Module
- ✅ **Clear separation** between command (write) and query (read)
- ✅ **HTTP REST API** for easy testing
- ✅ **In-memory storage** - no database required
- ✅ **Minimal dependencies** - focus on pattern learning
- ✅ **Health checks** on both services
- ✅ **Detailed logging** for tracing operations

### Pub/Sub Module
- ✅ **True decoupling** - publisher knows nothing about subscribers
- ✅ **Multiple subscribers** - demonstrates independent consumption
- ✅ **Azure Service Bus** - production-grade messaging
- ✅ **Scalable** - add more subscribers without changing publisher
- ✅ **Resilient** - failed subscriber doesn't block others
- ✅ **Event-driven design** - asynchronous by nature

---

## 🎯 Next Steps After Learning

### After CQRS
1. Add persistence layer (database integration)
2. Implement event sourcing
3. Add caching for read optimization
4. Consider eventual consistency model

### After Pub/Sub
1. Implement dead letter queue handling
2. Add message filtering in subscriptions
3. Implement retry logic with exponential backoff
4. Add correlation IDs for tracing

### General
1. Containerize with Docker
2. Deploy to Kubernetes
3. Add monitoring and observability
4. Implement CI/CD pipeline

---

## 🆘 Troubleshooting Quick Link

### CQRS Issues
- Port 3001/3002 already in use? See [README.md](../README.md#port-already-in-use)
- Can't connect services? See [README.md](../README.md#query-service-cannot-reach-command-service)

### Pub/Sub Issues
- Azure connection failed? See [README.md](../README.md#connection-string-issues)
- No messages received? See [README.md](../README.md#subscribers-not-receiving-messages)

---

## 📞 Resources

### Official Documentation
- [Microsoft CQRS Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/cqrs)
- [Azure Service Bus Docs](https://docs.microsoft.com/en-us/azure/service-bus-messaging/)
- [Event-Driven Architecture](https://microservices.io/patterns/data/event-driven-architecture.html)

### Learning Resources
- [CQRS by Martin Fowler](https://martinfowler.com/bliki/CQRS.html)
- [Published Language Pattern](https://martinfowler.com/eaaDev/PublishedLanguage.html)
- [Event Sourcing Pattern](https://martinfowler.com/eaaDev/EventSourcing.html)

---

## 📝 File Reference

### Configuration Files
| File | Purpose |
|------|---------|
| `.gitignore` | Git configuration |
| `.env.example` | Environment template |
| `package.json` | Node.js dependencies |
| `tsconfig.json` | TypeScript configuration |

### Implementation Files
| File | Purpose |
|------|---------|
| `src/index.ts` | Service implementation |

### Documentation Files
| File | Purpose |
|------|---------|
| `README.md` | Main guide (start here) |
| `QUICKSTART.md` | 5-minute quick start |
| `DOCKER.md` | Containerization guide |
| `PROJECT-OVERVIEW.md` | This file |
| `cqrs/README.md` | CQRS pattern details |
| `pubsub/README.md` | Pub/Sub pattern details |

---

## ✅ Verification Checklist

After setup, verify everything works:

### CQRS Module ✓
- [ ] Command Service starts on port 3001
- [ ] Query Service starts on port 3002
- [ ] Can POST to `/command` endpoint
- [ ] Can GET from `/query` endpoint
- [ ] Data persists between operations
- [ ] Health checks respond correctly

### Pub/Sub Module ✓
- [ ] Subscribers A and B start successfully
- [ ] Publisher connects to Azure Service Bus
- [ ] Both subscribers receive published messages
- [ ] Each subscriber processes independently
- [ ] Messages appear in both subscriptions

---

## 🎉 You're Ready!

Everything is set up. Choose your learning path:

1. **5-minute quick start**: `bash ./setup.sh && follow CQRS module`
2. **Comprehensive guide**: Read `README.md` then pick a module
3. **Hands-on learning**: Follow `QUICKSTART.md`

**Let's explore cloud patterns! 🚀**

---

*Last updated: March 2024*
