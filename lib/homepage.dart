import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'common.dart';

void copyArray(List sour, List dst) {
  for (int i = 0; i < sour.length; i ++) {
    dst[i] = sour[i];
  }
}

class TagDialog extends AlertDialog {
  const TagDialog({ Key? key, required contentWidget }) : super(
    key: key,
    content: contentWidget,
    contentPadding: EdgeInsets.zero,
  );
}

class TagWidget extends StatefulWidget {
  const TagWidget({ Key? key }) : super(key: key);

  @override
  _TagWidgetState createState() => _TagWidgetState();
}

class _TagWidgetState extends State<TagWidget> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      alignment: Alignment.center,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Tag',
              style: TextStyle(fontSize: 22, color: Colors.blue),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
              controller: controller,
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                )
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop("");
                },
                child: const Text(
                  'cancel',
                  style: TextStyle(fontSize: 22, color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                },
                child: const Text(
                  'ok',
                  style: TextStyle(fontSize: 22, color: Colors.blue),
                )
              ),
            ],
          ),
        ],
      )
    );
  }
}

class ControlButton extends StatelessWidget {
  const ControlButton({ Key? key, required this.index, required this.tag, required this.press, required this.color}) : super(key: key);
  final int index;
  final Text tag;
  final Function press;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(color),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(index.toString(), style: const TextStyle(fontSize: 30.0,),),
              tag
            ]
          ),
          onPressed: () => press(index),
        ),
      )
    );
  }
}

class HomePage extends StatefulWidget{
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage>{
  List<String> tags = ['空', '空', '空'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text('控制'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ControlButton(index: 1, tag: Text(tags[0]), press: press, color: tags[0] == '空' ? Colors.lightGreen : Colors.red,),
            ControlButton(index: 2, tag: Text(tags[1]), press: press, color: tags[1] == '空' ? Colors.lightGreen : Colors.red,),
            ControlButton(index: 3, tag: Text(tags[2]), press: press, color: tags[2] == '空' ? Colors.lightGreen : Colors.red,),
          ], 
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    copyArray(CommonVariable.tags, tags);
    CommonVariable.btcha?.write([48], withoutResponse: true);
    CommonVariable.btcha?.value.listen((value) {
      Map<int, List<int>> message = {};
      int index = 0;
      for (int i in value) {
        if (index == 0) {
          message[i] = [];
          index = i;
        }
        else if (i == 0) {
          index = 0;
        }
        else {
          message[index]?.add(i);
        }
      }
      message.forEach((key, v) {
        if (49 <= key && key <= 52) {
          int index = key - 49;
          String tag = utf8.decode(v);
          CommonVariable.tags[index] = (v.isEmpty ? '空' : tag);
          setState(() {
            tags[index] = CommonVariable.tags[index];
          });
        }
        else {
          Fluttertoast.showToast(
            msg: "未放置物品或正在运行",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0
          );
        }
      });
    });
  }

  void press(int index) {
    if (CommonVariable.btcha == null) {
      Fluttertoast.showToast(
        msg: "未连接设备",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black38,
        textColor: Colors.white,
        fontSize: 16.0
      );
      return;
    }
    if (CommonVariable.tags[index-1] == '空') {
      showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const TagDialog(contentWidget: TagWidget(),);
      }).then((value) {
        if (value != "") {
          List<int> bytes = [48 + index] + utf8.encode(value);
          CommonVariable.btcha?.write(bytes, withoutResponse: false);
        }
      });
    }
    else {
      CommonVariable.btcha?.write([48 + index], withoutResponse: false);
    }
  }
}