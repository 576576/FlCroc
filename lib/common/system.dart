import 'dart:io';

bool get isDesktop => !isMobile;
bool get isMobile => Platform.isAndroid || Platform.isIOS;
bool get isAndroid => Platform.isAndroid;
bool get isIOS => Platform.isIOS;
bool get isWindows => Platform.isWindows;
bool get isMacOS => Platform.isMacOS;
bool get isLinux => Platform.isLinux;
