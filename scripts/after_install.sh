#!/bin/bash

# Navigate to the application directory
cd /home/ec2-user/shilpagya|| exit 1

# Ensure npm is available
if ! command -v npm &> /dev/null; then
    echo "npm is not installed. Please install Node.js and npm."
    exit 1
fi

# Ensure PM2 is available and install it if missing
if ! command -v pm2 &> /dev/null; then
    echo "PM2 is not installed. Installing PM2 globally..."
    npm install -g pm2
fi

# Stop any existing instances to avoid duplicates
echo "Stopping any existing PM2 instances..."
pm2 stop "shilpagya"|| true
pm2 delete "shilpagya" || true

# Install project dependencies
echo "Installing project dependencies..."
npm install

# Build the Next.js application
echo "Building the application..."
npm run build

# Start the application using PM2
echo "Starting the application with PM2..."
pm2 start "npx next start" --name "shilpagya"

# Save the PM2 process list and configure it to restart on reboot
echo "Saving PM2 process list and setting up startup script..."
pm2 save
pm2 startup systemd -u ec2-user --hp /home/ec2-user

echo "Deployment script completed successfully."
