import 'dart:async' show Completer, unawaited;

import 'package:async/async.dart' show CancelableOperation;
import 'package:riverpod/riverpod.dart';
import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:test/test.dart';

void main() {
  test("invalidate/dispose should cancel all active operations", () async {
    final container = ProviderContainer();

    final notifier = container.read(_testNotifierProvider.notifier);

    notifier.doAsyncOperation();

    expect(notifier.operations.values.single.isCanceled, false);

    container.invalidate(_testNotifierProvider);

    await Future<void>.delayed(Duration.zero);

    expect(notifier.operations.isEmpty, true);
  });

  test(
    "a canceled runCatching should never call setState or onSuccess",
    () async {
      final container = ProviderContainer();

      Result<int> actualResult = const ResultInitial();

      final notifier = container.read(_testNotifierProvider.notifier);

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

      notifier.cancelOperationBy(identifier: "test");

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(actualResult, const ResultLoading<int>());
      expect(notifier.operations, <String, CancelableOperation<void>>{});
    },
  );

  test("invalidate/dispose should cancel all active operations", () async {
    final container = ProviderContainer();

    final notifier = container.read(_testNotifierProvider.notifier);

    notifier.doAsyncOperation();

    expect(notifier.operations.values.single.isCanceled, false);

    container.invalidate(_testNotifierProvider);

    await Future<void>.delayed(Duration.zero);

    expect(notifier.operations.isEmpty, true);
  });

  test("runCatching should cancel the previous actions", () async {
    final container = ProviderContainer();

    final notifier = container.read(_testNotifierProvider.notifier);

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
    "OperationErrorLogger.logError should be called when error occur",
    () async {
      bool errorLogged = false;

      final container = ProviderContainer(
        overrides: [
          BaseNotifier.errorLogger.overrideWithValue(
            _CallbackErrorLogger(onLog: (err) => errorLogged = true),
          ),
        ],
      );

      final notifier = container.read(_testNotifierProvider.notifier);

      await notifier.runCatching<int>(
        () async {
          await Future.delayed(const Duration(milliseconds: 23));

          throw Exception("Expected error");
        },
        setState: (result) {},
        identifier: "my-task",
      );

      expect(errorLogged, true);
    },
  );

  test(
    "OperationErrorLogger.logError should not be called when no error occur",
    () async {
      bool errorLogged = false;

      final container = ProviderContainer(
        overrides: [
          BaseNotifier.errorLogger.overrideWithValue(
            _CallbackErrorLogger(onLog: (err) => errorLogged = true),
          ),
        ],
      );

      final notifier = container.read(_testNotifierProvider.notifier);

      await notifier.runCatching<int>(
        () async {
          await Future.delayed(const Duration(milliseconds: 23));

          return 0;
        },
        setState: (result) {},
        identifier: "my-task",
      );

      expect(errorLogged, false);
    },
  );
}

final _testNotifierProvider = NotifierProvider<_BaseTestNotifier, String>(
  () => _BaseTestNotifier(),
);

class _BaseTestNotifier extends BaseNotifier<String> {
  CancelableOperation<void>? asyncOperation;

  @override
  String init() => "";

  void doAsyncOperation() {
    asyncOperation = createOperation(Completer<void>().future);
  }
}

class _CallbackErrorLogger extends OperationErrorLogger {
  final void Function(DisplayableError error) onLog;

  _CallbackErrorLogger({required this.onLog});

  @override
  void logError(DisplayableError error, Type runtimeType, String identifier) {
    onLog(error);
  }
}
