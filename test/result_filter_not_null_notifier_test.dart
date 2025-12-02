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
      testName: "initial value should be correct if there is none",
      initialState: ResultInitial(),
      fireUpdated: (_) {},
      expectedOutputs: [],
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

  test("Map data with different generic types", () {
    final inner = NotifierProvider(() => _TestBaseNotifier(ResultInitial()));

    final provider = NotifierProvider(
      () => ResultFilterNotNullNotifier<String, bool>(
        result: inner,
        filterMap: (r) =>
            r.mapOrNull(success: (d) => true, initial: (_) => false),
      ),
    );

    final container = ProviderContainer();

    addTearDown(container.dispose);

    final events = <bool?>[];

    container.listen<bool?>(
      provider,
      (previous, next) => events.add(next),
      fireImmediately: true,
    );

    container.read(inner.notifier).setResult(ResultLoading());
    container
        .read(inner.notifier)
        .setResult(
          Result.failure(
            DisplayableError(
              exception: Exception("Expected error"),
              stackTrace: StackTrace.current,
            ),
          ),
        );

    container.read(inner.notifier).setResult(ResultSuccess("Logged in"));

    expect(events, [false, true]);
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
      () => ResultFilterNotNullNotifier<String, String>(
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
