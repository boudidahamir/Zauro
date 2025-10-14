# Docker Setup for Hedera NFT System

## 🐳 Quick Start with Docker

### Prerequisites
- Docker (v20.10+)
- Docker Compose (v2.0+)
- Hedera testnet credentials

### 1. Environment Setup
```bash
# Copy environment template
cp env.example .env

# Edit .env with your Hedera credentials
# Replace placeholder values with your actual testnet credentials
```

### 2. Build and Run
```bash
# Option A: Using Docker Compose (Recommended)
npm run docker:up

# Option B: Manual Docker commands
npm run docker:build
npm run docker:run
```

### 3. Verify Deployment
```bash
# Check container status
docker-compose ps

# View logs
npm run docker:logs

# Test API
curl http://localhost:3000/collection-status
```

## 🔧 Docker Commands

### Using npm scripts (Recommended)
```bash
npm run docker:build    # Build Docker image
npm run docker:run      # Run container manually
npm run docker:up       # Start with docker-compose
npm run docker:down     # Stop containers
npm run docker:logs     # View logs
npm run docker:restart  # Restart containers
npm run docker:clean    # Clean up everything
```

### Direct Docker Commands
```bash
# Build image
docker build -t hedera-nft-app .

# Run container
docker run -p 3000:3000 --env-file .env hedera-nft-app

# Using docker-compose
docker-compose up -d
docker-compose down
docker-compose logs -f
```

## 📁 Docker Architecture

### Services
- **hedera-nft-app**: Main application container
- **nginx**: Reverse proxy (optional)

### Volumes
- **./data**: Persistent collection data
- **./logs**: Application logs

### Networks
- **hedera-network**: Internal Docker network

## 🔒 Security Features

### Container Security
- ✅ Non-root user execution
- ✅ Minimal Alpine Linux base
- ✅ Health checks
- ✅ Resource limits
- ✅ Read-only filesystem where possible

### Network Security
- ✅ Internal Docker network
- ✅ Reverse proxy with nginx
- ✅ Environment variable isolation

## 📊 Monitoring & Health Checks

### Health Check Endpoint
```bash
# Container health check
docker inspect hedera-nft-backend | grep Health -A 10

# Application health check
curl http://localhost:3000/collection-status
```

### Logs
```bash
# View application logs
docker-compose logs -f hedera-nft-app

# View nginx logs
docker-compose logs -f nginx

# View all logs
docker-compose logs -f
```

## 🚀 Production Deployment

### Environment Variables
```env
NODE_ENV=production
PORT=3000
HEDERA_OPERATOR_ID=your_account_id
HEDERA_OPERATOR_KEY=your_private_key
```

### Production Docker Compose
```yaml
# Add to docker-compose.yml for production
services:
  hedera-nft-app:
    environment:
      - NODE_ENV=production
    restart: always
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```

### SSL/HTTPS Setup
```bash
# Add SSL certificates to nginx
# Update nginx.conf with SSL configuration
# Use Let's Encrypt or your SSL provider
```

## 🔄 Data Persistence

### Collection Data
- Stored in `./data/collection.json`
- Persists across container restarts
- Backed up automatically

### Logs
- Stored in `./logs/`
- Rotated automatically
- Accessible via volume mounts

## 🛠️ Troubleshooting

### Common Issues

1. **Container won't start**
   ```bash
   # Check logs
   docker-compose logs hedera-nft-app
   
   # Check environment variables
   docker-compose config
   ```

2. **Port conflicts**
   ```bash
   # Change port in docker-compose.yml
   ports:
     - "3001:3000"  # Use different host port
   ```

3. **Permission issues**
   ```bash
   # Fix data directory permissions
   sudo chown -R $USER:$USER ./data
   ```

4. **Environment variables not loading**
   ```bash
   # Verify .env file exists and has correct format
   cat .env
   
   # Test environment loading
   docker-compose config
   ```

### Debugging
```bash
# Enter container shell
docker exec -it hedera-nft-backend sh

# Check environment variables
docker exec hedera-nft-backend env

# Check file permissions
docker exec hedera-nft-backend ls -la /app/data
```

## 📈 Scaling

### Horizontal Scaling
```yaml
# Scale application instances
docker-compose up -d --scale hedera-nft-app=3
```

### Load Balancing
- nginx automatically load balances
- Multiple app instances supported
- Session affinity not required (stateless)

## 🔄 Updates & Maintenance

### Update Application
```bash
# Pull latest changes
git pull

# Rebuild and restart
npm run docker:down
npm run docker:up
```

### Backup Data
```bash
# Backup collection data
cp ./data/collection.json ./backup/collection-$(date +%Y%m%d).json

# Backup logs
tar -czf ./backup/logs-$(date +%Y%m%d).tar.gz ./logs/
```

### Clean Up
```bash
# Remove unused containers and images
npm run docker:clean

# Remove specific images
docker rmi hedera-nft-app
```

## 🌐 Network Configuration

### Default Ports
- **3000**: Application (internal)
- **80**: nginx (external)
- **443**: nginx SSL (external)

### Custom Ports
```yaml
# In docker-compose.yml
ports:
  - "8080:3000"  # Custom application port
  - "8443:443"   # Custom SSL port
```

## 📋 Docker Compose Override

### Development Override
```yaml
# docker-compose.override.yml
version: '3.8'
services:
  hedera-nft-app:
    environment:
      - NODE_ENV=development
    volumes:
      - .:/app  # Mount source code for development
```

### Production Override
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  hedera-nft-app:
    environment:
      - NODE_ENV=production
    restart: always
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
```

## 🎯 Best Practices

1. **Always use .env files** for sensitive data
2. **Mount volumes** for persistent data
3. **Use health checks** for monitoring
4. **Run as non-root** user in containers
5. **Keep images minimal** with Alpine Linux
6. **Use multi-stage builds** for optimization
7. **Implement proper logging** and monitoring
8. **Backup data regularly**
9. **Use Docker secrets** for production
10. **Monitor resource usage**

## 🔗 Integration

### With Frontend Applications
```bash
# Add to your frontend docker-compose.yml
services:
  frontend:
    depends_on:
      - hedera-nft-backend
    environment:
      - REACT_APP_API_URL=http://hedera-nft-backend:3000
```

### With Databases
```yaml
# Add database service
services:
  postgres:
    image: postgres:13
    environment:
      - POSTGRES_DB=hedera_nft
      - POSTGRES_USER=hedera
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

This Docker setup provides a production-ready, scalable, and secure deployment of your Hedera NFT system!
