#!/bin/bash

# Exit immediately if a command fails
set -e

# Define the application directory
APP_DIR="/home/ec2-user/shilpagya"

# Navigate to the application directory
echo "Navigating to $APP_DIR..."
if [ ! -d "$APP_DIR" ]; then
    echo "Directory $APP_DIR does not exist. Exiting."
    exit 1
fi
cd $APP_DIR

# Check and install Node.js and npm if they are not installed
echo "Checking if Node.js and npm are installed..."
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    echo "Node.js and npm are not installed. Installing Node.js and npm..."
    curl -sL https://rpm.nodesource.com/setup_16.x | sudo -E bash -
    sudo yum install -y nodejs
    echo "Node.js and npm installed successfully."
fi

# Ensure PM2 is installed globally
echo "Checking if PM2 is installed..."
if ! command -v pm2 &> /dev/null; then
    echo "PM2 is not installed. Installing PM2 globally..."
    npm install -g pm2 --unsafe-perm
fi

# Stop any existing PM2 instances to avoid duplicates
echo "Stopping any existing PM2 instances of 'shilpagya'..."
pm2 stop "shilpagya" || true
pm2 delete "shilpagya" || true

# Install project dependencies using npm ci for a clean, reproducible install
echo "Installing project dependencies..."
npm ci

# Build the Next.js application
echo "Building the application..."
npm run build

# Start the application with PM2
echo "Starting the application with PM2..."
pm2 start "npx next start" --name "shilpagya"

# Save the PM2 process list and set up PM2 to start on reboot
echo "Saving PM2 process list and setting up startup script..."
pm2 save
pm2 startup systemd -u ec2-user --hp /home/ec2-user | sudo tee /dev/null

echo "Deployment script completed successfully."
