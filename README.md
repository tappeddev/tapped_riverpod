# Tapped extensions for Riverpod 🚀

`BaseNotifier` is an abstract class for building custom [`riverpod`](https://pub.dev/packages/riverpod) notifiers with
built-in support for:

- Cancelable async operations
- Standardized error handling via `DisplayableError`
- Unified `Result<T>` states (`Loading`, `Success`, `Failure`)
- Automatic cleanup of running operations on dispose

It simplifies asynchronous state management in Riverpod by providing safe cancellation, consistent error handling, and a
clear pattern for loading and result states.

---

## Features

- ✅ Manage async tasks with `CancelableOperation`
- ✅ Run cancellable operations with `runCatching`
- ✅ Declarative async providers with `RunCatchingNotifier`
- ✅ Cancel operations by identifier
- ✅ Auto-cleanup when the provider is disposed

---

## `RunCatchingNotifier`

Use `RunCatchingNotifier` for simple async fetches with `Result<T>`, without writing a custom notifier class.

The fetch does **not** run automatically — you decide when to call `.load()` (e.g. on screen init or button press).

```dart
final provRemoteConfigLoader =
    NotifierProvider<RunCatchingNotifier<RemoteConfig>, Result<RemoteConfig>>(
  () => RunCatchingNotifier(
    fetch: (ref) => ref.read(provRemoteConfigService).getConfiguration(),
  ),
);

class RemoteConfigScreen extends ConsumerStatefulWidget {
  const RemoteConfigScreen({super.key});

  @override
  ConsumerState<RemoteConfigScreen> createState() => _RemoteConfigScreenState();
}

class _RemoteConfigScreenState extends ConsumerState<RemoteConfigScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(provRemoteConfigLoader.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(provRemoteConfigLoader);

    return result.when(
      initial: (_) => const SizedBox.shrink(),
      loading: (_) => const CircularProgressIndicator(),
      success: (config) => Text(config.someValue),
      failure: (error, _) => Text(error.toMessage(context)),
    );
  }
}
```

Reload:

```dart
ref.read(provRemoteConfigLoader.notifier).load();
```

Compared to a manual `BaseNotifier`, you do not need to create a class yourself.

---

## Installation

```yaml
dependencies:
  tapped_riverpod:
    git:
      url: https://github.com/tappeddev/tapped_riverpod.git
      ref: main
```

## Custom Error Mapping

To display user-friendly error messages based on different exception types, you can implement a **custom mapping** using
an extension on `DisplayableError`:

```dart
extension DisplayableErrorExtension on DisplayableError {
  String toMessage(BuildContext context) {
    final i18n = I18.of(context);
    final exception = this.exception;

    // Example: Mapping for Appwrite errors
    if (exception is AppwriteException) {
      if (exception.type == "user_already_exists") {
        return i10n.auth_register_user_exists_error;
      }
      if ([
        "user_invalid_credentials",
        "general_argument_invalid",
      ].contains(exception.type)) {
        return i10n.auth_login_invalid_credentials;
      }
    }

    // Fallback for unknown errors
    return i10n.error_something_went_wrong;
  }
}
```
