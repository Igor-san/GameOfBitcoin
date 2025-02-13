// shared.dart
//export 'found_web.dart';

export 'found_unsupported.dart'
    if (dart.library.ffi) 'found_native.dart'
    if (dart.library.js_interop) 'found_web.dart';



