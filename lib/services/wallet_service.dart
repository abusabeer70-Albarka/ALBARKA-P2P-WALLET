import 'dart:convert';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'transaction_history_service.dart';
class WalletService {
  final _storage = const FlutterSecureStorage();
  final TransactionHistoryService _historyService =
      TransactionHistoryService();
  static const String _sepoliaRpc =
    String.fromEnvironment(
  'ALCHEMY_SEPOLIA_RPC',
  defaultValue: 'https://rpc.sepolia.org',
);

  static const String _alchemyApiKey =
      String.fromEnvironment('ALCHEMY_API_KEY');
  final Web3Client _client =
      Web3Client(_sepoliaRpc, http.Client());

  Future<int> getSepoliaBlockNumber() async {
    return await _client.getBlockNumber();
  }

  Future<double> getEthUsdPrice() async {
    final response = await http.get(
      Uri.parse(
        'https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to fetch ETH price.');
    }

    final data = jsonDecode(response.body);
    final price = data['ethereum']?['usd'];

    if (price == null) {
      throw Exception('ETH/USD price not found.');
    }

    return (price as num).toDouble();
  }

  Future<double?> getSepoliaBalance() async {
    final privateKey = await getPrivateKey();

    if (privateKey == null || privateKey.isEmpty) {
      return null;
    }

    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = credentials.address;
    final balance = await _client.getBalance(address);

    return balance.getInWei.toDouble() / 1000000000000000000;
  }

  Future<String> createWallet() async {
    // Generate a standard 12-word BIP-39 English recovery phrase.
    final mnemonic = Bip39MnemonicGenerator(Bip39Languages.english)
        .fromWordsNumber(Bip39WordsNum.wordsNum12);

    // Convert the recovery phrase into the BIP-39 seed.
    final seed = Bip39SeedGenerator(mnemonic).generate();

    // Derive the first Ethereum account using BIP-44.
    final wallet = Bip44.fromSeed(seed, Bip44Coins.ethereum)
        .deriveDefaultPath;

    // Get the derived private key.
    final privateKey = wallet.privateKey.raw;

    // Convert private key bytes to hexadecimal.
    final privateKeyHex = privateKey
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    // Create the Ethereum credentials from the derived private key.
    final credentials = EthPrivateKey.fromHex(privateKeyHex);

    final address = credentials.address;

    // Store sensitive wallet data locally.
    await _storage.write(
      key: 'recovery_phrase',
      value: mnemonic.toStr(),
    );

    await _storage.write(
      key: 'private_key',
      value: privateKeyHex,
    );

    await _storage.write(
      key: 'wallet_address',
      value: address.hexEip55,
    );

    return address.hexEip55;
  }

  Future<String> importWallet(String recoveryPhrase) async {
    final mnemonic = Bip39Mnemonic.fromString(
      recoveryPhrase.trim(),
    );

    final seed = Bip39SeedGenerator(mnemonic).generate();

    final wallet = Bip44.fromSeed(seed, Bip44Coins.ethereum)
        .deriveDefaultPath;

    final privateKey = wallet.privateKey.raw;
    final privateKeyHex = privateKey
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    final credentials = EthPrivateKey.fromHex(privateKeyHex);
    final address = credentials.address;

    await _storage.write(
      key: 'recovery_phrase',
      value: mnemonic.toStr(),
    );

    await _storage.write(
      key: 'private_key',
      value: privateKeyHex,
    );

    await _storage.write(
      key: 'wallet_address',
      value: address.hexEip55,
    );

    return address.hexEip55;
  }

  Future<String?> getAddress() async {
    return await _storage.read(key: 'wallet_address');
  }

  Future<String?> getPrivateKey() async {
    return await _storage.read(key: 'private_key');
  }

  Future<String?> getRecoveryPhrase() async {
    return await _storage.read(key: 'recovery_phrase');
  }

