# Hedera NFT System Setup Guide

## 🚀 Quick Start

### 1. Prerequisites
- Node.js (v14 or higher)
- npm or yarn
- Hedera testnet account

### 2. Install Dependencies
```bash
cd Hedera
npm install
```

### 3. Get Hedera Testnet Credentials
1. Go to [Hedera Portal](https://portal.hedera.com/)
2. Create a new account or use existing one
3. Copy your **Account ID** and **Private Key**

### 4. Configure Environment
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your credentials
# Replace the placeholder values with your actual Hedera testnet credentials
```

### 5. Start the Server
```bash
npm start
```

## 📋 Environment Variables

Create a `.env` file with:
```env
HEDERA_OPERATOR_ID=0.0.1234567
HEDERA_OPERATOR_KEY=302e020100300506032b657004220420abc123...
PORT=3000
```

## 🔧 API Endpoints

Once running, the server provides:

- `POST /create-wallet` - Create new wallet
- `POST /create-collection` - Create collection (optional, auto-created)
- `POST /mint-nft` - Mint NFT (auto-creates collections)
- `POST /transfer-nft` - Transfer NFT between accounts
- `GET /collection-status` - Get current collection status
- `GET /collection-nfts` - Get all NFTs in current collection
- `GET /nfts/:accountId` - Get NFTs owned by account
- `GET /nfts` - Get all NFTs minted by operator

## 🧪 Testing the System

### Test with PowerShell (Windows)
```powershell
# 1. Create a wallet
Invoke-RestMethod -Uri "http://localhost:3000/create-wallet" -Method Post

# 2. Check collection status
Invoke-RestMethod -Uri "http://localhost:3000/collection-status" -Method Get

# 3. Mint an NFT (replace with your wallet credentials)
$metadata = @{
  age = "5Y"
  price = 3000
  health = "healthy"
  sex = "male"
  image = "https://example.com/cow.jpg"
} | ConvertTo-Json -Depth 5

$body = @{
  ownerAccountId = "0.0.1234567"
  ownerPrivateKey = "302e020100300506032b657004220420abc..."
  metadata = $metadata
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri "http://localhost:3000/mint-nft" -Method Post -Body $body -ContentType "application/json"
```

### Test with curl (Linux/Mac)
```bash
# 1. Create a wallet
curl -X POST http://localhost:3000/create-wallet

# 2. Check collection status
curl http://localhost:3000/collection-status

# 3. Mint an NFT
curl -X POST http://localhost:3000/mint-nft \
  -H "Content-Type: application/json" \
  -d '{
    "ownerAccountId": "0.0.1234567",
    "ownerPrivateKey": "302e020100300506032b657004220420abc...",
    "metadata": {
      "age": "5Y",
      "price": 3000,
      "health": "healthy",
      "sex": "male",
      "image": "https://example.com/cow.jpg"
    }
  }'
```

## 🔍 Features

### Automatic Collection Management
- ✅ Collections auto-created on server start
- ✅ Automatic switching when collections reach capacity
- ✅ Real-time capacity monitoring
- ✅ Sequential collection numbering

### NFT Management
- ✅ Mint NFTs with custom metadata
- ✅ Transfer NFTs between accounts
- ✅ Query NFTs by collection or owner
- ✅ Base64 metadata encoding/decoding

### Security
- ✅ Private key management
- ✅ Account association handling
- ✅ Error handling and recovery

## 🚨 Troubleshooting

### Common Issues

1. **"Invalid operator credentials"**
   - Check your `.env` file has correct Hedera credentials
   - Ensure you're using testnet credentials

2. **"Collection not found"**
   - Server will auto-create collections on startup
   - Check server logs for initialization messages

3. **"Account not associated with token"**
   - System handles this automatically
   - If persistent, check account has sufficient HBAR

4. **Port already in use**
   - Change PORT in `.env` file
   - Or kill existing process: `netstat -ano | findstr :3000`

### Getting Help
- Check server console logs for detailed error messages
- Verify Hedera testnet status at [status.hedera.com](https://status.hedera.com)
- Ensure sufficient HBAR balance for transactions

## 📚 Next Steps

1. **Integrate with Frontend**: Connect to your livestock web app
2. **Add Authentication**: Implement user authentication
3. **Database Integration**: Store additional metadata
4. **Production Setup**: Configure for mainnet deployment
5. **Monitoring**: Add logging and monitoring tools

## 🔗 Useful Links

- [Hedera Documentation](https://docs.hedera.com/)
- [Hedera Portal](https://portal.hedera.com/)
- [Hedera SDK](https://github.com/hashgraph/hedera-sdk-js)
- [Hedera Mirror Node API](https://docs.hedera.com/hedera/mirror-node-api)
