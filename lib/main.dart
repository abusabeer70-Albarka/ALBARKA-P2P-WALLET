import 'services/transaction_history_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'services/wallet_service.dart';

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

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final WalletService _walletService = WalletService();

  bool _creating = false;
  String? _address;

  Future<void> _createWallet() async {
    setState(() => _creating = true);

    try {
      final address = await _walletService.createWallet();

      if (!mounted) return;

      setState(() {
        _address = address;
        _creating = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _creating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallet creation failed: $e')),
      );
    }
  }

  void _openBackupScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BackupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 64,
              color: Color(0xFF39A8FF),
            ),
            const SizedBox(height: 24),
            const Text(
              'Create your wallet',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your wallet will be generated securely on this device. '
              'Keep your wallet credentials private and never share them.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            if (_address != null) ...[
              const Text(
                'Wallet Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                _address!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF55B9FF),
                ),
              ),
            ],
            const Spacer(),
            _ActionButton(
              text: _creating
                  ? 'Creating Wallet...'
                  : _address == null
                      ? 'Create New Wallet'
                      : 'Continue',
              filled: true,
              onTap: () {
                if (_creating) return;
                if (_address == null) {
                  _createWallet();
                } else {
                  _openBackupScreen();
                }
              },
              ),
          ],
        ),
      ),
    );
  }
}

class BackupScreen extends StatefulWidget {
  BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final WalletService _walletService = WalletService();
  String? _recoveryPhrase;
  bool _loading = true;
  bool _confirmed = false;
  bool _phraseVisible = false;  

  @override
  void initState() {
    super.initState();
    _createWallet();
  }

  Future<void> _createWallet() async {
    try {
      final phrase = await _walletService.getRecoveryPhrase();
      if (!mounted) return;
      setState(() {
        _recoveryPhrase = phrase;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallet creation failed: ')),
      );
    }
  }

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
              'Write down these 12 words and keep them somewhere safe. Anyone who has them can access your wallet.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B255D),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF1479FF)),
                      ),
                     child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Center(
        child: _phraseVisible
            ? SelectableText(
                _recoveryPhrase ?? 'Recovery phrase unavailable.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const Text(
                '•••• •••• •••• ••••\n'
                '•••• •••• •••• ••••',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  letterSpacing: 2,
                ),
              ),
      ),
    ),
    const SizedBox(height: 16),
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _recoveryPhrase == null
            ? null
            : () {
                setState(() {
                  _phraseVisible = !_phraseVisible;
                });
              },
        icon: Icon(
          _phraseVisible
              ? Icons.visibility_off
              : Icons.visibility,
        ),
        label: Text(
          _phraseVisible
              ? 'Hide Recovery Phrase'
              : 'Show Recovery Phrase',
        ),
      ),
    ),
  ],
),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _confirmed,
              onChanged: _recoveryPhrase == null
                  ? null
                  : (value) => setState(() => _confirmed = value ?? false),
              title: const Text(
                'I have safely written down my recovery phrase.',
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            _ActionButton(
              text: 'Continue to Wallet',
              filled: _confirmed,
              onTap: _confirmed
                  ? () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      )
                  : () {},
            ),
          ],
        ),
      ),
    );
  }
}

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
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
        const SnackBar(content: Text('Enter your recovery phrase.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _walletService.importWallet(phrase);


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid recovery phrase. Please check the words.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Wallet')),
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
            textInputAction: TextInputAction.done,
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
          _ActionButton(
            text: _loading ? 'Importing...' : 'Import Wallet',
            filled: !_loading,
            onTap: _loading ? () {} : _importWallet,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WalletService _walletService = WalletService();
  String? _address;
  String _ethBalance = '0.000000';
  double _ethUsdPrice = 0.0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAddress();
    _loadEthBalance();
  }

  Future<void> _loadAddress() async {
    final address = await _walletService.getAddress();
    if (!mounted) return;
    setState(() => _address = address);
  }

  Future<void> _loadEthBalance() async {
    double? balance;
    double? price;

    try {
      balance = await _walletService.getSepoliaBalance();
    } catch (_) {}

    try {
      price = await _walletService.getEthUsdPrice();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      if (balance != null) {
        _ethBalance = balance.toStringAsFixed(6);
      }

      if (price != null) {
        _ethUsdPrice = price;
      }
    });
  }


  Future<void> _testSepolia() async {
    try {
      final block = await _walletService.getSepoliaBlockNumber();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sepolia connected. Block: $block')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sepolia connection failed: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final assets = [
      ('Bitcoin', 'BTC', '0.000000', Icons.currency_bitcoin),
      ('Ethereum', 'ETH', _ethBalance, Icons.diamond_outlined),
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
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });

            if (index != 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    index == 1
                        ? 'Markets coming soon'
                        : index == 2
                            ? 'DApps coming soon'
                            : 'Settings coming soon',
                  ),
                ),
              );
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart),
              label: 'Markets',
            ),
            NavigationDestination(
              icon: Icon(Icons.apps),
              label: 'DApps',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Balance', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text(
                  '\$${((double.tryParse(_ethBalance) ?? 0) * _ethUsdPrice).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                _RoundAction(
                  icon: Icons.arrow_upward,
                  label: 'Send',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SendScreen(),
                    ),
                  ),
                ),
                _RoundAction(
                  icon: Icons.qr_code_2,
                  label: 'Receive',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiveScreen(address: _address),
                    ),
                  ),
                ),
                _RoundAction(
                  icon: Icons.swap_horiz,
                  label: 'Swap',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Swap coming soon')),
                  ),
                ),
                _RoundAction(
                  icon: Icons.add_card,
                  label: 'Buy',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Buy coming soon')),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _testSepolia,
              child: const Text('Test Sepolia'),
            ),
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
                onTap: a.$2 == 'ETH' && _address != null
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EthereumAssetScreen(address: _address!),
                          ),
                        )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class EthereumAssetScreen extends StatefulWidget {
  final String address;

  const EthereumAssetScreen({
    super.key,
    required this.address,
  });

  @override
  State<EthereumAssetScreen> createState() => _EthereumAssetScreenState();
}

