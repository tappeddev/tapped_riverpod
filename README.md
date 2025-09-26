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
      ref: master
```
