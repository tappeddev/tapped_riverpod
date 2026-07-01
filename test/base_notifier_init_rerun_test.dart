import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:test/test.dart';

void main() {
  test(
    "ref.watch in init causes init to re-run when watched provider changes",
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(_watchNotifierProvider.notifier);

      expect(notifier.initCallCount, 1);
      expect(container.read(_watchNotifierProvider), 0);

      container.read(_counterProvider.notifier).state = 1;
      // Allow rebuild to propagate.
      await Future<void>.delayed(Duration.zero);

      expect(container.read(_watchNotifierProvider), 1);
      expect(
        notifier.initCallCount,
        2,
        reason: "init should re-run when a watched provider changes",
      );
    },
  );

  test(
    "ref.listen in init does NOT cause init to re-run; only the callback is invoked",
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(_listenNotifierProvider.notifier);

      expect(notifier.initCallCount, 1);
      expect(notifier.listenCallbackCount, 0);

      container.read(_counterProvider.notifier).state = 1;
      await Future<void>.delayed(Duration.zero);

      expect(
        notifier.initCallCount,
        1,
        reason: "init should NOT re-run when a listened provider changes",
      );
      expect(
        notifier.listenCallbackCount,
        1,
        reason: "The listen callback should be invoked instead",
      );

      container.read(_counterProvider.notifier).state = 2;
      await Future<void>.delayed(Duration.zero);

      expect(notifier.initCallCount, 1);
      expect(notifier.listenCallbackCount, 2);
    },
  );
}

final _counterProvider = NotifierProvider<_CounterNotifier, int>(
  () => _CounterNotifier(),
);

class _CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;
}

final _watchNotifierProvider = NotifierProvider<_WatchNotifier, int>(
  () => _WatchNotifier(),
);

class _WatchNotifier extends BaseNotifier<int> {
  int initCallCount = 0;

  @override
  int init() {
    initCallCount++;
    return ref.watch(_counterProvider);
  }
}

final _listenNotifierProvider = NotifierProvider<_ListenNotifier, int>(
  () => _ListenNotifier(),
);

class _ListenNotifier extends BaseNotifier<int> {
  int initCallCount = 0;
  int listenCallbackCount = 0;

  @override
  int init() {
    initCallCount++;
    ref.listen<int>(_counterProvider, (_, _) {
      listenCallbackCount++;
    });
    return 0;
  }
}
