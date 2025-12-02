import 'package:tapped_riverpod/tapped_riverpod.dart';

/// A `Notifier` that listens to an inner `Result<I>` provider and exposes a
/// mapped value of type `T?`, ignoring any updates where the mapping returns `null`.
///
/// This is useful when you want to react only to a subset of `Result` updates,
/// e.g. only when the result is a `ResultSuccess` with valid data.
///
/// The notifier:
/// - Subscribes to the given `result` provider.
/// - Applies the `filterMap` function to each incoming `Result<I>`.
/// - Updates its `state` **only** when `filterMap` returns a non-null value.
/// - Keeps the previous state when the mapping result is `null`.
///
/// The initial state is computed by applying `filterMap` to the current value of
/// the `result` provider at build time.
///
/// Example:
/// ```dart
/// final myNotifier = NotifierProvider(
///   () => ResultFilterNotNullNotifier<String, int>(
///     result: someResultProvider,
///     filterMap: (result) {
///       if (result is ResultSuccess<String>) {
///         return int.tryParse(result.value); // only update when parsing works
///       }
///       return null;
///     },
///   ),
/// );
/// ```
///
/// In this example, the notifier exposes `int?` values derived from successful
/// results, but ignores failures and unparseable strings.
class ResultFilterNotNullNotifier<I, T> extends Notifier<T?> {
  final ProviderListenable<Result<I>> _inner;
  final T? Function(Result<I>) _filterMap;

  ResultFilterNotNullNotifier({
    required ProviderListenable<Result<I>> result,
    required T? Function(Result<I>) filterMap,
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
