#!/bin/bash

# Setup script for Cloud Patterns Demo
# This script installs dependencies for all services

echo "╔════════════════════════════════════════════╗"
echo "║  Cloud Patterns Demo - Setup Script        ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 16+ first."
    echo "   Visit: https://nodejs.org"
    exit 1
fi

echo "✓ Node.js $(node --version) found"
echo "✓ npm $(npm --version) found"
echo ""

# Install dependencies for CQRS module
echo "📦 Installing CQRS module dependencies..."
echo ""

echo "  → Command Service..."
cd cqrs/command-service
npm install --silent
if [ $? -eq 0 ]; then
    echo "    ✓ Command Service dependencies installed"
else
    echo "    ❌ Failed to install Command Service dependencies"
    exit 1
fi
cd ../..

echo "  → Query Service..."
cd cqrs/query-service
npm install --silent
if [ $? -eq 0 ]; then
    echo "    ✓ Query Service dependencies installed"
else
    echo "    ❌ Failed to install Query Service dependencies"
    exit 1
fi
cd ../..

echo ""

# Install dependencies for Pub/Sub module
echo "📦 Installing Pub/Sub module dependencies..."
echo ""

echo "  → Publisher..."
cd pubsub/publisher
npm install --silent
if [ $? -eq 0 ]; then
    echo "    ✓ Publisher dependencies installed"
else
    echo "    ❌ Failed to install Publisher dependencies"
    exit 1
fi
cd ../..

echo "  → Subscriber A..."
cd pubsub/subscriber-a
npm install --silent
if [ $? -eq 0 ]; then
    echo "    ✓ Subscriber A dependencies installed"
else
    echo "    ❌ Failed to install Subscriber A dependencies"
    exit 1
fi
cd ../..

echo "  → Subscriber B..."
cd pubsub/subscriber-b
npm install --silent
if [ $? -eq 0 ]; then
    echo "    ✓ Subscriber B dependencies installed"
else
    echo "    ❌ Failed to install Subscriber B dependencies"
    exit 1
fi
cd ../..

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  ✅ Setup Complete!                        ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "📚 Next steps:"
echo ""
echo "  1. CQRS Module (Local only):"
echo "     Terminal 1: cd cqrs/command-service && npm run dev"
echo "     Terminal 2: cd cqrs/query-service && npm run dev"
echo ""
echo "  2. Pub/Sub Module (Requires Azure Service Bus):"
echo "     - Set SERVICE_BUS_CONNECTION_STRING environment variable"
echo "     - Terminal 1: cd pubsub/subscriber-a && npm run dev"
echo "     - Terminal 2: cd pubsub/subscriber-b && npm run dev"
echo "     - Terminal 3: cd pubsub/publisher && npm run dev"
echo ""
echo "📖 For more details, see README.md"
echo ""
