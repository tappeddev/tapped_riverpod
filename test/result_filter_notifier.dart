import 'package:tapped_riverpod/src/result_filter_notifier.dart';
import 'package:tapped_riverpod/tapped_riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('ResultFilterNotifier', () {
    test('the initial value should be correct ', () {
      final inner = StateProvider<Result<String>>(
        (_) => Result.success("Initial-Success"),
      );

      final provider = NotifierProvider(
        () => ResultFilterNotifier<String>(
          result: inner,
          filterMap: (r) => r.whenOrNull(success: (v) => v),
        ),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final value = container.read(provider);

      expect(value, "Initial-Success");
    });

    test('does not change state when filterMap returns null', () {
      final inner = StateProvider<Result<String>>(
        (_) => Result.success('data'),
      );

      final provider = NotifierProvider(
        () => ResultFilterNotifier<String>(
          result: inner,
          // filterMap returns null always => no updates should be applied after build
          filterMap: (r) => r.whenOrNull(success: (v) => v),
        ),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // initial build => filterMap returns null, initial state should be null
      expect(container.read(provider), "data");

      container.read(inner.notifier).state = Result.loading();
      container.read(inner.notifier).state = Result.failure(
        DisplayableError(
          exception: Exception("Expected error"),
          stackTrace: StackTrace.current,
        ),
      );

      //TODO can check how many times this was called ?
      expect(container.read(provider), "data");
    });

    test('does not change state when filterMap returns the same data again', () {
      final inner = StateProvider<Result<String>>(
        (_) => Result.success('data'),
      );

      final provider = NotifierProvider(
        () => ResultFilterNotifier<String>(
          result: inner,
          // filterMap returns null always => no updates should be applied after build
          filterMap: (r) => r.whenOrNull(success: (v) => v),
        ),
      );

      final container = ProviderContainer();

      addTearDown(container.dispose);

      // initial build => filterMap returns null, initial state should be null
      expect(container.read(provider), "data");

      container.read(inner.notifier).state = Result.success("data");
      container.read(inner.notifier).state = Result.success("data");

      //TODO can check how many times this was called ?
      expect(container.read(provider), "data");
    });

    test(
      'updates state when inner emits success mapping to non-null',
      () async {
        final inner = StateProvider<Result<String>>(
          (_) => Result.success("initial-data"),
        );

        final provider = NotifierProvider(
          () => ResultFilterNotifier<String>(
            result: inner,
            filterMap: (r) => r.whenOrNull(success: (v) => v),
          ),
        );

        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(provider), "initial-data");

        container.read(inner.notifier).state = Result.success("data-2");

        //TODO can check how many times this was called ?
        expect(container.read(provider), "data-2");

        container.read(inner.notifier).state = Result.success("data-3");

        //TODO can check how many times this was called ?
        expect(container.read(provider), "data-3");
      },
    );

    test(
      'updates state when mapped value changed',
          () async {
        final inner = StateProvider<Result<String>>(
              (_) => Result.success("initial-data"),
        );

        final provider = NotifierProvider(
              () => ResultFilterNotifier<String>(
            result: inner,
            filterMap: (r) => r.whenOrNull(success: (v) => v),
          ),
        );

        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(provider), "initial-data");

        container.read(inner.notifier).state = Result.loading();
        container.read(inner.notifier).state = Result.failure(
          DisplayableError(
            exception: Exception("Expected error"),
            stackTrace: StackTrace.current,
          ),
        );
        container.read(inner.notifier).state = Result.loading();
        container.read(inner.notifier).state = Result.success("data-2");

        //TODO can check how many times this was called ?
        expect(container.read(provider), "data-2");


        container.read(inner.notifier).state = Result.loading();
        container.read(inner.notifier).state = Result.failure(
          DisplayableError(
            exception: Exception("Expected error"),
            stackTrace: StackTrace.current,
          ),
        );
        container.read(inner.notifier).state = Result.loading();
        container.read(inner.notifier).state = Result.success("data-3");

        //TODO can check how many times this was called ?
        expect(container.read(provider), "data-3");
      },
    );
  });
}
