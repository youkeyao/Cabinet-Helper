import 'package:flutter_blue/flutter_blue.dart';

class CommonVariable{
  static FlutterBlue flutterBlue = FlutterBlue.instance;
  static BluetoothState? btstate;
  static BluetoothDevice? btdevice;
  static BluetoothCharacteristic? btcha;
  static List<String> tags = ['空', '空', '空'];
}