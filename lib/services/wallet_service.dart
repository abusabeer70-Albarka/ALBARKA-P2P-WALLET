import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';

class WalletService {
  final _storage = const FlutterSecureStorage();

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

    final address = await credentials.address;

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

  Future<String?> getAddress() async {
    return await _storage.read(key: 'wallet_address');
  }

  Future<String?> getPrivateKey() async {
    return await _storage.read(key: 'private_key');
  }

  Future<String?> getRecoveryPhrase() async {
    return await _storage.read(key: 'recovery_phrase');
  }
}
