import { ServiceBusClient } from '@azure/service-bus';

/**
 * Publisher - Sends messages to Azure Service Bus Topic
 */
async function main() {
  const connectionString =
    process.env.SERVICE_BUS_CONNECTION_STRING ||
    'Endpoint=sb://your-namespace.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=your-key';

  const topicName = 'demo-topic';

  try {
    console.log(`
╔════════════════════════════════════════════╗
║  PUBLISHER - Azure Service Bus            ║
║  Topic: ${topicName.padEnd(25)} ║
╚════════════════════════════════════════════╝
    `);

    // Create client
    const client = new ServiceBusClient(connectionString);
    const sender = client.createSender(topicName);

    // Sample messages to send
    const messages = [
      {
        body: JSON.stringify({
          id: '1',
          event: 'UserCreated',
          name: 'Juan Pablo Parra',
          timestamp: new Date().toISOString(),
        }),
      },
      {
        body: JSON.stringify({
          id: '2',
          event: 'UserCreated',
          name: 'Stick Martinez',
          timestamp: new Date().toISOString(),
        }),
      },
      {
        body: JSON.stringify({
          id: '3',
          event: 'OrderPlaced',
          orderId: 'ORD-001',
          amount: 99.99,
          timestamp: new Date().toISOString(),
        }),
      },
    ];

    // Send messages
    console.log('\n📤 Sending messages to topic...\n');

    for (let i = 0; i < messages.length; i++) {
      await sender.sendMessages(messages[i]);
      const data = JSON.parse(messages[i].body);
      console.log(`✓ Message ${i + 1}/${messages.length} sent:`);
      console.log(`  Event: ${data.event}`);
      console.log(`  Timestamp: ${data.timestamp}\n`);
    }

    console.log('✅ All messages sent successfully!');
    console.log('\n💡 Subscribers should now receive these messages from their subscriptions.\n');

    // Close connection
    await sender.close();
    await client.close();
  } catch (error: any) {
    console.error('❌ Error:', error.message);
    if (error.message.includes('failed to negotiate')) {
      console.error(
        '\n⚠️  Connection failed. Check your SERVICE_BUS_CONNECTION_STRING environment variable.'
      );
      console.error('   Make sure:\n');
      console.error('   1. Service Bus Namespace exists in Azure');
      console.error('   2. Topic "demo-topic" is created');
      console.error('   3. Connection string is valid\n');
    }
    process.exit(1);
  }
}

main();
