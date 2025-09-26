class DisplayableError {
  final Object exception;
  final StackTrace stackTrace;

  DisplayableError({required this.exception, required this.stackTrace});

  @override
  String toString() {
    return 'DisplayableError{exception: $exception, stackTrace: $stackTrace}';
  }
}
