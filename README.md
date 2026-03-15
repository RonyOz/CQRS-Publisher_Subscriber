# 📚 Cloud Patterns Demo - CQRS & Publisher-Subscriber

An educational repository demonstrating two fundamental architectural patterns using **Azure** and **Node.js/TypeScript**:

1. **CQRS (Command Query Responsibility Segregation)** - Separating read and write operations
2. **Publisher-Subscriber using Azure Service Bus** - Asynchronous messaging without coupling

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running CQRS Module](#running-cqrs-module)
- [Running Pub/Sub Module](#running-pubsub-module)
- [Project Structure](#project-structure)
- [Learning Resources](#learning-resources)

---

## 🎯 Project Overview

This repository provides **minimal, clear implementations** of two architectural patterns commonly used in cloud applications:

### Pattern 1: CQRS

**What it is**: A pattern that separates handling write operations (Commands) from handling read operations (Queries) into two independent services.

**Why use it**:
- Scale read and write operations independently
- Different optimization strategies for each operation
- Simpler business logic separation
- Easier to understand and maintain

**In this demo**: A Command Service handles writes, and a Query Service handles reads. They communicate through a simple API.

---

### Pattern 2: Publisher-Subscriber

**What it is**: A messaging pattern where a Publisher sends messages to a Topic, and multiple independent Subscribers receive those messages from their own Subscriptions.

**Why use it**:
- Decouple services - they don't need to know about each other
- One publisher, many subscribers
- Each subscriber processes messages independently
- Enable event-driven architectures

**In this demo**: Azure Service Bus provides the Topic and Subscriptions infrastructure.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         CQRS Module                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐        ┌──────────────────┐         │
│  │ Command Service  │        │ Query Service    │         │
│  │ (Write-Side)     │◄─────► │ (Read-Side)      │         │
│  │ POST /command    │        │ GET /query       │         │
│  │ Port: 3001       │        │ Port: 3002       │         │
│  └──────────────────┘        └──────────────────┘         │
│         ▲                              ▲                   │
│         │ HTTP                         │ HTTP              │
│         │ Requests                     │ Requests          │
│         └──────────────────────────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              Publisher-Subscriber Module                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐                                          │
│  │ Publisher    │──┐                                       │
│  │              │  │                                       │
│  └──────────────┘  │  ┌──────────────────────────┐        │
│                    │  │  Azure Service Bus       │        │
│                    └─►│  Topic: demo-topic       │        │
│                       │                          │        │
│                       │  ┌────────────────┐      │        │
│                       │  │ subscription-a │      │        │
│                       │  └────────────────┘      │        │
│                       │                          │        │
│  ┌────────────────┐   │  ┌────────────────┐      │        │
│  │ Subscriber A   │◄──┤  │ subscription-b │      │        │
│  └────────────────┘   │  └────────────────┘      │        │
│                       └──────────────────────────┘        │
│  ┌────────────────┐                                       │
│  │ Subscriber B   │◄──┐                                   │
│  └────────────────┘   │                                   │
│                       │ Messages routed to both           │
│                       │ subscriptions automatically       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Prerequisites

### Local Development
- **Node.js** 16+ or **17+**
- **npm** (comes with Node.js)
- **TypeScript 5.0+**

### For Pub/Sub Module Only
- **Azure Subscription** (free tier available at [azure.microsoft.com/free](https://azure.microsoft.com/free))
- **Azure Service Bus Namespace** with:
  - 1 Topic named `demo-topic`
  - 2 Subscriptions: `subscription-a` and `subscription-b`
- **Connection String** for authentication

### Optional Tools
- **Docker** (for containerized deployment)
- **VS Code** with REST Client extension (for testing HTTP endpoints)
- **Postman** (alternative for testing HTTP endpoints)

---

## 💾 Installation

### Step 1: Clone the repository

```bash
git clone https://github.com/yourusername/cloud-patterns-demo.git
cd CQRS-Publisher_Subscriber
```

### Step 2: Install dependencies for all services

#### CQRS Module
```bash
# Command Service
cd cqrs/command-service
npm install

# Query Service
cd ../query-service
npm install
cd ../../
```

#### Pub/Sub Module
```bash
# Publisher
cd pubsub/publisher
npm install

# Subscriber A
cd ../subscriber-a
npm install

# Subscriber B
cd ../subscriber-b
npm install
cd ../../
```

---

## 🚀 Running CQRS Module

The CQRS module demonstrates **separated read and write operations**.

### Prerequisites
- No external dependencies required
- Both services run locally
- In-memory storage (resets on restart)

### Start Command Service (Writer)

Open terminal 1 and run:

```bash
cd cqrs/command-service
npm run dev
```

Expected output:
```
╔═══════════════════════════════════════╗
║  COMMAND SERVICE (CQRS - Write Side)  ║
║  Running on http://localhost:3001     ║
╚═══════════════════════════════════════╝
```

### Start Query Service (Reader)

Open terminal 2 and run:

```bash
cd cqrs/query-service
npm run dev
```

Expected output:
```
╔═══════════════════════════════════════╗
║  QUERY SERVICE (CQRS - Read Side)     ║
║  Running on http://localhost:3002     ║
║  Reading from: http://localhost:3001  ║
╚═══════════════════════════════════════╝
```

### Test the CQRS Pattern

#### Option 1: Using curl

**1. Send a command (write operation)**

```bash
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{
    "id": "user-001",
    "name": "Alice Johnson"
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "Command executed successfully",
  "data": {
    "id": "user-001",
    "name": "Alice Johnson",
    "createdAt": "2024-03-14T10:30:00.000Z"
  }
}
```

**2. Query the data (read operation)**

```bash
curl http://localhost:3002/query
```

Expected response:
```json
{
  "message": "Query Service Response (Read-side)",
  "queryTime": "2024-03-14T10:30:15.000Z",
  "data": {
    "message": "Command Service Stats (Write-side)",
    "totalItems": 1,
    "items": [
      {
        "id": "user-001",
        "name": "Alice Johnson",
        "createdAt": "2024-03-14T10:30:00.000Z"
      }
    ]
  }
}
```

**3. Add more commands**

```bash
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{"id": "user-002", "name": "Bob Smith"}'

curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{"id": "user-003", "name": "Carol White"}'
```

**4. Query specific item**

```bash
curl http://localhost:3002/query/user-001
```

#### Option 2: Using VS Code REST Client

Create a file `test.http` in the root directory:

```http
### Send command
POST http://localhost:3001/command
Content-Type: application/json

{
  "id": "user-001",
  "name": "Alice Johnson"
}

### Query all data
GET http://localhost:3002/query

### Query specific item
GET http://localhost:3002/query/user-001

### Health check
GET http://localhost:3001/health
GET http://localhost:3002/health
```

Click "Send Request" above each endpoint.

---

## 🌐 Running Pub/Sub Module

The Publisher-Subscriber module demonstrates **decoupled, event-driven communication** using Azure Service Bus.

### Prerequisites

1. **Create Azure Service Bus resources** (if not already created):

   ```bash
   # Install Azure CLI (if not already installed)
   # https://docs.microsoft.com/cli/azure/install-azure-cli

   # Login to Azure
   az login

   # Create resource group
   az group create --name my-cloud-patterns --location eastus

   # Create Service Bus namespace
   az servicebus namespace create \
     --resource-group my-cloud-patterns \
     --name my-cloud-patterns-sb \
     --location eastus

   # Create topic
   az servicebus topic create \
     --resource-group my-cloud-patterns \
     --namespace-name my-cloud-patterns-sb \
     --name demo-topic

   # Create subscriptions
   az servicebus topic subscription create \
     --resource-group my-cloud-patterns \
     --namespace-name my-cloud-patterns-sb \
     --topic-name demo-topic \
     --name subscription-a

   az servicebus topic subscription create \
     --resource-group my-cloud-patterns \
     --namespace-name my-cloud-patterns-sb \
     --topic-name demo-topic \
     --name subscription-b
   ```

2. **Get Connection String**:

   ```bash
   az servicebus namespace authorization-rule keys list \
     --resource-group my-cloud-patterns \
     --namespace-name my-cloud-patterns-sb \
     --name RootManageSharedAccessKey \
     --query primaryConnectionString \
     --output tsv
   ```

3. **Set Environment Variable**:

   ```bash
   export SERVICE_BUS_CONNECTION_STRING="your-connection-string-here"
   ```

   Or create a `.env` file in `pubsub/` directory:
   ```
   SERVICE_BUS_CONNECTION_STRING=your-connection-string-here
   ```

### Start Subscribers (Receivers)

**Terminal 1 - Subscriber A:**

```bash
cd pubsub/subscriber-a
npm run dev
```

Expected output:
```
╔════════════════════════════════════════════╗
║  SUBSCRIBER A - Azure Service Bus          ║
║  Topic: demo-topic                         ║
║  Subscription: subscription-a              ║
╚════════════════════════════════════════════╝

⏳ Listening for messages on Subscription: subscription-a

✅ Subscriber A is active and listening...
Press Ctrl+C to exit.
```

**Terminal 2 - Subscriber B:**

```bash
cd pubsub/subscriber-b
npm run dev
```

Expected output:
```
╔════════════════════════════════════════════╗
║  SUBSCRIBER B - Azure Service Bus          ║
║  Topic: demo-topic                         ║
║  Subscription: subscription-b              ║
╚════════════════════════════════════════════╝

⏳ Listening for messages on Subscription: subscription-b

✅ Subscriber B is active and listening...
Press Ctrl+C to exit.
```

### Send Messages (Publisher)

**Terminal 3 - Publisher:**

```bash
cd pubsub/publisher
npm run dev
```

Expected output:
```
╔════════════════════════════════════════════╗
║  PUBLISHER - Azure Service Bus            ║
║  Topic: demo-topic                         ║
╚════════════════════════════════════════════╝

📤 Sending messages to topic...

✓ Message 1/3 sent:
  Event: UserCreated
  Timestamp: 2024-03-14T10:30:00.000Z

✓ Message 2/3 sent:
  Event: UserCreated
  Timestamp: 2024-03-14T10:30:01.000Z

✓ Message 3/3 sent:
  Event: OrderPlaced
  Timestamp: 2024-03-14T10:30:02.000Z

✅ All messages sent successfully!

💡 Subscribers should now receive these messages from their subscriptions.
```

### Verify Message Reception

Both **Subscriber A** and **Subscriber B** terminals should display:

```
📨 Message received by Subscriber A:
   Event: UserCreated
   Data: {
     "id": "1",
     "event": "UserCreated",
     "name": "Alice Johnson",
     "timestamp": "2024-03-14T10:30:00.000Z"
   }
   Received at: 2024-03-14T10:30:02.000Z
```

This confirms that **both subscribers independently received the same message** from the Topic!

---

## 📂 Project Structure

```
CQRS-Publisher_Subscriber/
│
├── cqrs/
│   ├── command-service/              # Write-side service
│   │   ├── src/
│   │   │   └── index.ts              # Command Service implementation
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── query-service/                # Read-side service
│       ├── src/
│       │   └── index.ts              # Query Service implementation
│       ├── package.json
│       └── tsconfig.json
│
├── pubsub/
│   ├── publisher/                    # Message sender
│   │   ├── src/
│   │   │   └── index.ts              # Publisher implementation
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── subscriber-a/                 # First message receiver
│   │   ├── src/
│   │   │   └── index.ts              # Subscriber A implementation
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── subscriber-b/                 # Second message receiver
│       ├── src/
│       │   └── index.ts              # Subscriber B implementation
│       ├── package.json
│       └── tsconfig.json
│
├── .gitignore
└── README.md                         # This file
```

---

## 🎓 Learning Resources

### CQRS Pattern
- **Microsoft Docs**: [CQRS Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/cqrs)
- **Martin Fowler**: [CQRS by Martin Fowler](https://martinfowler.com/bliki/CQRS.html)
- **Key Concepts**:
  - Command: Write operation (side effects)
  - Query: Read operation (no side effects)
  - Separate models for read and write
  - Can scale independently

### Publisher-Subscriber Pattern
- **Azure Service Bus Concepts**: [Topics and subscriptions](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-queues-topics-subscriptions)
- **Event-Driven Architecture**: [Introduction](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/publish-subscribe-events)
- **Key Concepts**:
  - Decoupling between publisher and subscribers
  - Topic acts as distribution mechanism
  - Each subscriber has independent subscription
  - Messages delivered to all subscriptions

### Related Patterns
- **Event Sourcing**: Store state as sequence of events
- **SAGA Pattern**: Cross-service transaction handling
- **Async Messaging**: Remove synchronous dependencies

---

## 🔧 Development

### Building for Production

#### CQRS Services
```bash
# Command Service
cd cqrs/command-service
npm run build

# Query Service
cd cqrs/query-service
npm run build
```

#### Pub/Sub Services
```bash
# Publisher
cd pubsub/publisher
npm run build

# Subscribers
cd pubsub/subscriber-a
npm run build

cd pubsub/subscriber-b
npm run build
```

### Running Production Builds
```bash
# After building
npm start
```

---

## 📝 Notes

- **In-memory storage**: CQRS module uses in-memory storage and resets on restart
- **No persistence**: This is a learning example; add a database for production
- **Local execution**: Perfect for understanding patterns without cloud complexity
- **Minimal dependencies**: Focus on pattern understanding, not framework features

---

## 🤝 Contributing

Suggestions and improvements are welcome! This is an educational project.

---

## 📄 License

This project is provided as-is for educational purposes.

---

## ❓ Troubleshooting

### CQRS Module

**Query Service cannot reach Command Service**
```
Error: Cannot reach Command Service at http://localhost:3001
```
Solution: Make sure Command Service is running on port 3001

**Port already in use**
```bash
# Kill process on port 3001
lsof -ti:3001 | xargs kill -9

# Or use different ports
PORT=4001 npm run dev
```

### Pub/Sub Module

**Connection failed error**
```
Connection failed. Check your SERVICE_BUS_CONNECTION_STRING environment variable.
```
Solution: 
1. Verify `SERVICE_BUS_CONNECTION_STRING` is set
2. Verify Service Bus Namespace exists in Azure
3. Verify Topic `demo-topic` exists
4. Verify Subscriptions exist

**Topic or Subscription not found**
```bash
# List existing topics
az servicebus topic list \
  --resource-group my-cloud-patterns \
  --namespace-name my-cloud-patterns-sb

# List existing subscriptions
az servicebus topic subscription list \
  --resource-group my-cloud-patterns \
  --namespace-name my-cloud-patterns-sb \
  --topic-name demo-topic
```

**No messages received by subscribers**
1. Ensure subscribers are running BEFORE publishing
2. Check subscription names match exactly: `subscription-a`, `subscription-b`
3. Verify connection string is correct

---

## 📞 Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review Azure Service Bus documentation
3. Check console error messages for details

---

**Happy learning! 🚀**
# CQRS-Publisher_Subscriber
