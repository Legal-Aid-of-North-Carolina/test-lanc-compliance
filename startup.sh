#!/bin/bash

# Azure App Service startup script for Node.js applications
# This script runs when the container starts

# Create logs directory if it doesn't exist
mkdir -p /home/site/wwwroot/logs

# Set proper permissions for logs directory
chmod 755 /home/site/wwwroot/logs

# Install dependencies if node_modules doesn't exist
if [ ! -d "/home/site/wwwroot/node_modules" ]; then
    echo "Installing dependencies..."
    cd /home/site/wwwroot
    npm ci --only=production
fi

# Start the application
echo "Starting test-lanc-compliance service..."
cd /home/site/wwwroot
node server.js