# Pub/Sub Module - Publisher-Subscriber Pattern with Azure Service Bus

## 📖 Overview

This module demonstrates the **Publisher-Subscriber (Pub/Sub) pattern** using **Azure Service Bus** - a fundamental messaging pattern for building decoupled, event-driven systems.

## 🎯 What is Publisher-Subscriber?

The Publisher-Subscriber pattern enables **asynchronous communication** between services:

- **Publisher**: Sends messages to a Topic
- **Topic**: Central hub that routes messages
- **Subscriptions**: Independent receivers registered with the Topic
- **Subscribers**: Services that listen to Subscriptions and process messages

```
Traditional Tight Coupling:
┌──────────────┐         ┌──────────────┐
│ Service A    │────────►│ Service B    │
│ (Slow)       │         │ (Slow)       │
└──────────────┘         └──────────────┘
     │
     │ Waits for response
     ▼
  Blocked

Pub/Sub Loose Coupling:
┌──────────────┐         ┌─────────────────────┐
│ Publisher    │────────►│  Topic              │
│              │         │  (Azure Service Bus)│
└──────────────┘         └─────────────────────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
            ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
            │Subscription │ │Subscription │ │Subscription │
            │    A        │ │    B        │ │    C        │
            └─────────────┘ └─────────────┘ └─────────────┘
                    │            │            │
                    ▼            ▼            ▼
            ┌──────────────┐┌──────────────┐┌──────────────┐
            │ Subscriber A ││ Subscriber B ││ Subscriber C │
            │  (Fast App)  ││  (Analytics) ││ (Logger)     │
            └──────────────┘└──────────────┘└──────────────┘
                    ✓ Independent processing
                    ✓ Async and non-blocking
                    ✓ Easy to extend (add more subscribers)
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Pub/Sub Module                         │
│               (Azure Service Bus Implementation)            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐                                          │
│  │ Publisher    │                                          │
│  │              │──────┐                                   │
│  │ • Sends      │      │                                   │
│  │   messages   │      │  ┌─────────────────────────────┐ │
│  └──────────────┘      │  │ Azure Service Bus Namespace │ │
│                        └─►│                             │ │
│                           │  Topic: demo-topic          │ │
│                           │                             │ │
│                           │  ┌─────────────────────┐    │ │
│                           │  │ Subscription A      │    │ │
│                           │  └─────────────────────┘    │ │
│                           │           ▲                  │ │
│  ┌──────────────┐         │           │                  │ │
│  │ Subscriber A │◄────────┤  ┌─────────────────────┐    │ │
│  │              │         │  │ Subscription B      │    │ │
│  │ • Receives   │         │  └─────────────────────┘    │ │
│  │   messages   │         │           ▲                  │ │
│  └──────────────┘         │           │                  │ │
│                           │           │                  │ │
│  ┌──────────────┐         └───────────┼──────────────────┘ │
│  │ Subscriber B │◄──────────────────────                   │
│  │              │                                         │
│  │ • Receives   │                                         │
│  │   messages   │                                         │
│  └──────────────┘                                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Key Points:
✓ Publisher sends once
✓ Topic broadcasts to all subscriptions
✓ Each subscription independently receives messages
✓ Subscribers process asynchronously
✓ Services remain decoupled
```

## 🚀 Quick Start

### Prerequisites

1. **Azure Subscription** (free tier available)
2. **Azure CLI** installed
3. **Azure Service Bus Namespace** created
4. **Connection String** configured

### Step 1: Create Azure Resources

