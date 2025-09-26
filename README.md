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
- ✅ Cancel operations by identifier
- ✅ Auto-cleanup when the provider is disposed

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
