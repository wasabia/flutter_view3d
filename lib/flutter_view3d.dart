
import 'dart:async';

import 'package:flutter/services.dart';


export 'widgets/View3D.dart';


class FlutterView3d {
  static const MethodChannel _channel = MethodChannel('flutter_view3d');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
