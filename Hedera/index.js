require('dotenv').config();
const express = require('express');
const { Client, AccountId, PrivateKey, AccountCreateTransaction, Hbar, TokenCreateTransaction, TokenType, TokenSupplyType, TokenMintTransaction, TokenAssociateTransaction, TransferTransaction } = require('@hashgraph/sdk');
const axios = require('axios');
const fs = require('fs').promises;

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const operatorId = AccountId.fromString(process.env.HEDERA_OPERATOR_ID);
const operatorKey = PrivateKey.fromString(process.env.HEDERA_OPERATOR_KEY);

// Hedera client for testnet
const client = Client.forTestnet().setOperator(operatorId, operatorKey);

// In-memory user wallet store (for demo)
const userWallets = {};

// Helper to decode base64 metadata
function decodeBase64Json(base64str) {
  try {
    const jsonStr = Buffer.from(base64str, 'base64').toString('utf8');
    return JSON.parse(jsonStr);
  } catch (e) {
    return null;
  }
}

// Helper to read collection info
async function getCollectionInfo() {
    try {
        const data = await fs.readFile('data/collection.json', 'utf8');
        return JSON.parse(data);
    } catch (err) {
        // Fallback to root directory for backward compatibility
        try {
            const data = await fs.readFile('collection.json', 'utf8');
            return JSON.parse(data);
        } catch (fallbackErr) {
            return null;
        }
    }
}

// Helper to save collection info
async function saveCollectionInfo(info) {
    // Ensure data directory exists
    try {
        await fs.mkdir('data', { recursive: true });
    } catch (err) {
        // Directory might already exist
    }
    
    await fs.writeFile('data/collection.json', JSON.stringify(info, null, 2));
}

// Helper to get current NFT count for a collection
async function getCurrentNFTCount(tokenId) {
    try {
        const url = `https://testnet.mirrornode.hedera.com/api/v1/tokens/${tokenId}/nfts`;
        const { data } = await axios.get(url);
        return data.nfts ? data.nfts.length : 0;
    } catch (err) {
        console.error("Error getting NFT count:", err);
        return 0;
    }
}

// Helper to create a new collection
async function createNewCollection(collectionNumber = 1) {
    try {
        const supplyKey = PrivateKey.generateED25519();
        const collectionName = `DemoNFT-${collectionNumber}`;
        const collectionSymbol = `DNFT${collectionNumber}`;
        
        const nftCreateTx = await new TokenCreateTransaction()
            .setTokenName(collectionName)
            .setTokenSymbol(collectionSymbol)
            .setTokenType(TokenType.NonFungibleUnique)
            .setDecimals(0)
            .setInitialSupply(0)
            .setTreasuryAccountId(operatorId)
            .setSupplyType(TokenSupplyType.Finite)
            .setMaxSupply(1000000) // Max supply per collection
            .setSupplyKey(supplyKey)
            .freezeWith(client);
        
        const nftCreateSign = await nftCreateTx.sign(operatorKey);
        const nftCreateSubmit = await nftCreateSign.execute(client);
        const nftCreateRx = await nftCreateSubmit.getReceipt(client);
        const tokenId = nftCreateRx.tokenId;

        const collectionInfo = {
            tokenId: tokenId.toString(),
            supplyKey: supplyKey.toStringRaw(),
            name: collectionName,
            symbol: collectionSymbol,
            collectionNumber: collectionNumber,
            createdAt: new Date().toISOString(),
            nftCount: 0
        };
        
        await saveCollectionInfo(collectionInfo);
        console.log(`✅ Created new collection: ${collectionName} (${tokenId})`);
        return collectionInfo;
    } catch (err) {
        console.error("Error creating new collection:", err);
        throw err;
    }
}

