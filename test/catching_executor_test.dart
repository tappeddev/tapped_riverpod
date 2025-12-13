import 'dart:async';

import 'package:async/async.dart' hide Result;
import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:test/test.dart';

void main() {
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

  test("OperationErrorLogger.logError should be called", () async {
    bool errorLogged = false;

    final logger = _CallbackErrorLogger(onLog: (err) => errorLogged = true);

    final executor = CatchingExecutor(
      errorLogger: logger,
      type: logger.runtimeType,
    );

    await executor.execute<int>(
      identifier: "my-task",
      task: () async {
        await Future.delayed(const Duration(milliseconds: 23));

        throw Exception("Expected error");
      },
      setState: (result) {},
    );

    expect(errorLogged, true);
  });
}

class _CallbackErrorLogger extends OperationErrorLogger {
  final void Function(DisplayableError error) onLog;

  _CallbackErrorLogger({required this.onLog});

  @override
  void logError(DisplayableError error, Type runtimeType, String identifier) {
    onLog(error);
  }
}

final _testNotifierProvider = NotifierProvider<_BaseTestNotifier, String>(
  () => _BaseTestNotifier(),
);

class _BaseTestNotifier extends BaseNotifier<String> {
  @override
  String init() => "";
}
