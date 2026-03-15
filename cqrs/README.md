# CQRS Module - Command Query Responsibility Segregation

## 📖 Overview

This module demonstrates the **CQRS pattern** - a fundamental architectural pattern that separates write operations (Commands) from read operations (Queries) into independent services.

## 🎯 What is CQRS?

CQRS stands for **Command Query Responsibility Segregation**. It's based on the principle of separating:

- **Commands**: Operations that modify state (Create, Update, Delete)
- **Queries**: Operations that retrieve state (Read only, no side effects)

```
Traditional Monolithic Approach:
┌─────────────────────────────┐
│  Single Model               │
│  ├─ Reads                   │
│  └─ Writes                  │
└─────────────────────────────┘

CQRS Pattern:
┌──────────────────┐  ┌──────────────────┐
│ Write Model      │  │ Read Model       │
│ (Commands)       │  │ (Queries)        │
│                  │  │                  │
│ - Create Order   │  │ - List Orders    │
│ - Update Status  │  │ - Get Statistics │
│ - Delete Item    │  │ - Search Items   │
└──────────────────┘  └──────────────────┘
         ▲                     ▲
         │                     │
         └─── Can be          │
              optimized    Can be
              independently optimized
```

## 🏗️ Architecture

```
┌───────────────────────────────────────────────────────────┐
│                      CQRS Module                           │
├───────────────────────────────────────────────────────────┤
│                                                            │
│  ┌─────────────────────┐      ┌─────────────────────┐    │
│  │ COMMAND SERVICE     │      │ QUERY SERVICE       │    │
│  │ (Write-side)        │      │ (Read-side)         │    │
│  │                     │      │                     │    │
│  │ Port: 3001          │      │ Port: 3002          │    │
│  │                     │      │                     │    │
│  │ Endpoints:          │      │ Endpoints:          │    │
│  │ POST /command       │      │ GET /query          │    │
│  │ GET /command/stats  │      │ GET /query/:id      │    │
│  │                     │      │ GET /health         │    │
│  │ Responsibilities:   │      │                     │    │
│  │ • Accept commands   │      │ Responsibilities:   │    │
│  │ • Validate input    │      │ • Fetch data        │    │
│  │ • Modify state      │      │ • Format response   │    │
│  │ • Store data        │      │ • No modifications  │    │
│  │                     │      │                     │    │
│  └─────────────────────┘      └─────────────────────┘    │
│           △                              △                 │
│           │         HTTP                 │                 │
│           └──────────────────────────────┘                 │
│                                                            │
│  ┌────────────────────────────────────────────────────┐  │
│  │  In-Memory Data Store                             │  │
│  │  (Persisted on Command Service, read by Query)    │  │
│  │  Map<string, DataItem>                            │  │
│  └────────────────────────────────────────────────────┘  │
│                                                            │
└───────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Node.js 16+
- No external dependencies

### Installation

```bash
# Install dependencies for both services
cd cqrs/command-service && npm install && cd ../..
cd cqrs/query-service && npm install && cd ../..
```

### Running

**Terminal 1 - Command Service (Writer)**
```bash
cd cqrs/command-service
npm run dev
```

**Terminal 2 - Query Service (Reader)**
```bash
cd cqrs/query-service
npm run dev
```

## 📡 API Reference

### Command Service (Write-Side)

#### POST /command
Executes a command to create or modify data.

**Request:**
```json
{
  "id": "user-001",
  "name": "John Doe"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Command executed successfully",
  "data": {
    "id": "user-001",
    "name": "John Doe",
    "createdAt": "2024-03-14T10:30:00.000Z"
  }
}
```

**Example:**
```bash
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{"id": "user-001", "name": "John Doe"}'
```

#### GET /command/stats
Returns stats and all stored items (internal read of write-side data).

**Response:**
```json
{
  "message": "Command Service Stats (Write-side)",
  "totalItems": 2,
  "items": [
    {
      "id": "user-001",
      "name": "John Doe",
      "createdAt": "2024-03-14T10:30:00.000Z"
    },
    {
      "id": "user-002",
      "name": "Jane Smith",
      "createdAt": "2024-03-14T10:31:00.000Z"
    }
  ]
}
```

#### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "Command Service is running",
  "port": 3001
}
```

---

### Query Service (Read-Side)

#### GET /query
Retrieves all data from Command Service.

**Response:**
```json
{
  "message": "Query Service Response (Read-side)",
  "queryTime": "2024-03-14T10:30:15.000Z",
  "data": {
    "message": "Command Service Stats (Write-side)",
    "totalItems": 2,
    "items": [...]
  }
}
```

**Example:**
```bash
curl http://localhost:3002/query
```

#### GET /query/:id
Retrieves a specific item by ID.

