#!/bin/bash

# Navigate to the application directory
echo "Navigating to /home/ec2-user/shilpagya..."
if [ ! -d "/home/ec2-user/shilpagya" ]; then
    echo "Directory /home/ec2-user/shilpagya does not exist. Exiting."
    exit 1
fi
cd /home/ec2-user/shilpagya || exit 1

# Ensure npm is available
echo "Checking if npm is installed..."
if ! command -v npm &> /dev/null; then
    echo "npm is not installed. Please install Node.js and npm."
    exit 1
fi

# Ensure PM2 is available and install it if missing
echo "Checking if PM2 is installed..."
if ! command -v pm2 &> /dev/null; then
    echo "PM2 is not installed. Installing PM2 globally..."
    npm install -g pm2 --unsafe-perm
fi

# Stop and delete any existing PM2 instances of 'shilpagya' to prevent duplicates
echo "Stopping and deleting existing PM2 instance for 'shilpagya'..."
pm2 stop "shilpagya" || true
pm2 delete "shilpagya" || true

# Stop and delete any existing PM2 instances of 'new' (if necessary)
echo "Stopping and deleting existing PM2 instance for 'new'..."
pm2 stop "new" || true
pm2 delete "new" || true

# Start the application using PM2
echo "Starting the application with PM2..."
pm2 start "npm start" --name "shilpagya"

# Save the PM2 process list and configure it to restart on reboot
echo "Saving PM2 process list and setting up startup script..."
pm2 save
pm2 startup systemd -u ec2-user --hp /home/ec2-user

echo "Deployment script completed successfully."
