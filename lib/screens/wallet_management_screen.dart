import 'package:flutter/material.dart';

import '../main.dart' show BackupScreen;
import '../services/wallet_service.dart';
import 'set_pin_screen.dart';

class WalletManagementScreen extends StatelessWidget {
  const WalletManagementScreen({super.key});

  Future<bool> _confirmReplaceWallet(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace Current Wallet?'),
        content: const Text(
          'This will replace the wallet currently stored on this device. '
          'Make sure you have safely backed up your current recovery phrase '
          'before continuing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _openImport(BuildContext context) async {
    if (!await _confirmReplaceWallet(context)) return;

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ImportWalletFromSettingsScreen(),
      ),
    );
  }

  void _openCreate(BuildContext context) async {
    if (!await _confirmReplaceWallet(context)) return;

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateWalletFromSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 72,
          ),
          const SizedBox(height: 18),
          const Text(
            'Manage Your Wallet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create or import another wallet on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),

          Card(
            color: const Color(0xFF081D49),
            child: ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Import Existing Wallet'),
              subtitle: const Text(
                'Restore a wallet using its recovery phrase.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openImport(context),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            color: const Color(0xFF081D49),
            child: ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Create New Wallet'),
              subtitle: const Text(
                'Generate a completely new wallet.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openCreate(context),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            color: const Color(0xFF081D49),
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('App PIN'),
              subtitle: const Text(
                'Set or change your 6-digit app PIN.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SetPinScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

        Card(
          color: const Color(0xFF081D49),
          child: ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Secure Backup'),
            subtitle: const Text(
              'View your recovery phrase securely with your App PIN.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BackupScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Important: Always back up your recovery phrase '
                      'before replacing the current wallet.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImportWalletFromSettingsScreen extends StatefulWidget {
  const ImportWalletFromSettingsScreen({super.key});

  @override
  State<ImportWalletFromSettingsScreen> createState() =>
      _ImportWalletFromSettingsScreenState();
}

class _ImportWalletFromSettingsScreenState
    extends State<ImportWalletFromSettingsScreen> {
  final WalletService _walletService = WalletService();
  final TextEditingController _phraseController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _phraseController.dispose();
    super.dispose();
  }

  Future<void> _importWallet() async {
    final phrase = _phraseController.text.trim();

    if (phrase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your recovery phrase.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _walletService.importWallet(phrase);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet imported successfully.'),
        ),
      );

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid recovery phrase. Please check the words.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Wallet'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Import Existing Wallet',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enter your 12-word recovery phrase to restore your wallet.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _phraseController,
            maxLines: 4,
            obscureText: false,
            decoration: InputDecoration(
              hintText: 'Enter your 12 recovery words',
              filled: true,
              fillColor: const Color(0xFF0B255D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _importWallet,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Import Wallet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateWalletFromSettingsScreen extends StatefulWidget {
  const CreateWalletFromSettingsScreen({super.key});

  @override
  State<CreateWalletFromSettingsScreen> createState() =>
      _CreateWalletFromSettingsScreenState();
}

class _CreateWalletFromSettingsScreenState
    extends State<CreateWalletFromSettingsScreen> {
  final WalletService _walletService = WalletService();

  bool _loading = false;
  String? _address;

  Future<void> _createWallet() async {
    setState(() => _loading = true);

    try {
      final address = await _walletService.createWallet();

      if (!mounted) return;

      setState(() {
        _address = address;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wallet creation failed: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.add_circle_outline,
              size: 70,
            ),
            const SizedBox(height: 24),
            const Text(
              'Create a New Wallet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A new recovery phrase will be generated. '
              'Your current wallet will be replaced on this device.',
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            if (_address != null) ...[
              const Text(
                'New Wallet Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(_address!),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _createWallet,
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(
                        _address == null
                            ? 'Create New Wallet'
                            : 'Create Another Wallet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
