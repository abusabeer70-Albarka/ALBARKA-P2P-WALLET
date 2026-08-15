import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransactionHistoryService {
  static const String _storageKey = 'transaction_history';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final data = await _storage.read(key: _storageKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(data);

      if (decoded is List) {
        return List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item)),
        );
      }
    } catch (_) {
      return [];
    }

    return [];
  }

  Future<void> addTransaction({
    required String txHash,
    required String type,
    required String amount,
    required String address,
    required String status,
    String network = 'Sepolia',
  }) async {
    final transactions = await getTransactions();

    transactions.insert(0, {
      'txHash': txHash,
      'type': type,
      'amount': amount,
      'address': address,
      'status': status,
      'network': network,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await _storage.write(
      key: _storageKey,
      value: jsonEncode(transactions),
    );
  }

  Future<void> clearTransactions() async {
    await _storage.delete(key: _storageKey);
  }
}
