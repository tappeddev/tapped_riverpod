import 'package:tapped_riverpod/tapped_riverpod.dart';

/// A [BaseNotifier] that executes [fetch] via [load].
///
/// The fetch does not run automatically — call [load] when you are ready
/// (e.g. on button press or in `initState`).
///
/// Example:
/// ```dart
/// final provRemoteConfigLoader =
///     NotifierProvider<CallbackResultNotifier<RemoteConfig>, Result<RemoteConfig>>(
///   () => CallbackResultNotifier(
///     fetch: (ref) => ref.read(provRemoteConfigService).getConfiguration(),
///   ),
/// );
///
/// ref.watch(provRemoteConfigLoader);
/// ref.read(provRemoteConfigLoader.notifier).load();
/// ```
class CallbackResultNotifier<T> extends BaseNotifier<Result<T>> {
  CallbackResultNotifier({required Future<T> Function(Ref ref) fetch})
    : _fetch = fetch;

  final Future<T> Function(Ref ref) _fetch;

  @override
  Result<T> init() => ResultInitial<T>();

  /// Runs [_fetch] and updates [state] with loading, success, or failure.
  Future<T?> load() {
    return runCatching(
      () => _fetch(ref),
      identifier: 'load',
      setState: (result) => state = result,
    );
  }
}