```bash
# Set variables
RESOURCE_GROUP="cloud-patterns"
NAMESPACE_NAME="cloud-patterns-sb"
REGION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $REGION

# Create Service Bus namespace
az servicebus namespace create \
  --resource-group $RESOURCE_GROUP \
  --name $NAMESPACE_NAME \
  --location $REGION

# Create topic
az servicebus topic create \
  --resource-group $RESOURCE_GROUP \
  --namespace-name $NAMESPACE_NAME \
  --name demo-topic

# Create subscriptions
az servicebus topic subscription create \
  --resource-group $RESOURCE_GROUP \
  --namespace-name $NAMESPACE_NAME \
  --topic-name demo-topic \
  --name subscription-a

az servicebus topic subscription create \
  --resource-group $RESOURCE_GROUP \
  --namespace-name $NAMESPACE_NAME \
  --topic-name demo-topic \
  --name subscription-b

# Get connection string
az servicebus namespace authorization-rule keys list \
  --resource-group $RESOURCE_GROUP \
  --namespace-name $NAMESPACE_NAME \
  --name RootManageSharedAccessKey \
  --query primaryConnectionString \
  --output tsv
```

### Step 2: Set Environment Variable

```bash
# Define variable
export SERVICE_BUS_CONNECTION_STRING="<paste-your-connection-string>"

# Verify it's set
echo $SERVICE_BUS_CONNECTION_STRING
```

### Step 3: Install Dependencies

```bash
# Publisher
cd pubsub/publisher && npm install && cd ../..

# Subscriber A
cd pubsub/subscriber-a && npm install && cd ../..

# Subscriber B
cd pubsub/subscriber-b && npm install && cd ../..
```

### Step 4: Run Services

**Terminal 1 - Subscriber A (Receiver)**
```bash
cd pubsub/subscriber-a
npm run dev
```

**Terminal 2 - Subscriber B (Receiver)**
```bash
cd pubsub/subscriber-b
npm run dev
```

**Terminal 3 - Publisher (Sender)**
```bash
cd pubsub/publisher
npm run dev
```

## 📡 Message Flow

### Complete Workflow

```
Timeline:

T=0ms   Subscriber A starts
        → Connects to subscription-a
        → Ready to receive messages

T=50ms  Subscriber B starts
        → Connects to subscription-b
        → Ready to receive messages

T=100ms Publisher starts
        → Loads messages
        → Sends Message 1 to Topic
        → Sends Message 2 to Topic
        → Sends Message 3 to Topic
        → Closes connection

T=120ms ServiceBus automatically routes to subscriptions
        → Subscription A receives copies
        → Subscription B receives copies

T=150ms Subscriber A processes messages
        Message 1: UserCreated - Alice
        Message 2: UserCreated - Bob
        Message 3: OrderPlaced - ORD-001

T=160ms Subscriber B processes messages
        Message 1: UserCreated - Alice
        Message 2: UserCreated - Bob
        Message 3: OrderPlaced - ORD-001

Both subscribers received ALL messages
Each processed independently
Perfect decoupling achieved!
```

## 🔄 Code Examples

### Publisher Implementation

```typescript
const client = new ServiceBusClient(connectionString);
const sender = client.createSender('demo-topic');

const message = {
  body: JSON.stringify({
    id: '1',
    event: 'UserCreated',
    name: 'Alice Johnson',
    timestamp: new Date().toISOString()
  })
};

await sender.sendMessages(message);
```

### Subscriber Implementation

```typescript
const client = new ServiceBusClient(connectionString);
const receiver = client.createReceiver('demo-topic', 'subscription-a');

receiver.subscribe({
  processMessage: async (message) => {
    const data = JSON.parse(message.body);
    console.log('Received:', data.event);
    await receiver.completeMessage(message);
  },
  processError: async (error) => {
    console.error('Error:', error);
  }
});
```

## 🎓 Key Concepts

### 1. Topic
- Central message hub
- Publisher sends to Topic
- Multi-destination routing
- No knowledge of subscribers needed

### 2. Subscription
- Independent receiver endpoint
- One per subscriber
- Gets copy of all Topic messages
- Maintains own message queue

### 3. Message Delivery

```
Scenario: Topic has 3 messages, 2 subscriptions

Topic: demo-topic
├─ Message 1 (UserCreated)
├─ Message 2 (OrderPlaced)
└─ Message 3 (UserDeleted)

subscription-a                    subscription-b
├─ Message 1 (copy)              ├─ Message 1 (copy)
├─ Message 2 (copy)              ├─ Message 2 (copy)
└─ Message 3 (copy)              └─ Message 3 (copy)

Each subscription independently:
✓ Receives all messages
✓ Processes at their own pace
✓ Can acknowledge/reject independently
```

