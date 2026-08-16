import 'package:flutter/material.dart';

import '../services/app_lock_service.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final AppLockService _appLockService = AppLockService();

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController =
      TextEditingController();

  bool _loading = false;
  bool _hidePin = true;
  bool _hideConfirmPin = true;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmController.text.trim();

    if (pin.length != 6 || int.tryParse(pin) == null) {
      _showMessage('PIN must be exactly 6 digits.');
      return;
    }

    if (pin != confirmPin) {
      _showMessage('PINs do not match.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _appLockService.setPin(pin);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN created successfully.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set App PIN'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.lock_outline,
              size: 72,
            ),
            const SizedBox(height: 24),
            const Text(
              'Create Your PIN',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Create a 6-digit PIN to help protect your wallet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              obscureText: _hidePin,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: _hideConfirmPin,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _savePin(),
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(
                      () => _hideConfirmPin = !_hideConfirmPin,
                    );
                  },
                  icon: Icon(
                    _hideConfirmPin
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
                onPressed: _loading ? null : _savePin,
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create PIN',
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
    );
  }
}
