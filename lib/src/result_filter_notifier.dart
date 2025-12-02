import 'package:tapped_riverpod/tapped_riverpod.dart';

/// A notifier that listens to a `Result<T>` provider and exposes only a
/// *filtered* value of type `T?`.
///
/// This is useful when you have a provider that emits `Result<T>` values
/// (e.g. loading/success/error states), but another part of your UI or logic
/// only cares about the **successful output**, and only when it is meaningful.
///
/// The notifier:
/// - **Subscribes** to the given `result` provider
/// - Applies the `filterMap` function on each new value
/// - **Updates its state only when `filterMap` returns a non-null value`**
/// - Returns the filtered value initially by calling `filterMap` on the current state
///
/// This prevents unnecessary updates when the result is not relevant.
///
/// ---
/// ## Example
///
/// Imagine you have a provider that loads legal information:
///
/// ```dart
/// final provAgreeLegalInfo = NotifierProvider<LegalInfoNotifier, LegalInfoState>(
///   () => LegalInfoNotifier(),
/// );
/// ```
///
/// The state contains:
/// ```dart
/// class LegalInfoState {
///   final Result<bool?> agreeResult;
///   LegalInfoState(this.agreeResult);
/// }
/// ```
///
/// You only want to expose the **successful agreeResult**, ignoring loading or errors.
///
/// ```dart
/// final provAgreeResult = NotifierProvider(
///   () => ResultFilterNotifier<bool?>(
///     result: provAgreeLegalInfo.select((s) => s.agreeResult),
///     filterMap: (result) => result.whenOrNull(
///       success: (value) => value,   // Only emit when success
///     ),
///   ),
/// );
/// ```
class ResultFilterNotifier<T> extends Notifier<T?> {
  final ProviderListenable<Result<T>> _inner;
  final T? Function(Result<T>) _filterMap;

  ResultFilterNotifier({
    required ProviderListenable<Result<T>> result,
    required T? Function(Result<T>) filterMap,
  }) : _inner = result,
       _filterMap = filterMap;

  @override
  T? build() {
    final sub = ref.container.listen(_inner, (previous, current) {
      final newState = _filterMap(current);
      if (newState == null) return;
      state = newState;
    });

    ref.onDispose(sub.close);

    return _filterMap(ref.read(_inner));
  }
}