### 4. Message Properties

```json
{
  "body": "Message content (serialized as JSON)",
  "contentType": "application/json",
  "sequenceNumber": 1,
  "deliveryCount": 1,
  "enqueuedTimeUtc": "2024-03-14T10:30:00Z",
  "lockToken": "unique-lock-identifier"
}
```

## 🏃 Complete Workflow Example

### Setup (Terminal 0)
```bash
export SERVICE_BUS_CONNECTION_STRING="Endpoint=sb://cloud-patterns-sb.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=..."
```

### Terminal 1 - Start Subscriber A
```bash
$ cd pubsub/subscriber-a && npm run dev

╔════════════════════════════════════════════╗
║  SUBSCRIBER A - Azure Service Bus          ║
║  Topic: demo-topic                         ║
║  Subscription: subscription-a              ║
╚════════════════════════════════════════════╝

⏳ Listening for messages on Subscription: subscription-a

✅ Subscriber A is active and listening...
```

### Terminal 2 - Start Subscriber B
```bash
$ cd pubsub/subscriber-b && npm run dev

╔════════════════════════════════════════════╗
║  SUBSCRIBER B - Azure Service Bus          ║
║  Topic: demo-topic                         ║
║  Subscription: subscription-b              ║
╚════════════════════════════════════════════╝

⏳ Listening for messages on Subscription: subscription-b

✅ Subscriber B is active and listening...
```

### Terminal 3 - Publish Messages
```bash
$ cd pubsub/publisher && npm run dev

╔════════════════════════════════════════════╗
║  PUBLISHER - Azure Service Bus             ║
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
```

### Terminal 1 - Subscriber A Receives
```bash
📨 Message received by Subscriber A:
   Event: UserCreated
   Data: {
     "id": "1",
     "event": "UserCreated",
     "name": "Alice Johnson",
     "timestamp": "2024-03-14T10:30:00.000Z"
   }
   Received at: 2024-03-14T10:30:02.150Z

📨 Message received by Subscriber A:
   Event: UserCreated
   ...
```

### Terminal 2 - Subscriber B Receives
```bash
📨 Message received by Subscriber B:
   Event: UserCreated
   Data: {
     "id": "1",
     "event": "UserCreated",
     "name": "Alice Johnson",
     "timestamp": "2024-03-14T10:30:00.000Z"
   }
   Received at: 2024-03-14T10:30:02.200Z
```

**Result**: Both subscribers independently received and processed all messages! ✅

## 💡 Benefits of Pub/Sub

### 1. Decoupling
```
Before (Tight Coupling):
ServiceA ──► ServiceB (knows about B)
     │          ▲
     └──────────┘ (direct dependency)

After (Pub/Sub):
ServiceA ──► Topic ◄── ServiceB (independent)
     │           │
     └─────┘     └────── ServiceC (independent)
              Any number of subscribers
```

### 2. Scalability
- Add subscribers without changing publisher
- Scale each service independently
- Handle traffic spikes asynchronously

### 3. Resilience
- Publisher doesn't wait for subscribers
- Failed subscriber doesn't block others
- Messages persisted in Topic/Subscriptions

### 4. Flexibility
- Easy to add new subscribers
- Different subscribers can process differently
- Retroactive consumer patterns

## 🔌 Azure Service Bus Concepts

### Topic vs Queue

```
Queue: One publisher ──► One subscriber
       First In, First Out
       Good for: Direct messaging

Topic: One publisher ──► Many subscribers
       Broadcasting
       Good for: Event-driven, one-to-many
```

### Subscription Filters (Advanced)

```typescript
// Filter messages by criteria
const filter = {
  sqlExpression: "event = 'UserCreated'"
};

// Only receives UserCreated events
```

