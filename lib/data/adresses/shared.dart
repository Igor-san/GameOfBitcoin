// shared.dart
//export 'web.dart';
export 'unsupported.dart'
    if (dart.library.ffi) 'native.dart'
    if (dart.library.js_interop) 'web.dart';


