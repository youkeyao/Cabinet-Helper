import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'btutil.dart';

class BTPage extends StatefulWidget{
  const BTPage({ Key? key }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BTPageState();
  }
}

class BTPageState extends State<BTPage>{
  List devices = [];
  List ids = [];
  List uuids = [];
  String status = BtUtil.id == "" ? '未连接' : '已连接';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        leading: const Icon(Icons.bluetooth),
        title: Text(status),
        centerTitle: true,
        actions: [IconButton(onPressed: () => write(BtUtil.id, BtUtil.uuid[0]), icon: const Icon(Icons.refresh))],
      ),
      body: ListView(
        children: devices.asMap().keys.map((i) => TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 18,horizontal: 15)),
            foregroundColor: MaterialStateProperty.all(ids[i] == BtUtil.id ? Colors.blue : Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(devices[i] == "" ? 'unknown' : devices[i], style: const TextStyle(fontSize: 18.0,),),
              Text(ids[i], style: const TextStyle(fontSize: 18.0,),),
            ],
          ),
          onPressed: () => pressDevice(devices[i], ids[i], uuids[i]),
        )).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BtUtil.flutterReactiveBle.statusStream.listen((e) {
      print('mmmmmmmmmmmmmmmmmstatus' + e.toString());
    });
    
    scanDevice();
  }

  void scanDevice() {
    setState(() {
      devices.clear();
      ids.clear();
      uuids.clear();
      if (BtUtil.id != "") {
        devices.add(BtUtil.name);
        ids.add(BtUtil.id);
        uuids.add(BtUtil.uuid);
      }
    });
    BtUtil.flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      setState(() {
        if (!ids.contains(device.id)) {
          devices.add(device.name);
          ids.add(device.id);
          uuids.add(device.serviceUuids);
        }
      });
    }, onError: (on) {
      print('scan error');
    });
  }

  void pressDevice(String name, String id, List uuid) {
    BtUtil.flutterReactiveBle.connectToDevice(
      id: id,
      connectionTimeout: const Duration(seconds: 2),
    ).listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connecting) {
        setState(() {
          status = '连接中';
        });
      }
      else if (connectionState.connectionState == DeviceConnectionState.connected) {
        setState(() {
          status = '已连接';
        });
        BtUtil.name = name;
        BtUtil.id = id;
        BtUtil.uuid = uuid;
        scanDevice();
      }
      else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
        setState(() {
          status = '未连接';
        });
        BtUtil.name = "";
        BtUtil.id = "";
      }
    }, onError: (Object error) {
      // handle error
    });
  }

  void write(String id, Uuid uuid) async {
    List<DiscoveredService> serviceList = await BtUtil.flutterReactiveBle.discoverServices(id);
    final characteristic = QualifiedCharacteristic(serviceId: serviceList[0].serviceId, characteristicId: serviceList[0].characteristicIds[0], deviceId: id); 
    await BtUtil.flutterReactiveBle.writeCharacteristicWithResponse(characteristic, value: [65, 66]);
    final response = await BtUtil.flutterReactiveBle.readCharacteristic(characteristic);
    print("response=$response");
  }
}