# Stage 1: Build
FROM node:22-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Production/Development
FROM node:22-alpine AS runtime
WORKDIR /usr/src/app

# Argument to specify the environment (default: development)
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

# Copy built files and package.json
COPY --from=builder /usr/src/app/dist ./dist
COPY package*.json ./

# Install dependencies based on the environment
RUN if [ "$NODE_ENV" = "production" ]; then \
      npm install --only=production; \
    else \
      npm install; \
    fi

# Expose port 3000
EXPOSE 3000

# Command for production or development
CMD [ "sh", "-c", "if [ \"$NODE_ENV\" = \"development\" ]; then node --inspect=0.0.0.0:9229 dist/main; else node dist/main; fi" ]
