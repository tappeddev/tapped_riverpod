import 'package:tapped_riverpod/src/result_filter_not_null_notifier.dart';
import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('ResultFilterNotNullNotifier', () {
    _test(
      testName: "initial value should be correct",
      initialState: ResultSuccess("Initial-Data"),
      fireUpdated: (_) {},
      expectedOutputs: ["Initial-Data"],
    );

    _test(
      testName: "should not change state when filterMap returns null",
      initialState: ResultSuccess("Initial-Data"),
      fireUpdated: (prov) {
        prov
          ..setResult(Result.loading())
          ..setResult(
            Result.failure(
              DisplayableError(
                exception: Exception("Expected error"),
                stackTrace: StackTrace.current,
              ),
            ),
          );
      },
      expectedOutputs: ["Initial-Data"],
    );

    _test(
      testName: "should not change state when same value is reported again",
      initialState: ResultSuccess("Data"),
      fireUpdated: (prov) {
        prov
          ..setResult(Result.success("Data"))
          ..setResult(Result.success("Data"));
      },
      expectedOutputs: ["Data"],
    );

    _test(
      testName: "should emit changes",
      initialState: ResultSuccess("Initial-Data"),
      fireUpdated: (provider) {
        provider
          ..setResult(Result.loading())
          ..setResult(Result.success("Data-2"))
          ..setResult(Result.loading())
          ..setResult(Result.success("Data-3"))
          ..setResult(Result.success("Data-3"))
          ..setResult(Result.loading())
          ..setResult(Result.success("Data-4"));
      },
      expectedOutputs: ["Initial-Data", "Data-2", "Data-3", "Data-4"],
    );
  });
}

void _test({
  required String testName,
  required Result<String> initialState,
  required void Function(_TestBaseNotifier prov) fireUpdated,
  required List<String?> expectedOutputs,
}) {
  test(testName, () {
    final inner = NotifierProvider(() => _TestBaseNotifier(initialState));

    final provider = NotifierProvider(
      () => ResultFilterNotNullNotifier<String>(
        result: inner,
        filterMap: (r) => r.whenOrNull(success: (v) => v),
      ),
    );

    final container = ProviderContainer();

    addTearDown(container.dispose);

    final events = <String?>[];

    container.listen<String?>(
      provider,
      (previous, next) => events.add(next),
      fireImmediately: true,
    );

    fireUpdated(container.read(inner.notifier));

    expect(events, expectedOutputs);
  });
}

class _TestBaseNotifier extends BaseNotifier<Result<String>> {
  final Result<String> _initial;

  _TestBaseNotifier(this._initial);

  @override
  Result<String> init() => _initial;

  void setResult(Result<String> result) {
    state = result;
  }
}
