/// FFI binding for the Go croc bridge shared library.
/// On web, falls back to a stub (FFI not available).
export 'lib_native.dart'
  if (dart.library.html) 'lib_web.dart';
