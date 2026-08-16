import 'package:flutter/material.dart';

import '../services/app_lock_service.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final AppLockService _appLockService = AppLockService();
  final TextEditingController _pinController = TextEditingController();

  bool _loading = false;
  bool _hidePin = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final pin = _pinController.text.trim();

    if (pin.length != 6 || int.tryParse(pin) == null) {
      _showMessage('Enter your 6-digit PIN.');
      return;
    }

    setState(() => _loading = true);

    try {
      final valid = await _appLockService.verifyPin(pin);

      if (!mounted) return;

      if (valid) {
        Navigator.pop(context, true);
      } else {
        _pinController.clear();
        _showMessage('Incorrect PIN. Try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Unable to verify PIN.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 70),
              const Icon(
                Icons.lock,
                size: 80,
              ),
              const SizedBox(height: 28),
              const Text(
                'Wallet Locked',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter your 6-digit PIN to unlock ALBARKA P2P WALLET.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _pinController,
                obscureText: _hidePin,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _unlock(),
                decoration: InputDecoration(
                  labelText: '6-Digit PIN',
                  prefixIcon: const Icon(Icons.pin),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _hidePin = !_hidePin);
                    },
                    icon: Icon(
                      _hidePin
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _unlock,
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Unlock Wallet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