  Future<String> sendSepoliaEth({
    required String recipientAddress,
    required String amountEth,
  }) async {
    final privateKey = await getPrivateKey();

    if (privateKey == null || privateKey.isEmpty) {
      throw Exception('Wallet private key not found.');
    }

    final credentials = EthPrivateKey.fromHex(privateKey);
    final recipient = EthereumAddress.fromHex(recipientAddress);

    // Convert decimal ETH to Wei safely.
    // Example: 0.00001 ETH = 10000000000000 Wei.
    final parts = amountEth.trim().split('.');
    final wholePart = parts.isEmpty || parts[0].isEmpty ? '0' : parts[0];
    final fractionPart = parts.length > 1 ? parts[1] : '';

    if (parts.length > 2 ||
        !RegExp(r'^\d+$').hasMatch(wholePart) ||
        (fractionPart.isNotEmpty &&
            !RegExp(r'^\d+$').hasMatch(fractionPart))) {
      throw FormatException('Invalid ETH amount: $amountEth');
    }

    if (fractionPart.length > 18) {
      throw FormatException('ETH amount has more than 18 decimal places.');
    }

    final paddedFraction = fractionPart.padRight(18, '0');
    final amountWei = BigInt.parse(wholePart) * BigInt.from(10).pow(18) +
        BigInt.parse(paddedFraction);

    if (amountWei <= BigInt.zero) {
      throw FormatException('ETH amount must be greater than zero.');
    }

    final transaction = Transaction(
      to: recipient,
      value: EtherAmount.inWei(amountWei),
    );

   final txHash = await _client.sendTransaction(
  credentials,
  transaction,
  chainId: 11155111,
);

await _historyService.addTransaction(
  txHash: txHash,
  type: 'Send',
  amount: amountEth,
  address: recipientAddress,
  status: 'Success',
  network: 'Sepolia',
);

return txHash;
  }

  Future<List<Map<String, dynamic>>> getBlockchainTransactions() async {
    final walletAddress = await getAddress();

    if (walletAddress == null || walletAddress.isEmpty) {
      return [];
    }

    if (_alchemyApiKey.isEmpty) {
      throw Exception('ALCHEMY_API_KEY is not configured.');
    }

    final url = Uri.parse(
      'https://eth-sepolia.g.alchemy.com/v2/$_alchemyApiKey',
    );

    Future<List<Map<String, dynamic>>> fetchTransfers({
      required String direction,
    }) async {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'alchemy_getAssetTransfers',
          'params': [
            {
              'fromBlock': '0x0',
              'toBlock': 'latest',
              direction == 'incoming'
                  ? 'toAddress'
                  : 'fromAddress': walletAddress,
              'category': ['external'],
              'withMetadata': true,
              'excludeZeroValue': true,
              'maxCount': '0x64',
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Alchemy request failed: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data['error'] != null) {
        throw Exception(
          data['error']['message']?.toString() ??
              'Alchemy API error.',
        );
      }

      final transfers = data['result']?['transfers'];

      if (transfers is! List) {
        return [];
      }

      return transfers
          .whereType<Map>()
          .map<Map<String, dynamic>>((tx) {
            final value = tx['value']?.toString() ?? '0';
            final hash = tx['hash']?.toString() ?? '';
            final from = tx['from']?.toString() ?? '';
            final to = tx['to']?.toString() ?? '';

            return {
              'txHash': hash,
              'type': direction == 'incoming' ? 'Receive' : 'Send',
              'amount': value,
              'address': direction == 'incoming' ? from : to,
              'status': 'Success',
              'network': 'Sepolia',
              'timestamp':
                  tx['metadata']?['blockTimestamp']?.toString() ??
                      DateTime.now().toIso8601String(),
            };
          })
          .where((tx) => tx['txHash'].toString().isNotEmpty)
          .toList();
    }

    final incoming = await fetchTransfers(direction: 'incoming');
    final outgoing = await fetchTransfers(direction: 'outgoing');

    return [...incoming, ...outgoing];
  }

  Future<void> syncBlockchainTransactions() async {
    final blockchainTransactions = await getBlockchainTransactions();

    for (final tx in blockchainTransactions) {
      await _historyService.addTransaction(
        txHash: tx['txHash']?.toString() ?? '',
        type: tx['type']?.toString() ?? 'Send',
        amount: tx['amount']?.toString() ?? '0',
        address: tx['address']?.toString() ?? '',
        status: tx['status']?.toString() ?? 'Success',
        network: tx['network']?.toString() ?? 'Sepolia',
        timestamp: tx['timestamp']?.toString(),
      );
    }
  }

}
