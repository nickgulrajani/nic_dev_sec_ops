# Stage 1: Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies including dev dependencies
RUN npm install

# Copy source code
COPY . .

# Stage 2: Development stage
FROM node:18-alpine

# Set non-root user for security
USER node

# Create app directory and set permissions
WORKDIR /app

# Set environment variables
ENV PORT=4000 \
    NODE_ENV=development \
    NPM_CONFIG_LOGLEVEL=info \
    NODE_OPTIONS="--max-old-space-size=2048"

# Copy only necessary files from builder
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/src ./src
COPY --from=builder --chown=node:node /app/package*.json ./

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/health || exit 1

# Expose port
EXPOSE ${PORT}

# Set container labels
LABEL maintainer="Nick Gulrajani" \
      version="1.0" \
      description="DevOps Demo Application - Dev Environment" \
      project="azure-devops-demo" \
      environment="development"

# Start application
CMD ["node", "src/index.js"]