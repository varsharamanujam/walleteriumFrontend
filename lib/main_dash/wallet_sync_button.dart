import 'package:flutter/material.dart';
import '../backend/google_wallet_service.dart';

class WalletSyncButton extends StatefulWidget {
  @override
  _WalletSyncButtonState createState() => _WalletSyncButtonState();
}

class _WalletSyncButtonState extends State<WalletSyncButton> {
  final GoogleWalletService _walletService = GoogleWalletService();
  bool _loading = false;

  Future<void> _syncWallet() async {
    setState(() => _loading = true);
    try {
      await _walletService.syncPassesWithFirebase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallet passes synced to Firebase!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error syncing: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.sync),
      label: Text(_loading ? 'Syncing...' : 'Sync Wallet Passes'),
      onPressed: _loading ? null : _syncWallet,
    );
  }
}
