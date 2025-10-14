# Quick Docker Start Guide

## 🚀 One-Command Setup

```bash
# 1. Configure environment
cp env.example .env
# Edit .env with your Hedera credentials

# 2. Start everything
npm run docker:up
```

## 📋 What's Included

### Docker Files
- `Dockerfile` - Multi-stage build with Alpine Linux
- `docker-compose.yml` - Complete orchestration
- `.dockerignore` - Optimized build context
- `nginx.conf` - Reverse proxy configuration

### Features
- ✅ **Security**: Non-root user, minimal base image
- ✅ **Persistence**: Data volumes for collection storage
- ✅ **Health Checks**: Automatic monitoring
- ✅ **Load Balancing**: nginx reverse proxy
- ✅ **Logging**: Centralized log management
- ✅ **Scaling**: Horizontal scaling support

### npm Scripts
```bash
npm run docker:build    # Build image
npm run docker:up       # Start with compose
npm run docker:down     # Stop containers
npm run docker:logs     # View logs
npm run docker:restart  # Restart services
npm run docker:clean    # Clean up everything
```

## 🌐 Access Points
- **Direct**: http://localhost:3000
- **Proxy**: http://localhost (nginx)
- **Health**: http://localhost/health

## 🧪 Testing
```bash
# Run automated test
./test-docker.sh

# Manual testing
curl http://localhost:3000/collection-status
```

## 📊 Monitoring
```bash
# View logs
npm run docker:logs

# Check status
docker-compose ps

# Health check
docker inspect hedera-nft-backend | grep Health
```

## 🔧 Production Ready
- Environment-based configuration
- Resource limits and health checks
- Persistent data storage
- Security best practices
- Comprehensive logging
- Easy scaling and updates

Your Hedera NFT system is now fully containerized and production-ready! 🎉
