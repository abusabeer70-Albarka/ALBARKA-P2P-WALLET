import 'package:flutter/material.dart';

void main() {
  runApp(const AlbarkaApp());
}

class AlbarkaApp extends StatelessWidget {
  const AlbarkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALBARKA P2P WALLET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF03133D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1479FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Image.asset('assets/logo.png', width: 125, height: 125),
              const SizedBox(height: 20),
              const Text(
                'ALBARKA P2P WALLET',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Secure • Fast • Reliable',
                style: TextStyle(color: Color(0xFF55B9FF), fontSize: 16),
              ),
_ActionButton(
  text: 'Create New Wallet',
  filled: true,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CreateWalletScreen(),
    ),
  ),
),
const SizedBox(height: 14),
_ActionButton(
  text: 'Import Existing Wallet',
  filled: false,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ImportWalletScreen(),
    ),
  ),
),
              const Spacer(),
              const Text(
                'Your keys. Your crypto. Your control.',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateWalletScreen extends StatelessWidget {
  const CreateWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_outlined, size: 64, color: Color(0xFF39A8FF)),
            const SizedBox(height: 24),
            const Text(
              'Create your wallet',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'The next secure step will generate a recovery phrase on your device. '
              'Never send your recovery phrase to anyone.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
            ),
            const Spacer(),
            _ActionButton(
              text: 'Continue',
              filled: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Backup')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recovery Phrase',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Production implementation will generate and display the BIP-39 '
              'recovery phrase locally and securely.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B255D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1479FF)),
              ),
              child: const Text(
                'TEST MODE\n\nRecovery phrase generation is intentionally not enabled in this UI scaffold.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const Spacer(),
            _ActionButton(
              text: 'Go to Wallet Demo',
              filled: true,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImportWalletScreen extends StatelessWidget {
  const ImportWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Existing Wallet',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const TextField(
              
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Recovery phrase',
                hintText: 'Enter your recovery phrase',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            _ActionButton(
              text: 'Import',
              filled: true,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assets = [
      ('Bitcoin', 'BTC', '0.000000', Icons.currency_bitcoin),
      ('Ethereum', 'ETH', '0.000000', Icons.diamond_outlined),
      ('BNB', 'BNB', '0.000000', Icons.token),
      ('USDT', 'USDT', '0.00', Icons.attach_money),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALBARKA P2P WALLET'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Markets'),
          NavigationDestination(icon: Icon(Icons.apps), label: 'DApps'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B3E9B), Color(0xFF06245C)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Balance', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('\$0.00', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _RoundAction(icon: Icons.arrow_upward, label: 'Send'),
              _RoundAction(icon: Icons.qr_code_2, label: 'Receive'),
              _RoundAction(icon: Icons.swap_horiz, label: 'Swap'),
              _RoundAction(icon: Icons.add_card, label: 'Buy'),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Assets', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...assets.map(
            (a) => Card(
              color: const Color(0xFF081D49),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF123D83),
                  child: Icon(a.$4, color: Colors.white),
                ),
                title: Text(a.$1),
                subtitle: Text(a.$2),
                trailing: Text(a.$3, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: filled
          ? FilledButton(
              onPressed: onTap,
              child: Text(text, style: const TextStyle(fontSize: 16)),
            )
          : OutlinedButton(
              onPressed: onTap,
              child: Text(text, style: const TextStyle(fontSize: 16)),
            ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RoundAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF0D4EB5),
          child: Icon(icon),
        ),
        const SizedBox(height: 7),
        Text(label),
      ],
    );
  }
}
