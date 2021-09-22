import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'common.dart';

class BTPage extends StatefulWidget{
  const BTPage({ Key? key }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BTPageState();
  }
}

class BTPageState extends State<BTPage>{
  Set<BluetoothDevice> devices = {};
  String status = CommonVariable.btdevice == null ? '未连接' : '已连接';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        leading: const Icon(Icons.bluetooth),
        title: Text(status),
        centerTitle: true,
        actions: [IconButton(onPressed: scanDevice, icon: const Icon(Icons.refresh))],
      ),
      body: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.on,
        builder: (c, snapshot) {
          CommonVariable.btstate = snapshot.data;
          if (CommonVariable.btstate == BluetoothState.on) {
            return ListView(
              children: devices.map((d) => TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 18,horizontal: 15)),
                  foregroundColor: MaterialStateProperty.all(d == CommonVariable.btdevice ? Colors.blue : Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d.name == "" ? "unknown" : d.name, style: const TextStyle(fontSize: 18.0,),),
                    Text(d.id.toString(), style: const TextStyle(fontSize: 18.0,),),
                  ],
                ),
                onPressed: () => pressDevice(d),
              )).toList(),
            );
          }
          else {
            return const Center(
              child: Text(
                '未开启蓝牙',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0),
              ),
            );
          }
        }
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    CommonVariable.flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        setState(() {
          devices.add(r.device);
        });
      }
    });
    if (CommonVariable.btstate == BluetoothState.on) {
      scanDevice();
    }
  }

  void scanDevice() {
    setState(() {
      devices.clear();
      if (CommonVariable.btdevice != null) devices.add(CommonVariable.btdevice!);
    });
    CommonVariable.flutterBlue.startScan(timeout: const Duration(seconds: 2));
    CommonVariable.flutterBlue.stopScan();
  }

  void pressDevice(BluetoothDevice d) async {
    d.state.listen((v) {
      switch (v) {
        case BluetoothDeviceState.connected: CommonVariable.btdevice = d; setState(() {status = '已连接';}); break;
        case BluetoothDeviceState.disconnecting: setState(() {status = '断开中';}); break;
        case BluetoothDeviceState.disconnected: CommonVariable.btdevice = null; CommonVariable.btcha = null; setState(() {status = '未连接';}); break;
        default: setState(() {status = v.toString();});
      }
    });
    if (d == CommonVariable.btdevice) {
      await d.disconnect();
    }
    else {
      setState(() {status = '连接中';});
      await CommonVariable.btdevice?.disconnect();
      await d.connect(autoConnect: false, timeout: const Duration(seconds: 10));
      List<BluetoothService> services = await CommonVariable.btdevice!.discoverServices();
      for (var service in services) {
        // print(service.uuid.toString());
        if (service.uuid.toString().substring(4, 8) == 'ffe0') {
          List<BluetoothCharacteristic> characteristics = service.characteristics;
          for (var characteristic in characteristics) {
            // print(characteristic.uuid.toString());
            if (characteristic.uuid.toString().substring(4, 8) == 'ffe1') {
              CommonVariable.btcha = characteristic;
            }
          }
        }
      }
    }
    scanDevice();
  }
}