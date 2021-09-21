import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
class BtUtil{
  static String name = "";
  static String id = "";
  static List uuid = [];
  static final flutterReactiveBle = FlutterReactiveBle();

  static Future connectDevice(DiscoveredDevice d) async {
    

    return true;
  }

  static Future disconnectDevice(DiscoveredDevice d) async {
    return true;
  }
}