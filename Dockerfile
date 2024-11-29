# Stage 1: Build the Next.js application
FROM node:18 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Build the Next.js app for production
RUN npm run build

# Stage 2: Create the production environment with Nginx and PM2
FROM nginx:latest

# Install Node.js and PM2 for process management
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pm2

# Copy Nginx configuration to the container
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the built Next.js application to Nginx's default directory
COPY --from=builder /app/.next /usr/share/nginx/html
COPY --from=builder /app/public /usr/share/nginx/html

# Expose ports 80 (Nginx) and 3000 (Next.js app managed by PM2)
EXPOSE 80 3000

# Start both PM2 and Nginx in the background
CMD ["sh", "-c", "pm2 start npm --name 'nextjs-app' -- run start && pm2 startup && pm2 save && nginx -g 'daemon off;'"]
