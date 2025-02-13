// unsupported.dart
import 'found_database.dart';
//FoundSharedDatabase constructFoundDb() => throw UnimplementedError();

Never _unsupported() {
  throw UnsupportedError(
      'No suitable database implementation was found on this platform.');
}

// Depending on the platform the app is compiled to, the following stubs will
// be replaced with the methods in native.dart or web.dart

Future<FoundSharedDatabase> constructFoundDb() async {
  _unsupported();
}
