import 'dart:async' show Completer, unawaited;

import 'package:async/async.dart' show CancelableOperation;
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
    "when the same action is called twice, the second call's Future completes with the second result",
    () async {
      final container = ProviderContainer();

      final notifier = container.read(_testNotifierProvider.notifier);

      final identifier = "test";

      bool secondActionStarted = false;

      unawaited(
        notifier.runCatching<int>(
          () async {
            await Future<void>.delayed(const Duration(seconds: 2));

            return 1;
          },
          identifier: identifier,
          setState: (result) {
            expect(
              secondActionStarted,
              false,
              reason:
                  "After second action started, this should not be called, because the first action is not completed",
            );
          },
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final secondResult = await notifier.runCatching<int>(
        () async {
          secondActionStarted = true;
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return 2;
        },
        identifier: identifier,
        setState: (_) {},
      );

      await Future<void>.delayed(const Duration(seconds: 5));

      expect(secondResult, 2);
    },
  );

  test(
    "OperationErrorLogger.logOperationCanceled should be called when action is cancelled or overridden",
    () async {
      int operationCanceledCounter = 0;

      final container = ProviderContainer(
        overrides: [
          BaseNotifier.logger.overrideWithValue(
            _CallbackOperationLogger(
              onLogOperationCanceled: (type, id) {
                expect(
                  type,
                  _BaseTestNotifier,
                  reason: "The type should be correct",
                );

                expect(id, "test", reason: "The id should be correct");

                operationCanceledCounter++;
              },
            ),
          ),
        ],
      );

      final notifier = container.read(_testNotifierProvider.notifier);

      unawaited(
        notifier.runCatching<int>(
          () async {
            await Future<void>.delayed(const Duration(seconds: 2));

            fail('Cancelled operation should not run to completion');
          },
          identifier: "test",
          setState: (result) {},
        ),
      );

      notifier.cancelOperationBy(identifier: "test");

      expect(operationCanceledCounter, 1);

      await Future<void>.delayed(Duration.zero);

      unawaited(
        notifier.runCatching<int>(
          () async {
            await Future<void>.delayed(const Duration(seconds: 2));

            fail('Superseded operation should not run to completion');
          },
          identifier: "test",
          setState: (result) {},
        ),
      );

      await notifier.runCatching<int>(
        () async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return 2;
        },
        identifier: "test",
        setState: (result) {},
      );

      expect(operationCanceledCounter, 2);
    },
  );

  test(
    "OperationErrorLogger.logError should be called when error occur",
    () async {
      String? emittedError;
      Type? notifierType;
      String? requestId;

      final container = ProviderContainer(
        overrides: [
          BaseNotifier.logger.overrideWithValue(
            _CallbackOperationLogger(
              onLogError: (err, type, id) {
                emittedError = err.exception.toString();
                notifierType = type;
                requestId = id;
              },
            ),
          ),
        ],
      );

      final notifier = container.read(_testNotifierProvider.notifier);

      await notifier.runCatching<int>(
        () async {
          await Future<void>.delayed(const Duration(milliseconds: 23));

          throw Exception("Expected error");
        },
        setState: (result) {},
        identifier: "my-task",
      );

      expect(emittedError, isNotEmpty);
      expect(notifierType, _BaseTestNotifier().runtimeType);
      expect(requestId, "my-task");
    },
  );

  test(
    "OperationErrorLogger.logError should not be called when no error occur",
    () async {
      String? emittedError;

      final container = ProviderContainer(
        overrides: [
          BaseNotifier.logger.overrideWithValue(
            _CallbackOperationLogger(
              onLogError: (err, _, _) =>
                  emittedError = err.exception.toString(),
            ),
          ),
        ],
      );

      final notifier = container.read(_testNotifierProvider.notifier);

      await notifier.runCatching<int>(
        () async {
          await Future<void>.delayed(const Duration(milliseconds: 23));

          return 0;
        },
        setState: (result) {},
        identifier: "my-task",
      );

      expect(emittedError, isNull);
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

class _CallbackOperationLogger extends OperationLogger {
  final void Function(
    DisplayableError error,
    Type providerType,
    String identifier,
  )?
  onLogError;

  final void Function(Type providerType, String identifier)?
  onLogOperationCanceled;

  _CallbackOperationLogger({this.onLogError, this.onLogOperationCanceled});

  @override
  void logError(DisplayableError error, Type providerType, String identifier) {
    onLogError?.call(error, providerType, identifier);
  }

  @override
  void logOperationCanceled(Type providerType, String identifier) {
    onLogOperationCanceled?.call(providerType, identifier);
  }
}
