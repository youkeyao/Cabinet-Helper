import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'btutil.dart';

class BTPage extends StatefulWidget{
  const BTPage({ Key? key }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BTPageState();
  }
}

class BTPageState extends State<BTPage>{
  Set<BluetoothDevice> devices = {};
  String status = BtUtil.btdevice == null ? '未连接' : '已连接';

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
      body: ListView(
        children: devices.map((d) => TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 18,horizontal: 15)),
            foregroundColor: MaterialStateProperty.all(d == BtUtil.btdevice ? Colors.blue : Colors.grey),
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BtUtil.flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        setState(() {
          devices.add(r.device);
        });
      }
    });
    scanDevice();
  }

  void scanDevice() {
    setState(() {
      devices.clear();
      if (BtUtil.btdevice != null) devices.add(BtUtil.btdevice!);
    });
    BtUtil.scanDevice();
  }

  void pressDevice(BluetoothDevice d) async {
    setState(() {
      status = '连接中';
    });
    if (d == BtUtil.btdevice) {
      await BtUtil.disconnectDevice(d);
    }
    else {
      await BtUtil.connectDevice(d);
    }
    setState(() {
      if (BtUtil.btdevice != null) {
        status = '已连接';
      }
      else {
        status = '未连接';
      }
    });
    scanDevice();
  }
}