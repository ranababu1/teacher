import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live device network connectivity — reflects the OS-reported network
/// interface state (WiFi/mobile/ethernet vs none), not confirmed internet
/// reachability. A device connected to a WiFi network with no working
/// upstream internet still reports connected here — the "Test AI
/// Connection" action in Settings is what actually confirms the selected
/// AI provider itself is reachable. Emits the current state immediately,
/// then live updates.
final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});

/// Whether the device currently has any network connection.
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider).valueOrNull;
  if (status == null) return true; // avoid flashing "offline" before the first check resolves
  return status.any((result) => result != ConnectivityResult.none);
});
