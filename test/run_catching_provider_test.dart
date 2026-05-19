import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:test/test.dart';

NotifierProvider<RunCatchingNotifier<T>, Result<T>> _provider<T>(
  Future<T> Function(Ref ref) fetch,
) {
  return NotifierProvider(() => RunCatchingNotifier(fetch: fetch));
}

void main() {
  test('starts with ResultInitial', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final provider = _provider<int>((_) async => 1);

    expect(container.read(provider), const ResultInitial<int>());
  });

  test('load transitions through loading to success', () async {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final provider = _provider<int>((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return 42;
    });

    final notifier = container.read(provider.notifier);
    final states = <Result<int>>[];

    container.listen(
      provider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );

    await notifier.load();

    expect(states, [
      const ResultInitial<int>(),
      const ResultLoading<int>(),
      const ResultSuccess(42),
    ]);
  });

  test('load transitions to failure on error', () async {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final provider = _provider<int>((_) async => throw Exception('boom'));

    await container.read(provider.notifier).load();

    final result = container.read(provider);
    expect(result.isFailure, true);
    expect(result.asFailureOrNull()?.error.exception, isA<Exception>());
  });

  test('calling load again re-fetches', () async {
    var callCount = 0;

    final container = ProviderContainer();

    addTearDown(container.dispose);

    final provider = _provider<int>((_) async {
      callCount++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return callCount;
    });

    final notifier = container.read(provider.notifier);

    await notifier.load();
    expect(container.read(provider), const ResultSuccess(1));

    await notifier.load();
    expect(container.read(provider), const ResultSuccess(2));
    expect(callCount, 2);
  });

  test('invalidate cancels active load operation', () async {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final provider = _provider<int>((_) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      return 1;
    });

    final notifier = container.read(provider.notifier);

    // ignore: unawaited_futures
    notifier.load();

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(notifier.operations.isNotEmpty, true);

    container.invalidate(provider);

    await Future<void>.delayed(Duration.zero);

    expect(notifier.operations.isEmpty, true);
  });
}
