// Real-time sync via polling (FR-7.1)
// In production, replace with WebSocket or Server-Sent Events.
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';

class RealtimeSync {
  Timer? _timer;
  final VoidCallback onSync;

  RealtimeSync({required this.onSync});

  void start({Duration interval = const Duration(seconds: 30)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _sync());
  }

  void stop() => _timer?.cancel();

  Future<void> _sync() async {
    try {
      await ApiService.instance.get('/health');
      onSync();
    } catch (_) {}
  }
}