class _EthereumAssetScreenState extends State<EthereumAssetScreen> {
  final WalletService _walletService = WalletService();
  final TransactionHistoryService _historyService =
      TransactionHistoryService();

  String _balance = 'Loading...';
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _syncBlockchainTransactions();
    _loadTransactions();
  }

  Future<void> _loadBalance() async {
    try {
      final balance = await _walletService.getSepoliaBalance();

      if (!mounted) return;

      setState(() {
        _balance = balance == null
            ? 'No wallet'
            : '${balance.toStringAsFixed(6)} ETH';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _balance = 'Unable to load');
    }
  }

  String _formatTransactionDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return 'Unknown date';
    }

    try {
      final date = DateTime.parse(timestamp).toLocal();

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      final hour = date.hour == 0
          ? 12
          : date.hour > 12
              ? date.hour - 12
              : date.hour;

      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '${date.day} ${months[date.month - 1]} ${date.year} • '
          '$hour:$minute $period';
    } catch (_) {
      return timestamp;
    }
  }

  Future<void> _syncBlockchainTransactions() async {
    try {
      await _walletService.syncBlockchainTransactions();
      await _loadTransactions();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction sync failed: $e'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  Future<void> _loadTransactions() async {
    final transactions = await _historyService.getTransactions();

    if (!mounted) return;

    setState(() {
      _transactions = transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ethereum'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B3E9B), Color(0xFF06245C)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ethereum Balance',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 8),
                Text(
                  _balance,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Sepolia Test Network',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Wallet Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF081D49),
              borderRadius: BorderRadius.circular(14),
            ),
            child: SelectableText(widget.address),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SendScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Send'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceiveScreen(address: widget.address),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Receive'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (_transactions.isEmpty)
            const Card(
              color: Color(0xFF081D49),
              child: ListTile(
                leading: Icon(Icons.receipt_long),
                title: Text('No transactions yet'),
                subtitle: Text(
                  'Your Ethereum transactions will appear here.',
                ),
              ),
            )
          else
            ..._transactions.map(
              (tx) => Card(
                color: const Color(0xFF081D49),
                child: ListTile(
                  leading: Icon(
                    tx['type']?.toString() == 'Receive'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: tx['type']?.toString() == 'Receive'
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                  title: Text(
                    '${tx['type']} • ${tx['amount']} ETH',
                  ),
                  subtitle: Text(
                    '${tx['type']?.toString() == 'Receive' ? 'From' : 'To'}: ${tx['address']}\n'
                    'Status: ${tx['status']} • ${tx['network']}\n'
                    'Date: ${_formatTransactionDate(tx['timestamp'] as String?)}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailsScreen(
                          transaction: tx,
                        ),
                      ),
                    );
                  },
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




class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();

  final WalletService _walletService = WalletService();

  bool _sending = false;

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final recipient = _addressController.text.trim();
    final amount = _amountController.text.trim();

    if (recipient.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter recipient address and amount.'),
        ),
      );
      return;
    }

    if (!recipient.startsWith('0x') || recipient.length != 42) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Ethereum address.'),
        ),
      );
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      final txHash = await _walletService.sendSepoliaEth(
        recipientAddress: recipient,
        amountEth: amount,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction sent: $txHash'),
          duration: const Duration(seconds: 8),
        ),
      );

      _addressController.clear();
      _amountController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Send failed: $e'),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send ETH'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Send Ethereum',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Send ETH on Sepolia Testnet',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Recipient Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _addressController,
              enabled: !_sending,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: '0x...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Amount (ETH)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _amountController,
              enabled: !_sending,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: '0.0001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_exchange),
                suffixText: 'ETH',
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _sending ? 'Sending...' : 'Send ETH',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Network: Sepolia Testnet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiveScreen extends StatefulWidget {
  final String? address;

  const ReceiveScreen({super.key, this.address});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final WalletService _walletService = WalletService();
  String _address = 'Loading address...';

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    if (widget.address != null) {
      setState(() => _address = widget.address!);
      return;
    }

    final address = await _walletService.getAddress();

    if (!mounted) return;

    setState(() {
      _address = address ?? 'No wallet address found';
    });
  }

  Future<void> _copyAddress() async {
    if (_address == 'Loading address...' ||
        _address == 'No wallet address found') {
      return;
    }

    await Clipboard.setData(ClipboardData(text: _address));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06152F),
      appBar: AppBar(
        title: const Text('Receive'),
        backgroundColor: const Color(0xFF06152F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Receive Crypto',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            if (_address != 'Loading address...' &&
                _address != 'No wallet address found')
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: QrImageView(
                  data: _address,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Scan this QR code to receive ETH',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sepolia Test Network',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B255D),
                borderRadius: BorderRadius.circular(18),
              ),
              child: SelectableText(
                _address,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _ActionButton(
              text: 'Copy Address',
              filled: true,
              onTap: _copyAddress,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              text: 'Share Address',
              filled: false,
              onTap: () async {
                if (_address == 'Loading address...' ||
                    _address == 'No wallet address found') {
                  return;
                }

                await Share.share(
                  'My ALBARKA P2P WALLET address:\n\n$_address',
                  subject: 'ALBARKA P2P WALLET Address',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _RoundAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF0D4EB5),
            child: Icon(icon),
          ),
          const SizedBox(height: 7),
          Text(label),
        ],
      ),
    );
  }
}

