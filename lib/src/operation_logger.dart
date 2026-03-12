import 'package:tapped_riverpod/src/error/displayble_error.dart';

abstract class OperationLogger {
  void logOperationCanceled(Type providerType, String identifier);

  void logError(DisplayableError error, Type providerType, String identifier);
}
