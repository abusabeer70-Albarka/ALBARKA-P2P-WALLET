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
