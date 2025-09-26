import 'dart:async' show Completer, unawaited;

import 'package:async/async.dart' show CancelableOperation;
import 'package:riverpod/riverpod.dart';
import 'package:tapped_riverpod/src/result.dart';
import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:test/test.dart';

void main() {
  test("dispose should cancel all active operations", () async {
    final testNotifierProvider = NotifierProvider<_BaseTestNotifier, String>(
          () => _BaseTestNotifier(),
    );

    final container = ProviderContainer();

    final notifier = container.read(testNotifierProvider.notifier);

    notifier.doAsyncOperation();

    expect(notifier.operations.values.single.isCanceled, false);

    container.invalidate(testNotifierProvider);

    await Future<void>.delayed(Duration.zero);

    expect(notifier.operations.isEmpty, true);
  });

  test("runCatching should cancel the previous actions", () async {
    final notifier = _BaseTestNotifier();

    Result<int> actualResult = const ResultInitial();

    bool initialSuccessCalled = false;

    unawaited(
      notifier.runCatching<int>(
            () async {
          await Future<void>.delayed(const Duration(milliseconds: 500));

          return 1;
        },
        identifier: "test",
        setState: (result) {
          if (result.isSuccess) {
            // ⚠️ This should never be called !
            initialSuccessCalled = true;
          }

          actualResult = result;
        },
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(actualResult, const ResultLoading<int>());

    await notifier.runCatching<int>(
          () async {
        await Future<void>.delayed(const Duration(milliseconds: 100));

        return 2;
      },
      identifier: "test",
      setState: (result) {
        actualResult = result;
      },
    );

    await Future<void>.delayed(const Duration(seconds: 1));

    expect(initialSuccessCalled, false);

    expect(actualResult, const ResultSuccess(2));
  });

  test(
    "a canceled runCatching should never call setState or onSuccess",
        () async {
      final notifier = _BaseTestNotifier();

      Result<int> actualResult = const ResultInitial();

      unawaited(
        notifier.runCatching<int>(
              () async {
            await Future<void>.delayed(const Duration(seconds: 2));

            return 1;
          },
          identifier: "test",
          setState: (result) {
            if (result.isSuccess) {
              throw Exception("Should not be called ");
            }

            actualResult = result;
          },
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      notifier.cancelRunCatchingBy(identifier: "test");

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(actualResult, const ResultLoading<int>());
      expect(notifier.operations, <String, CancelableOperation<void>>{});
    },
  );
}

class _BaseTestNotifier extends BaseNotifier<String> {
  CancelableOperation<void>? asyncOperation;

  @override
  String init() => "";

  void doAsyncOperation() {
    asyncOperation = createOperation(Completer<void>().future);
  }
}
