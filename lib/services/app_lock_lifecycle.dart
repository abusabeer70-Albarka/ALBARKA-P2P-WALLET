import 'package:flutter/widgets.dart';

class AppLockLifecycle with WidgetsBindingObserver {
  final VoidCallback onBackground;
  final VoidCallback onForeground;

  AppLockLifecycle({
    required this.onBackground,
    required this.onForeground,
  });

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      onBackground();
    }

    if (state == AppLifecycleState.resumed) {
      onForeground();
    }
  }
}
