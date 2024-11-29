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

# Stage 2: Create the production environment with Nginx
FROM nginx:latest

# Copy Nginx configuration to the container
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the built Next.js application to Nginx's default directory
COPY --from=builder /app/.next /usr/share/nginx/html
COPY --from=builder /app/public /usr/share/nginx/html

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
