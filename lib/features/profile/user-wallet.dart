import 'package:flutter/material.dart';

class UserWalletScreen extends StatefulWidget {
  const UserWalletScreen({Key? key}) : super(key: key);

  @override
  State<UserWalletScreen> createState() => _UserWalletScreenState();
}

class _UserWalletScreenState extends State<UserWalletScreen> {
  final _accountIdController = TextEditingController();
  final _privateKeyController = TextEditingController();

  void _submitCredentials() {
    final accountId = _accountIdController.text.trim();
    final privateKey = _privateKeyController.text.trim();

    if (accountId.isNotEmpty && privateKey.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallet connected: $accountId')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hedera Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _accountIdController,
              decoration: InputDecoration(
                labelText: 'Account ID (e.g., 0.0.12345)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _privateKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Private Key',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitCredentials,
              child: Text('Connect Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