class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return 'Unknown date';
    }

    try {
      final date = DateTime.parse(timestamp).toLocal();

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      final hour = date.hour == 0
          ? 12
          : date.hour > 12
              ? date.hour - 12
              : date.hour;

      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '${date.day} ${months[date.month - 1]} ${date.year} • '
          '$hour:$minute $period';
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final txHash = transaction['txHash']?.toString() ?? '';
    final amount = transaction['amount']?.toString() ?? '0';
    final address = transaction['address']?.toString() ?? '';
    final type = transaction['type']?.toString() ?? 'Send';
    final status = transaction['status']?.toString() ?? 'Unknown';
    final network = transaction['network']?.toString() ?? 'Sepolia';
    final addressLabel = type == 'Receive' ? 'From' : 'To';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.greenAccent,
            size: 72,
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Transaction Successful',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _detailRow('Amount', '$amount ETH'),
          _detailRow(addressLabel, address),
          _detailRow('Status', status),
          _detailRow('Network', network),
          _detailRow(
            'Date & Time',
            _formatDate(transaction['timestamp']?.toString()),
          ),
          const SizedBox(height: 12),
          const Text(
            'Transaction Hash',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            txHash,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () async {
                final receipt = '''
ALBARKA P2P WALLET
Transaction Receipt

Status: $status
Amount: $amount ETH
$addressLabel: $address
Network: $network
Date & Time: ${_formatDate(transaction['timestamp']?.toString())}

Transaction Hash:
$txHash
''';

                await Share.share(
                  receipt,
                  subject: 'ALBARKA P2P WALLET Transaction Receipt',
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Share Transaction Receipt'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
