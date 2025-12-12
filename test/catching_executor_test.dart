import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:test/test.dart';

void main() {
  test("OperationErrorLogger.logError should be called", () async {
    bool errorLogged = false;

    final logger = _CallbackErrorLogger(onLog: (err) => errorLogged = true);

    //TODO
    final executor = CatchingExecutor(errorLogger: logger, type:);

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
