import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:test/test.dart';

final lifeCycle = <String>[];

void main() {
  setUp(() => lifeCycle.clear());

  test("the lifecycle of the provider should be correct", () async {
    final container = ProviderContainer();

    expect(lifeCycle, []);

    final notifier = container.read(_testNotifierProvider.notifier);

    expect(lifeCycle, ["build", "init"]);

    await notifier.runCatching<int>(
      () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));

        return 1;
      },
      identifier: "test",
      setState: (result) {},
    );

    expect(lifeCycle, ["build", "init"]);

    container.invalidate(_testNotifierProvider);

    expect(lifeCycle, ["build", "init", "onDispose"]);

    // should recreate the provider
    container.read(_testNotifierProvider.notifier);

    expect(lifeCycle, ["build", "init", "onDispose", "build", "init"]);
  });
}

final _testNotifierProvider = NotifierProvider<_BaseTestNotifier, String>(
  () => _BaseTestNotifier(),
);

class _BaseTestNotifier extends BaseNotifier<String> {
  @override
  String build() {
    lifeCycle.add("build");

    return super.build();
  }

  @override
  String init() {
    lifeCycle.add("init");

    return "";
  }

  @override
  void onDispose() {
    lifeCycle.add("onDispose");

    super.onDispose();
  }
}
