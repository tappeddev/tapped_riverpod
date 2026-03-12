import 'package:tapped_riverpod/src/error/displayble_error.dart';

abstract class OperationLogger {
  void logError(DisplayableError error, Type providerType, String identifier);
}
