import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';

class WalletService {
  final _storage = const FlutterSecureStorage();

  Future<String> createWallet() async {
    final random = Random.secure();

    final privateKeyBytes = List<int>.generate(
      32,
      (_) => random.nextInt(256),
    );

    final credentials = EthPrivateKey(privateKeyBytes);

    final address = await credentials.extractAddress();

    await _storage.write(
      key: 'private_key',
      value: credentials.privateKeyInt.toRadixString(16),
    );

    await _storage.write(
      key: 'wallet_address',
      value: address.hex,
    );

    return address.hex;
  }

  Future<String?> getAddress() async {
    return await _storage.read(key: 'wallet_address');
  }

  Future<String?> getPrivateKey() async {
    return await _storage.read(key: 'private_key');
  }
}
