# 📊 Final Directory Structure & Setup Guide

## 🎯 Complete Project Layout

```
CQRS-Publisher_Subscriber/          ← Your repository root
│
├── 📖 DOCUMENTATION (5 files)
│   ├── README.md                  ← ⭐ START HERE (Main guide)
│   ├── QUICKSTART.md              ← 5-minute setup
│   ├── PROJECT-OVERVIEW.md        ← Visual guide
│   ├── CREATION-SUMMARY.md        ← What was built
│   ├── DOCKER.md                  ← Container guide
│   └── .env.example               ← Template for env vars
│
├── 🔧 CONFIGURATION
│   ├── .gitignore                 ← Git configuration
│   └── setup.sh                   ← Automated installer (executable)
│
├── 📦 CQRS MODULE (2 independent services)
│   ├── README.md                  ← CQRS pattern explained
│   │
│   ├── command-service/           ← Write-side (Port 3001)
│   │   ├── src/
│   │   │   └── index.ts           ← Implementation (~150 lines)
│   │   ├── package.json           ← Dependencies
│   │   └── tsconfig.json          ← TypeScript config
│   │
│   └── query-service/             ← Read-side (Port 3002)
│       ├── src/
│       │   └── index.ts           ← Implementation (~130 lines)
│       ├── package.json           ← Dependencies
│       └── tsconfig.json          ← TypeScript config
│
└── 📡 PUB/SUB MODULE (3 independent services)
    ├── README.md                  ← Pub/Sub pattern explained
    │
    ├── publisher/                 ← Sends to Azure Topic
    │   ├── src/
    │   │   └── index.ts           ← Implementation (~100 lines)
    │   ├── package.json           ← Dependencies
    │   └── tsconfig.json          ← TypeScript config
    │
    ├── subscriber-a/              ← Gets from subscription-a
    │   ├── src/
    │   │   └── index.ts           ← Implementation (~140 lines)
    │   ├── package.json           ← Dependencies
    │   └── tsconfig.json          ← TypeScript config
    │
    └── subscriber-b/              ← Gets from subscription-b
        ├── src/
        │   └── index.ts           ← Implementation (~140 lines)
        ├── package.json           ← Dependencies
        └── tsconfig.json          ← TypeScript config
```

---

## 📋 File Count Summary

```
Total Files: 22
├── TypeScript Source Files:     5  (.ts)
├── Configuration Files:         11 (.json, .gitignore, .env.example)
├── Documentation:               6  (.md, .sh)
└── Scripts:                     0  (setup.sh is a script)

Total Project Size: ~200 KB
├── Documentation: ~150 KB
├── Source Code:  ~50 KB
└── Configuration: ~5 KB
```

---

## 🚀 Getting Started - Quick Reference

### Step 1: Navigate to Project
```bash
cd /home/ronyoz/CQRS-Publisher_Subscriber
```

### Step 2: Choose Your Learning Path

#### 🟢 Path A: Quick Start (5 mins)
```bash
# Read the quick start
cat QUICKSTART.md

# Then run CQRS (needs 2 terminals)
cd cqrs/command-service && npm install && npm run dev   # Terminal 1
cd cqrs/query-service && npm install && npm run dev     # Terminal 2
```

#### 🟡 Path B: Comprehensive (30 mins)
```bash
# Read main guide
cat README.md

# Run CQRS module (as above)
# Then setup Azure and run Pub/Sub
```

#### 🔵 Path C: Full Stack (2+ hours)
```bash
# Study everything
cat README.md
cat cqrs/README.md
cat pubsub/README.md
cat DOCKER.md

# Run and test both modules
# Review source code
# Plan production deployment
```

---

## 📚 Documentation Reading Order

### For Learning the Patterns (Recommended)

**First** (10 mins):
```
1. README.md              → Overview & architecture
2. QUICKSTART.md          → Immediate setup
```

