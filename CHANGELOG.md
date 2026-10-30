## 1.2.1

### Fixed

* `runCatching` no longer hangs when its operation is canceled. Previously, awaiting a
  `runCatching` call that was canceled (or replaced by a newer call with the same
  identifier) never completed. It now returns `null` and leaves the state unchanged.
* `runCatching` no longer throws an `UnmountedRefException` when it is called after the
  notifier has been disposed. It now returns `null` right away.

## 0.0.1

* Initial version of the package 
