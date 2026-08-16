import 'package:flutter/material.dart';

import '../services/app_lock_service.dart';
import '../services/wallet_service.dart';
import 'pin_lock_screen.dart';

class AppStartupScreen extends StatefulWidget {
  final Widget welcomeScreen;
  final Widget homeScreen;

  const AppStartupScreen({
    super.key,
    required this.welcomeScreen,
    required this.homeScreen,
  });

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> {
  final WalletService _walletService = WalletService();
  final AppLockService _appLockService = AppLockService();

  @override
  void initState() {
    super.initState();
    _checkWallet();
  }

  Future<void> _checkWallet() async {
    try {
      final address = await _walletService.getAddress();

      if (!mounted) return;

      if (address == null || address.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => widget.welcomeScreen,
          ),
        );
        return;
      }

      final hasPin = await _appLockService.hasPin();

      if (!mounted) return;

      if (hasPin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => _WalletWithLockScreen(
              homeScreen: widget.homeScreen,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => _WalletWithoutPinScreen(
              homeScreen: widget.homeScreen,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.welcomeScreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _WalletWithLockScreen extends StatefulWidget {
  final Widget homeScreen;

  const _WalletWithLockScreen({
    required this.homeScreen,
  });

  @override
  State<_WalletWithLockScreen> createState() =>
      _WalletWithLockScreenState();
}

class _WalletWithLockScreenState extends State<_WalletWithLockScreen> {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _openLock();
  }

  Future<void> _openLock() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PinLockScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _unlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return widget.homeScreen;
  }
}

class _WalletWithoutPinScreen extends StatelessWidget {
  final Widget homeScreen;

  const _WalletWithoutPinScreen({
    required this.homeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return homeScreen;
  }
}