**Then Choose**:
```
Option A: CQRS Pattern
   └─ cqrs/README.md      → Deep dive into CQRS

Option B: Pub/Sub Pattern
   └─ pubsub/README.md    → Deep dive into Pub/Sub

Option C: Both (Recommended!)
   ├─ cqrs/README.md
   └─ pubsub/README.md
```

**Advanced** (15+ mins):
```
- PROJECT-OVERVIEW.md     → Visual guide & checklist
- DOCKER.md               → Containerization
- CREATION-SUMMARY.md     → What was built
```

---

## 🔌 Service Quick Start

### CQRS Module

```bash
# Terminal 1: Command Service (Writer)
Terminal 1 $ cd cqrs/command-service
Terminal 1 $ npm install
Terminal 1 $ npm run dev
# Output: Running on http://localhost:3001

# Terminal 2: Query Service (Reader)
Terminal 2 $ cd cqrs/query-service
Terminal 2 $ npm install
Terminal 2 $ npm run dev
# Output: Running on http://localhost:3002

# Terminal 3: Test It
Terminal 3 $ curl -X POST http://localhost:3001/command \
              -H "Content-Type: application/json" \
              -d '{"id":"user-001","name":"John"}'

Terminal 3 $ curl http://localhost:3002/query
```

### Pub/Sub Module

```bash
# Pre-requisite: Azure Service Bus setup
export SERVICE_BUS_CONNECTION_STRING="<your-connection-string>"

# Terminal 1: Subscriber A
Terminal 1 $ cd pubsub/subscriber-a
Terminal 1 $ npm install && npm run dev

# Terminal 2: Subscriber B
Terminal 2 $ cd pubsub/subscriber-b  
Terminal 2 $ npm install && npm run dev

# Terminal 3: Publisher
Terminal 3 $ cd pubsub/publisher
Terminal 3 $ npm install && npm run dev

# Result: Both subscribers receive all messages!
```

---

## 🛠️ Automated Setup

```bash
# From repository root
chmod +x setup.sh          # Already done, but shown here
./setup.sh                 # Installs all dependencies

# Output:
# ✓ Command Service dependencies installed
# ✓ Query Service dependencies installed
# ✓ Publisher dependencies installed
# ✓ Subscriber A dependencies installed
# ✓ Subscriber B dependencies installed
```

---

## 📱 API Endpoints Reference

### CQRS Endpoints

| Method | URL | Purpose | Body |
|--------|-----|---------|------|
| POST | `http://localhost:3001/command` | Create/Update item | `{"id":"...", "name":"..."}` |
| GET | `http://localhost:3001/command/stats` | Get all items | None |
| GET | `http://localhost:3002/query` | Query all (read-side) | None |
| GET | `http://localhost:3002/query/:id` | Query specific | None |
| GET | `http://localhost:3001/health` | Health check | None |
| GET | `http://localhost:3002/health` | Health check | None |

### Example Requests

```bash
# Create item
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{
    "id": "user-001",
    "name": "Alice Johnson"
  }'

# Query all
curl http://localhost:3002/query | jq

# Query specific
curl http://localhost:3002/query/user-001 | jq

# Health checks
curl http://localhost:3001/health | jq
curl http://localhost:3002/health | jq
```

---

## 🐳 Docker Quick Start

### Build All Services

```bash
# From root directory, if you have Dockerfile in each service:
docker-compose build

# Start all
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all
docker-compose down
```

See [DOCKER.md](DOCKER.md) for detailed container setup.

---

## ✅ Verification Checklist

After installations, verify everything:

```bash
# ✓ CQRS Module
[ ] Command Service starts (port 3001)
[ ] Query Service starts (port 3002)
[ ] Services communicate correctly
[ ] POST /command works
[ ] GET /query works

# ✓ Pub/Sub Module
[ ] SERVICE_BUS_CONNECTION_STRING is set
[ ] Subscribers connect to Azure
[ ] Publisher sends messages
[ ] Both subscribers receive all messages
[ ] Messages process independently
```

---

## 🎓 Learning Outcomes