// Initialize collections on server start
async function initializeCollections() {
    try {
        console.log("🚀 Initializing collections...");
        
        let collection = await getCollectionInfo();
        
        if (!collection || !collection.tokenId) {
            console.log("📦 No collection found, creating first collection...");
            collection = await createNewCollection(1);
        } else {
            console.log(`📦 Found existing collection: ${collection.name} (${collection.tokenId})`);
            
            // Check if current collection is approaching limit
            const currentCount = await getCurrentNFTCount(collection.tokenId);
            const maxSupply = 1000000;
            const warningThreshold = maxSupply * 0.9; // 90% of max supply
            
            if (currentCount >= warningThreshold) {
                console.log(`⚠️  Collection ${collection.name} is at ${currentCount}/${maxSupply} NFTs (${Math.round(currentCount/maxSupply*100)}%)`);
                console.log("🔄 Creating new collection for future NFTs...");
                
                const nextCollectionNumber = (collection.collectionNumber || 1) + 1;
                collection = await createNewCollection(nextCollectionNumber);
            } else {
                console.log(`✅ Collection ${collection.name} has ${currentCount} NFTs (${Math.round(currentCount/maxSupply*100)}% capacity)`);
            }
        }
        
        return collection;
    } catch (err) {
        console.error("❌ Error initializing collections:", err);
        throw err;
    }
}

