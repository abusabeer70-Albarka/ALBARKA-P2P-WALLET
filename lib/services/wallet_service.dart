import 'dart:math';
import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';

class WalletService {
  final _storage = const FlutterSecureStorage();

  Future<String> createWallet() async {
    final random = Random.secure();

    final privateKeyBytes = Uint8List.fromList(
      List<int>.generate(
        32,
        (_) => random.nextInt(256),
      ),
    );

    final credentials = EthPrivateKey(privateKeyBytes);

    final address = await credentials.address;

    await _storage.write(
      key: 'private_key',
      value: credentials.privateKeyInt.toRadixString(16).padLeft(64, '0'),
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
}
