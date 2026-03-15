import { ServiceBusClient } from '@azure/service-bus';

/**
 * Subscriber B - Receives messages from Azure Service Bus Topic Subscription
 */
async function main() {
  const connectionString =
    process.env.SERVICE_BUS_CONNECTION_STRING ||
    'Endpoint=sb://your-namespace.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=your-key';

  const topicName = 'demo-topic';
  const subscriptionName = 'subscription-b';

  try {
    console.log(`
╔════════════════════════════════════════════╗
║  SUBSCRIBER B - Azure Service Bus          ║
║  Topic: ${topicName.padEnd(28)} ║
║  Subscription: ${subscriptionName.padEnd(21)} ║
╚════════════════════════════════════════════╝
    `);

    // Create client
    const client = new ServiceBusClient(connectionString);
    const receiver = client.createReceiver(topicName, subscriptionName);

    console.log(`\n⏳ Listening for messages on Subscription: ${subscriptionName}\n`);

    // Message handler
    const messageHandler = async (message: any) => {
      try {
        const data = JSON.parse(message.body);
        console.log(`📨 Message received by Subscriber B:`);
        console.log(`   Event: ${data.event}`);
        console.log(`   Data: ${JSON.stringify(data, null, 4)}`);
        console.log(`   Received at: ${new Date().toISOString()}\n`);

        // Complete the message
        await receiver.completeMessage(message);
      } catch (error) {
        console.error('Error processing message:', error);
        await receiver.abandonMessage(message);
      }
    };

    // Error handler
    const errorHandler = async (error: any) => {
      console.error('❌ Error in message receiver:', error);
    };

    // Subscribe to messages
    receiver.subscribe(
      {
        processMessage: messageHandler,
        processError: errorHandler,
      },
      {
        autoCompleteMessages: false,
        maxConcurrentCalls: 1,
      }
    );

    // Keep running
    console.log('✅ Subscriber B is active and listening...');
    console.log('Press Ctrl+C to exit.\n');

    // Handle graceful shutdown
    process.on('SIGINT', async () => {
      console.log('\n\n🛑 Shutting down Subscriber B...');
      await receiver.close();
      await client.close();
      process.exit(0);
    });
  } catch (error: any) {
    console.error('❌ Error:', error.message);
    if (error.message.includes('failed to negotiate')) {
      console.error(
        '\n⚠️  Connection failed. Check your SERVICE_BUS_CONNECTION_STRING environment variable.'
      );
      console.error('   Make sure:\n');
      console.error('   1. Service Bus Namespace exists in Azure');
      console.error(`   2. Topic "${topicName}" is created`);
      console.error(`   3. Subscription "${subscriptionName}" is created`);
      console.error('   4. Connection string is valid\n');
    }
    process.exit(1);
  }
}

main();