// Endpoint: Create wallet
app.post('/create-wallet', async (req, res) => {
  try {
    const newKey = PrivateKey.generateED25519();
    const response = await new AccountCreateTransaction()
      .setKey(newKey.publicKey)
      .setInitialBalance(new Hbar(10))
      .execute(client);
    const receipt = await response.getReceipt(client);
    const newAccountId = receipt.accountId.toString();
    // Store in-memory
    userWallets[newAccountId] = { accountId: newAccountId, privateKey: newKey.toStringRaw() };
    res.json({ accountId: newAccountId, privateKey: newKey.toStringRaw() });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Endpoint: Create NFT Collection (Optional - collections auto-created)
app.post('/create-collection', async (req, res) => {
    try {
        // Check if collection already exists
        const existingCollection = await getCollectionInfo();
        if (existingCollection && existingCollection.tokenId) {
            return res.status(400).json({ 
                error: 'Collection already exists', 
                collection: existingCollection,
                note: 'Collections are automatically created when needed. Use /collection-status to check current collection.'
            });
        }

        // Create new collection
        const collection = await createNewCollection(1);
        res.json({ 
            message: 'Collection created successfully',
            collection: collection
        });
    } catch (err) {
        console.error("Error in /create-collection:", err);
        res.status(500).json({ error: err.message });
    }
});

// Endpoint: Get collection status
app.get('/collection-status', async (req, res) => {
    try {
        const collection = await getCollectionInfo();
        if (!collection || !collection.tokenId) {
            return res.status(404).json({ error: 'No collection found' });
        }

        const currentCount = await getCurrentNFTCount(collection.tokenId);
        const maxSupply = 1000000;
        const usagePercentage = Math.round((currentCount / maxSupply) * 100);
        
        res.json({
            collection: {
                ...collection,
                nftCount: currentCount,
                maxSupply: maxSupply,
                usagePercentage: usagePercentage,
                status: currentCount >= maxSupply ? 'FULL' : 
                       currentCount >= maxSupply * 0.9 ? 'NEAR_LIMIT' : 'ACTIVE'
            }
        });
    } catch (err) {
        console.error("Error in /collection-status:", err);
        res.status(500).json({ error: err.message });
    }
});

// Modified Endpoint: Mint NFT
app.post('/mint-nft', async (req, res) => {
    try {
        const { ownerAccountId, ownerPrivateKey, metadata } = req.body;
        if (!ownerAccountId || !ownerPrivateKey || !metadata) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        // Get collection info
        let collection = await getCollectionInfo();
        if (!collection || !collection.tokenId) {
            console.log("📦 No collection found, creating new one...");
            collection = await createNewCollection(1);
        }

        // Check if current collection is at limit and create new one if needed
        const currentCount = await getCurrentNFTCount(collection.tokenId);
        const maxSupply = 1000000;
        
        if (currentCount >= maxSupply) {
            console.log(`⚠️  Collection ${collection.name} is at maximum capacity (${currentCount}/${maxSupply})`);
            console.log("🔄 Creating new collection for this NFT...");
            
            const nextCollectionNumber = (collection.collectionNumber || 1) + 1;
            collection = await createNewCollection(nextCollectionNumber);
        }

        const tokenId = collection.tokenId;
        const supplyKey = PrivateKey.fromString(collection.supplyKey);

        // Associate NFT with owner (with error handling for already associated)
        const ownerClient = Client.forTestnet().setOperator(ownerAccountId, PrivateKey.fromString(ownerPrivateKey));
        let associationError = null;
        try {
            const associateTx = await new TokenAssociateTransaction()
                .setAccountId(ownerAccountId)
                .setTokenIds([tokenId])
                .freezeWith(ownerClient)
                .sign(PrivateKey.fromString(ownerPrivateKey));
            await associateTx.execute(ownerClient).then(tx => tx.getReceipt(ownerClient));
        } catch (e) {
            if (e.message.includes('TOKEN_ALREADY_ASSOCIATED_TO_ACCOUNT')) {
                console.log('Account already associated with token, continuing with mint...');
                associationError = e;
            } else {
                throw e;
            }
        }

        try {
            // Mint NFT to treasury (operator) with metadata
            const metadataString = JSON.stringify(metadata);
            const metadataBuffer = Buffer.from(metadataString);
            const mintTx = await new TokenMintTransaction()
                .setTokenId(tokenId)
                .setMetadata([metadataBuffer])
                .freezeWith(client)
                .sign(supplyKey);
            const mintSubmit = await mintTx.execute(client);
            const mintRx = await mintSubmit.getReceipt(client);
            const serial = mintRx.serials[0].toString();

            // Transfer NFT to owner
            const transferTx = await new TransferTransaction()
                .addNftTransfer(tokenId, serial, operatorId, ownerAccountId)
                .freezeWith(client)
                .sign(operatorKey);
            await transferTx.execute(client).then(tx => tx.getReceipt(client));

            // Update collection NFT count
            collection.nftCount = await getCurrentNFTCount(tokenId);
            await saveCollectionInfo(collection);

            res.json({ 
                tokenId: tokenId,
                serial,
                metadata: metadataString,
                collection: {
                    name: collection.name,
                    symbol: collection.symbol,
                    collectionNumber: collection.collectionNumber,
                    nftCount: collection.nftCount,
                    maxSupply: maxSupply
                },
                note: associationError ? 'Account was already associated with token' : 'Account was newly associated with token'
            });
        } catch (mintError) {
            console.error("Error during mint/transfer:", mintError);
            res.status(500).json({ 
                error: mintError.message,
                note: associationError ? 'Account was already associated with token' : 'Account was newly associated with token'
            });
        }
    } catch (err) {
        console.error("Error in /mint-nft:", err);
        res.status(500).json({ error: err.message });
    }
});

// Endpoint: Transfer NFT (buy/sell/exchange)
app.post('/transfer-nft', async (req, res) => {
  /*
    Expects body: {
      tokenId: string,
      serial: string,
      fromAccountId: string,
      fromPrivateKey: string,
      toAccountId: string
    }
  */
  try {
    const { tokenId, serial, fromAccountId, fromPrivateKey, toAccountId } = req.body;
    if (!tokenId || !serial || !fromAccountId || !fromPrivateKey || !toAccountId) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    // Associate NFT with recipient if not already
    const toClient = Client.forTestnet().setOperator(toAccountId, operatorKey);
    try {
      const associateTx = await new TokenAssociateTransaction()
        .setAccountId(toAccountId)
        .setTokenIds([tokenId])
        .freezeWith(toClient)
        .sign(operatorKey);
      await associateTx.execute(toClient).then(tx => tx.getReceipt(toClient));
    } catch (e) {
      // Ignore if already associated
    }
    // Transfer NFT
    const fromClient = Client.forTestnet().setOperator(fromAccountId, PrivateKey.fromString(fromPrivateKey));
    const transferTx = await new TransferTransaction()
      .addNftTransfer(tokenId, serial, fromAccountId, toAccountId)
      .freezeWith(fromClient)
      .sign(PrivateKey.fromString(fromPrivateKey));
    await transferTx.execute(fromClient).then(tx => tx.getReceipt(fromClient));
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Endpoint: Get all NFTs in our collection
app.get('/collection-nfts', async (req, res) => {
    try {
        // Get collection info
        const collection = await getCollectionInfo();
        if (!collection || !collection.tokenId) {
            return res.status(400).json({ error: 'Collection not created yet' });
        }

        // Query Hedera Mirror Node for NFTs in our collection
        const url = `https://testnet.mirrornode.hedera.com/api/v1/tokens/${collection.tokenId}/nfts`;
        const { data } = await axios.get(url);
        
        // For each NFT, decode metadata if possible
        const nfts = await Promise.all((data.nfts || []).map(async (nft) => {
            let metadataDecoded = null;
            if (nft.metadata) {
                metadataDecoded = decodeBase64Json(nft.metadata);
            }
            return {
                token_id: nft.token_id,
                serial_number: nft.serial_number,
                metadata: nft.metadata,
                metadataDecoded,
                account_id: nft.account_id
            };
        }));

        res.json({ 
            collection: {
                tokenId: collection.tokenId,
                name: collection.name,
                symbol: collection.symbol
            },
            nfts 
        });
    } catch (err) {
        console.error("Error in /collection-nfts:", err);
        if (err.response) {
            // If the error is from the mirror node API
            res.status(err.response.status).json({ 
                error: 'Error fetching from Hedera Mirror Node',
                details: err.response.data
            });
        } else {
            res.status(500).json({ error: err.message });
        }
    }
});

// Endpoint: Get all NFTs owned by an account
app.get('/nfts/:accountId', async (req, res) => {
    const { accountId } = req.params;
    try {
        // Query Hedera Mirror Node for NFTs owned by this account
        const url = `https://testnet.mirrornode.hedera.com/api/v1/accounts/${accountId}/nfts`;
        const { data } = await axios.get(url);
        
        // For each NFT, decode metadata if possible
        const nfts = await Promise.all((data.nfts || []).map(async (nft) => {
            let metadataDecoded = null;
            if (nft.metadata) {
                metadataDecoded = decodeBase64Json(nft.metadata);
            }
            return {
                token_id: nft.token_id,
                serial_number: nft.serial_number,
                metadata: nft.metadata,
                metadataDecoded,
                account_id: nft.account_id
            };
        }));

        res.json({ nfts });
    } catch (err) {
        console.error("Error in /nfts/:accountId:", err);
        if (err.response) {
            // If the error is from the mirror node API
            res.status(err.response.status).json({ 
                error: 'Error fetching from Hedera Mirror Node',
                details: err.response.data
            });
        } else {
            res.status(500).json({ error: err.message });
        }
    }
});

// Endpoint: Get all NFTs minted by the operator (all tokens where operator is treasury)
app.get('/nfts', async (req, res) => {
  try {
    // Query all tokens for which the operator is treasury
    const url = `https://testnet.mirrornode.hedera.com/api/v1/tokens?treasury_id=${operatorId}`;
    const { data } = await axios.get(url);
    const tokens = data.tokens || [];
    // For each token, get all NFTs
    let allNfts = [];
    for (const token of tokens) {
      if (token.type !== 'NON_FUNGIBLE_UNIQUE') continue;
      const nftsUrl = `https://testnet.mirrornode.hedera.com/api/v1/tokens/${token.token_id}/nfts`;
      const { data: nftsData } = await axios.get(nftsUrl);
      for (const nft of nftsData.nfts || []) {
        let metadataDecoded = null;
        if (nft.metadata) {
          metadataDecoded = decodeBase64Json(nft.metadata);
        }
        allNfts.push({
          token_id: nft.token_id,
          serial_number: nft.serial_number,
          metadata: nft.metadata,
          metadataDecoded
        });
      }
    }
    res.json({ nfts: allNfts });
  } catch (err) {
    console.error("Error in /nfts:", err);
    res.status(500).json({ error: err.message });
  }
});

// Initialize collections and start server
async function startServer() {
    try {
        console.log("🚀 Starting Hedera NFT Application...");
        
        // Initialize collections on startup
        await initializeCollections();
        
        // Start the server
        app.listen(PORT, () => {
            console.log(`✅ Hedera NFT app listening on port ${PORT}`);
            console.log("📋 Available endpoints:");
            console.log("   POST /create-wallet - Create new wallet");
            console.log("   POST /create-collection - Create collection (optional, auto-created)");
            console.log("   POST /mint-nft - Mint NFT (auto-creates collections)");
            console.log("   POST /transfer-nft - Transfer NFT between accounts");
            console.log("   GET /collection-status - Get current collection status");
            console.log("   GET /collection-nfts - Get all NFTs in current collection");
            console.log("   GET /nfts/:accountId - Get NFTs owned by account");
            console.log("   GET /nfts - Get all NFTs minted by operator");
        });
    } catch (err) {
        console.error("❌ Failed to start server:", err);
        process.exit(1);
    }
}

// Start the server
startServer();