### After CQRS (30 mins)
You'll understand:
- ✅ Separation of read and write concerns
- ✅ How to scale read/write independently
- ✅ Service-to-service communication
- ✅ When to apply CQRS pattern

### After Pub/Sub (30 mins)
You'll understand:
- ✅ Event-driven architecture
- ✅ Publisher-Subscriber pattern
- ✅ Azure Service Bus concepts
- ✅ Decoupling services
- ✅ Asynchronous processing
- ✅ When to apply Pub/Sub pattern

### Combined Learning
- ✅ Cloud architecture patterns
- ✅ Microservices design
- ✅ Azure service integration
- ✅ TypeScript best practices
- ✅ Docker containerization (optional)

---

## 📞 Resources & Help

### In This Repository
- **Main Guide**: [README.md](README.md)
- **Quick Setup**: [QUICKSTART.md](QUICKSTART.md)
- **CQRS Details**: [cqrs/README.md](cqrs/README.md)
- **Pub/Sub Details**: [pubsub/README.md](pubsub/README.md)
- **Docker Setup**: [DOCKER.md](DOCKER.md)

### External Resources
- [Microsoft CQRS Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/cqrs)
- [Azure Service Bus](https://docs.microsoft.com/en-us/azure/service-bus-messaging/)
- [Event-Driven Architecture](https://microservices.io/patterns/data/event-driven-architecture.html)
- [Martin Fowler - CQRS](https://martinfowler.com/bliki/CQRS.html)

---

## 🐛 Troubleshooting Quick Links

### CQRS Issues
- Port already in use? → See README.md#port-already-in-use
- Services won't connect? → See README.md#query-service-cannot-reach-command-service
- npm install fails? → `rm -rf node_modules package-lock.json && npm install`

### Pub/Sub Issues
- Azure connection failed? → See README.md#connection-failed-error
- Missing Topic/Subscription? → See README.md#topic-or-subscription-not-found
- No messages received? → See README.md#no-messages-received-by-subscribers

---

## 🔄 Development Workflow

### Making Changes

```bash
# CQRS Source Code
cqrs/command-service/src/index.ts    ← Edit here
cqrs/query-service/src/index.ts      ← Edit here

# Pub/Sub Source Code
pubsub/publisher/src/index.ts        ← Edit here
pubsub/subscriber-a/src/index.ts     ← Edit here
pubsub/subscriber-b/src/index.ts     ← Edit here
```

### Testing Changes

```bash
# For TypeScript, run:
npm run dev          # Starts ts-node (dev mode)

# For production:
npm run build        # Compiles TypeScript
npm start           # Runs compiled code
```

---

## 📊 Module Dependencies

```
┌─ CQRS Module
│  ├─ Command Service
│  │  └─ Dependencies: express, @types/express
│  └─ Query Service
│     └─ Dependencies: express, axios, @types/express
│
└─ Pub/Sub Module
   ├─ Publisher
   │  └─ Dependencies: @azure/service-bus
   ├─ Subscriber A
   │  └─ Dependencies: @azure/service-bus
   └─ Subscriber B
      └─ Dependencies: @azure/service-bus

All services use:
- typescript, ts-node, @types/node
- For development
```

---

## 🎉 You're All Set!

```
✅ Repository created
✅ All files in place
✅ Documentation complete
✅ Services ready to run
✅ Examples provided
✅ Troubleshooting guide included

➜ Next: Read README.md or QUICKSTART.md
```

---

## 🗺️ Navigation

```
START HERE          →  README.md
  ↓
QUICK START         →  QUICKSTART.md
  ↓
Choose Module:
  ├─ CQRS            →  cqrs/README.md
  └─ Pub/Sub         →  pubsub/README.md
  ↓
ADVANCED:
  ├─ Docker          →  DOCKER.md
  ├─ Overview        →  PROJECT-OVERVIEW.md
  └─ Summary         →  CREATION-SUMMARY.md (this file)
```

---

**Welcome to Cloud Patterns Demo! 🚀**

Happy learning and exploring architectural patterns!

---

*For the latest information, always check the respective README.md files in each module directory.*
