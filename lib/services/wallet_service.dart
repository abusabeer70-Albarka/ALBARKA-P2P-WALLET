import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/src/core/amount.dart';
import 'package:web3dart/src/core/transaction.dart';

class WalletService {
  final _storage = const FlutterSecureStorage();

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
      value: address.with0x,
    );

    return address.with0x;
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
      value: address.with0x,
    );

    return address.with0x;
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

    final amountWei = EtherAmount.fromUnitAndValue(
      EtherUnit.ether,
      amountEth,
    ).getInWei;

    final transaction = Transaction(
      to: recipient,
      value: EtherAmount.inWei(amountWei),
    );

    final txHash = await _client.sendTransaction(
      credentials,
      transaction,
      chainId: 11155111,
    );

    return txHash;
  }

}
