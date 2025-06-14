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
        const data = await fs.readFile('collection.json', 'utf8');
        return JSON.parse(data);
    } catch (err) {
        return null;
    }
}

// Helper to save collection info
async function saveCollectionInfo(info) {
    await fs.writeFile('collection.json', JSON.stringify(info, null, 2));
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

// Endpoint: Create NFT Collection
app.post('/create-collection', async (req, res) => {
    try {
        // Check if collection already exists
        const existingCollection = await getCollectionInfo();
        if (existingCollection && existingCollection.tokenId) {
            return res.status(400).json({ error: 'Collection already exists', collection: existingCollection });
        }

        // Create NFT collection
        const supplyKey = PrivateKey.generateED25519();
        const nftCreateTx = await new TokenCreateTransaction()
            .setTokenName('DemoNFT')
            .setTokenSymbol('DNFT')
            .setTokenType(TokenType.NonFungibleUnique)
            .setDecimals(0)
            .setInitialSupply(0)
            .setTreasuryAccountId(operatorId)
            .setSupplyType(TokenSupplyType.Finite)
            .setMaxSupply(1000000) // Increased max supply for multiple NFTs
            .setSupplyKey(supplyKey)
            .freezeWith(client);
        
        const nftCreateSign = await nftCreateTx.sign(operatorKey);
        const nftCreateSubmit = await nftCreateSign.execute(client);
        const nftCreateRx = await nftCreateSubmit.getReceipt(client);
        const tokenId = nftCreateRx.tokenId;

        // Save collection info
        const collectionInfo = {
            tokenId: tokenId.toString(),
            supplyKey: supplyKey.toStringRaw(),
            name: 'DemoNFT',
            symbol: 'DNFT'
        };
        await saveCollectionInfo(collectionInfo);

        res.json({ 
            message: 'Collection created successfully',
            collection: collectionInfo
        });
    } catch (err) {
        console.error("Error in /create-collection:", err);
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
        const collection = await getCollectionInfo();
        if (!collection || !collection.tokenId) {
            return res.status(400).json({ error: 'Collection not created. Please create collection first using /create-collection' });
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

            res.json({ 
                tokenId: tokenId,
                serial,
                metadata: metadataString,
                collection: collection.name,
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

app.listen(PORT, () => {
  console.log(`Hedera NFT app listening on port ${PORT}`);
});