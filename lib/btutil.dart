import 'package:flutter_blue/flutter_blue.dart';
class BtUtil{
  static BluetoothDevice? btdevice;
  static FlutterBlue flutterBlue = FlutterBlue.instance;
  static BluetoothCharacteristic? btcha;

  static void scanDevice() {
    flutterBlue.startScan(timeout: const Duration(seconds: 2));
    flutterBlue.stopScan();
  }

  static Future connectDevice(BluetoothDevice d) async {
    await d.connect(autoConnect: false, timeout: const Duration(seconds: 10));
    btdevice = d;

    List<BluetoothService> services = await d.discoverServices();
    services.map((service) {
      if (service.uuid.toString().toUpperCase().substring(4, 8) == "FFF0") {
        List<BluetoothCharacteristic> characteristics = service.characteristics;
        characteristics.map((characteristic) {
          var valuex = characteristic.uuid.toString();
          print("所有特征值 --- $valuex");
          if (service.uuid.toString().toUpperCase().substring(4, 8) == 'FFF1') {
            print("匹配到正确的特征值");
            
            btcha = characteristic;
          }
        });
      }
    });
    await btcha?.setNotifyValue(true);
    btcha?.value.listen((value) {
      print('hello'+value.toString());
    });

    return true;
  }

  static Future disconnectDevice(BluetoothDevice d) async {
    await d.disconnect();
    btdevice = null;
    return true;
  }
}