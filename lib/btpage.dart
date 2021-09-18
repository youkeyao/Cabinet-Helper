import 'package:flutter/material.dart';

class BTPage extends StatefulWidget{
  const BTPage({ Key? key }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BTPageState();
  }
}

class BTPageState extends State<BTPage>{
  List<String> devices = ['hello', 'world'];
  List<String> addrs = ['127.0.0.1', '192.168.1.1'];
  String _addr = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text('蓝牙'),
      ),
      body: Column(
        children: devices.asMap().keys.map((i) => TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 18,horizontal: 0)),
            foregroundColor: _addr == addrs[i] ? MaterialStateProperty.all(Colors.blue) : MaterialStateProperty.all(Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(devices[i], style: const TextStyle(fontSize: 18.0,),),
              Text(addrs[i], style: const TextStyle(fontSize: 18.0,),),
            ],
          ),
          onPressed: () => {},
        )).toList(),
      ),
    );
  }
}