### Dead Letter Queue

```typescript
// Messages that can't be processed
// Default location: <subscription-name>/$DeadLetterQueue
```

## 🐛 Troubleshooting

### Connection String Issues

**Problem:**
```
Connection failed. Check your SERVICE_BUS_CONNECTION_STRING
```

**Solution:**
```bash
# Verify connection string is set
echo $SERVICE_BUS_CONNECTION_STRING

# Should output: Endpoint=sb://...;SharedAccessKey=...

# If not set, manually set it
export SERVICE_BUS_CONNECTION_STRING="your-connection-string"
```

### Topic or Subscription Not Found

**Problem:**
```
The entity 'demo-topic' could not be found
```

**Solution:**
```bash
# Verify topic exists
az servicebus topic list \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb

# Create if missing
az servicebus topic create \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb \
  --name demo-topic

# Verify subscriptions exist
az servicebus topic subscription list \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb \
  --topic-name demo-topic
```

### Subscribers Not Receiving Messages

**Problem:**
```
No messages received by subscribers
```

**Solutions:**
1. Ensure subscribers are running BEFORE publishing
2. Verify connection string is correct
3. Check that subscriptions are created
4. Verify Azure authentication

```bash
# Test connection string
az servicebus topic list \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb
```

### Network/Firewall Issues

**Problem:**
```
Unable to connect to Service Bus
```

**Solution:**
```bash
# Check if firewall allows Service Bus
# Or use Azure Cloud Shell for testing
az cloud shell
```

## 📚 File Structure

```
pubsub/
├── publisher/
│   ├── src/
│   │   └── index.ts           # Publisher implementation
│   ├── package.json           # Dependencies and scripts
│   └── tsconfig.json          # TypeScript configuration
│
├── subscriber-a/
│   ├── src/
│   │   └── index.ts           # Subscriber A implementation
│   ├── package.json           # Dependencies and scripts
│   └── tsconfig.json          # TypeScript configuration
│
└── subscriber-b/
    ├── src/
    │   └── index.ts           # Subscriber B implementation
    ├── package.json           # Dependencies and scripts
    └── tsconfig.json          # TypeScript configuration
```

## 🎯 When to Use Publisher-Subscriber

### ✅ Good Use Cases
- Event-driven architectures
- Multiple services need same event
- Decoupling services
- Asynchronous processing
- Broadcasting notifications
- Logging/Analytics pipelines

### ❌ Not Ideal For
- Request-response patterns (use Queues instead)
- When ordering is strictly required
- Simple point-to-point messaging
- Single recipient scenarios (use Queues)

## 🔗 Advanced Patterns

### 1. Event Fan-Out
```
OrderPlaced Event
      ▼
   Topic
      │
   ┌──┼──┬──┐
   ▼  ▼  ▼  ▼
  Payment Inventory Notification Analytics
  Service  Service   Service      Service
```

### 2. Event Sourcing with Pub/Sub
```
Command ──► Store Event ──► Publish Event ──► Subscribers
(write)      (persist)      (distribute)      (process)
```

### 3. Dead Letter Handling
```
Subscriber tries to process
        ▼
    Failed 3x
        ▼
   Move to DLQ
        ▼
  Manual review
        ▼
   Reprocess or discard
```

## 📖 Learning Resources

- **Azure Service Bus Docs**: https://docs.microsoft.com/azure/service-bus-messaging/
- **Pub/Sub Pattern**: https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern
- **Event-Driven Architecture**: https://microservices.io/patterns/data/event-driven-architecture.html
- **Message Queuing**: https://www.rabbitmq.com/tutorials/amqp-concepts.html

---

## 🎯 Next Steps

1. ✅ Create Azure Service Bus resources
2. ✅ Run subscribers and publisher
3. ✅ Verify message delivery to both subscriptions
4. ✅ Explore dead letter queues
5. ✅ Add filters to subscriptions
6. ✅ Implement retry logic

---

**Happy learning! 🚀**

For more information, see the main [README.md](../README.md)
