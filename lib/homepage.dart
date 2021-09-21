import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  const ControlButton({ Key? key, required this.index, required this.tag }) : super(key: key);
  final int index;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.brown),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(index.toString(), style: const TextStyle(fontSize: 30.0,),),
              Text(tag)
            ]
          ),
          onPressed: () => {}
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
  List<String> tags = ['空', '空', '空', '空'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text('控制'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                ControlButton(index: 1, tag: tags[0],),
                ControlButton(index: 2, tag: tags[1],)
              ]
            ),
          ),
          Expanded(
            child: Row(
              children: [
                ControlButton(index: 3, tag: tags[2],),
                ControlButton(index: 4, tag: tags[3],)
              ]
            ),
          )
        ], 
      ),
    );
  }
}