**Response:**
```json
{
  "message": "Query Service Response (Read-side)",
  "queryTime": "2024-03-14T10:30:15.000Z",
  "data": {
    "id": "user-001",
    "name": "John Doe",
    "createdAt": "2024-03-14T10:30:00.000Z"
  }
}
```

**Example:**
```bash
curl http://localhost:3002/query/user-001
```

#### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "Query Service is running",
  "port": 3002
}
```

## 🔄 Complete Example

### Step 1: Start both services

```bash
# Terminal 1
cd cqrs/command-service && npm run dev

# Terminal 2
cd cqrs/query-service && npm run dev
```

### Step 2: Create some data

```bash
# Create user 1
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{"id": "user-001", "name": "Alice"}'

# Create user 2
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{"id": "user-002", "name": "Bob"}'

# Create user 3
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{"id": "user-003", "name": "Charlie"}'
```

### Step 3: Query the data

```bash
# Get all data through Query Service
curl http://localhost:3002/query | jq

# Get specific user
curl http://localhost:3002/query/user-001 | jq

# Get query statistics
curl http://localhost:3001/command/stats | jq
```

## 💡 Key Concepts

### 1. Separation of Concerns
- Command Service handles all writes
- Query Service handles all reads
- Each optimized independently

### 2. Scalability
```
Write Operations:
- Typically fewer in volume
- More complex validation
- Can be vertically scaled

Read Operations:
- Typically higher volume
- Simpler retrieval logic
- Can be horizontally scaled
```

### 3. Data Consistency
- Single source of truth (Command Service store)
- Query Service reads directly from Command Service
- Can add caching/replication for advanced scenarios

## 🎓 When to Use CQRS

### ✅ Good Use Cases
- Systems with different read/write patterns
- High read volume compared to writes
- Complex business logic for commands
- Needing independent scaling
- Event-sourced systems

### ❌ Not Ideal For
- Simple CRUD applications
- Monolithic systems
- When read/write patterns are similar
- Small-scale applications with minimal traffic

## 🔌 Integration Points

### Adding a Database

Replace in-memory store with persistent storage:

```typescript
// Before: Map storage
const store: Map<string, DataItem> = new Map();

// After: Database integration
import mongoose from 'mongoose';

const itemSchema = new mongoose.Schema({
  id: String,
  name: String,
  createdAt: Date
});

const Item = mongoose.model('Item', itemSchema);
```

### Adding Event Publishing

Emit events when commands execute:

```typescript
app.post('/command', async (req, res) => {
  // ... execute command ...
  
  // Publish event
  await publishEvent({
    type: 'ItemCreated',
    data: item
  });
});
```

## 🏃 Performance Considerations

### Command Service
- Validate input thoroughly
- Apply business rules
- Consider batch operations
- Monitor write throughput

### Query Service
- Cache results if needed
- Consider read replicas
- Implement pagination
- Monitor read latency

## 📚 Further Learning

### CQRS Variants

**1. Basic CQRS** (This implementation)
- Single write model
- Single read model
- Shared database
- Simple synchronization

**2. Eventual Consistency**
- Separate databases
- Asynchronous synchronization
- Event sourcing
- Snapshots for performance

**3. Polyglot Persistence**
- Different storage for reads (NoSQL, cache)
- Different storage for writes (RDBMS)
- ETL processes
- Specialized queries

## 🐛 Troubleshooting

### Query Service cannot reach Command Service

**Problem:**
```
Error: Cannot reach Command Service at http://localhost:3001
```

**Solution:**
```bash
# Ensure Command Service is running
lsof -i :3001  # Check if port 3001 is in use

# Or start with explicit host
cd cqrs/command-service
PORT=3001 npm run dev
```

### Port Already in Use

**Solution:**
```bash
# Find and kill process on port
lsof -ti:3001 | xargs kill -9

# Or use different ports
cd cqrs/command-service
PORT=4001 COMMAND_SERVICE_PORT=4001 npm run dev

cd cqrs/query-service
PORT=4002 COMMAND_SERVICE_URL=http://localhost:4001 npm run dev
```

## 📖 File Structure

```
cqrs/
├── command-service/
│   ├── src/
│   │   └── index.ts           # Command service implementation
│   ├── package.json           # Dependencies and scripts
│   └── tsconfig.json          # TypeScript configuration
│
└── query-service/
    ├── src/
    │   └── index.ts           # Query service implementation
    ├── package.json           # Dependencies and scripts
    └── tsconfig.json          # TypeScript configuration
```

---

## 🎯 Next Steps

1. ✅ Run both services locally
2. ✅ Test the API endpoints
3. ✅ Understand the separation between read and write
4. ✅ Explore how to add a persistence layer
5. ✅ Learn about Event Sourcing as an extension

---

**Happy learning! 🚀**

For more information, see the main [README.md](../README.md)
