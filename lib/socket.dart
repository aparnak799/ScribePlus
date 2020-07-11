import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
// import 'package:adhara_socket_io/adhara_socket_io.dart';
// import 'dart:convert';

const String URI = 'http://13.234.64.136:5000';

class MyHomePage extends StatefulWidget {
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SocketIO socketIO;
    @override
  void initState() {
    //Creating the socket
    socketIO = SocketIOManager().createSocketIO(
     'http://13.234.75.104:5000/',
      '/',
    );
    //Call init before doing anything with socket
    socketIO.init();
    //Subscribe to an event to listen to
    socketIO.subscribe('message', (jsonData) {
      //Convert the JSON data received into a Map
      print("DATA FROM SOCKET : "+jsonData);
    });

    socketIO.subscribe('1594098288464', (jsonData) {
      //Convert the JSON data received into a Map
      print("DATA FROM SOCKET NEW : "+jsonData);
    });
    //Connect to the socket
    socketIO.connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Socket"),
      ),
      body: Text("data"));
  }
//   TextEditingController _controller = TextEditingController();
//   // SocketIO socketIO;
//   List<String> toPrint = ["trying to connect"];
//   SocketIOManager manager;
//   Map<String, SocketIO> sockets = {};
//   Map<String, bool> _isProbablyConnected = {};

//    @override
//   void initState() {
//     super.initState();
//     manager = SocketIOManager();
//     initSocket("default");
//   }
//   initSocket(String identifier) async {
//     setState(() => _isProbablyConnected[identifier] = true);
//     SocketIO socket = await manager.createInstance(SocketOptions(
//       //Socket IO server URI
//         URI,
//         //Enable or disable platform channel logging
//         enableLogging: false,
//         transports: [Transports.WEB_SOCKET/*, Transports.POLLING*/] //Enable required transport
//     ));
//     socket.onConnect((data) {
//       pprint("connected...");
//       pprint("Inside OnConnect: $data");
//       // socket.emit("disconnect", ["Hey there"]);
//       socket.on("1594098288464",(data) => print("got Data from Socket : "+data));
//       // sendMessage(identifier);
//     });
//     socket.onConnectError(pprint);
//     socket.onConnectTimeout(pprint);
//     socket.onError(pprint);
//     socket.onDisconnect(pprint);
//     // socket.on("type:string", (data) => pprint("type:string | $data"));
//     // socket.on("type:bool", (data) => pprint("type:bool | $data"));
//     // socket.on("type:number", (data) => pprint("type:number | $data"));
//     // socket.on("type:object", (data) => pprint("type:object | $data"));
//     // socket.on("type:list", (data) => pprint("type:list | $data"));
//     // socket.on("message", (data) => pprint(data));
    
//     socket.connect();
//     sockets[identifier] = socket;
//   }
//   bool isProbablyConnected(String identifier){
//     return _isProbablyConnected[identifier]??false;
//   }

//   disconnect(String identifier) async {
//     await manager.clearInstance(sockets[identifier]);
//     setState(() => _isProbablyConnected[identifier] = false);
//   }
//     pprint(data) {
//     setState(() {
//       if (data is Map) {
//         data = json.encode(data);
//       }
//       print(data);
//       toPrint.add(data);
//     });
//   }
//   // IO.Socket socket = IO.io('http://13.234.75.104:5000', <String, dynamic>{
//   //   'transports': ['websocket'],
//   //   // 'autoConnect': false,

//   //   // optional
//   // });

//   //   _connectSocket01() {
//   //   //update your domain before using
//   //   /*socketIO = new SocketIO("http://127.0.0.1:3000", "/chat",
//   //       query: "userId=21031", socketStatusCallback: _socketStatus);*/
//   //   socketIO = SocketIOManager().createSocketIO("wss://echo.websocket.org","", socketStatusCallback: _socketStatus);

//   //   //call init socket before doing anything
//   //   socketIO.init();

//   //   //subscribe event
//   //   // socketIO.subscribe("hello", _onSocketInfo);

//   //   //connect socket
//   //   socketIO.connect();
//   // }
//   // _onSocketInfo(dynamic data) {
//   //   print("Socket info: " + data);
//   // }

//   // _socketStatus(dynamic data) {
//   //   print("Socket status: " + data);
//   // }
//   // _reconnectSocket() {
//   //   if (socketIO == null) {
//   //     _connectSocket01();
//   //   } }
//   // _subscribes() {
//   //   if (socketIO != null) {
//   //     socketIO.subscribe("hello", _onReceiveChatMessage);
//   //   }
//   // }
//   // void _onReceiveChatMessage(dynamic message) {
//   //   print("Message from UFO: " + message);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     bool ipc = isProbablyConnected("default");
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Socket"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Form(
//               child: TextFormField(
//                 controller: _controller,
//                 decoration: InputDecoration(labelText: 'Send a message'),
//               ),
//             ),
//             RaisedButton(
//               child:
//                   const Text('CONNECT  SOCKET 01', style: TextStyle(color: Colors.white)),
//               color: Theme.of(context).accentColor,
//               elevation: 0.0,
//               splashColor: Colors.blueGrey,
//               onPressed:
//                 ipc?null:()=>initSocket("default")
//                 // socket.connect();
//                 // _connectSocket01();
// //                _sendChatMessage(mTextMessageController.text);
              
//             ),
// //             new RaisedButton(
// //               child: const Text('RECONNECT',
// //                   style: TextStyle(color: Colors.white)),
// //               color: Theme.of(context).accentColor,
// //               elevation: 0.0,
// //               splashColor: Colors.blueGrey,
// //               onPressed: () {
// //                 _reconnectSocket();
// // //                _sendChatMessage(mTextMessageController.text);
// //               },
// //             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _sendMessage,
//         tooltip: 'Send message',
//         child: Icon(Icons.send),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty) {
//   //     widget.channel.stream.listen((message) {
//   //       widget.channel.sink.add("received!");
        
//   // });
//       // widget.channel.sink.add(_controller.text);
//     }
//   }

//   @override
//   void dispose() {
//     // widget.channel.sink.close();
//     super.dispose();
  // }
}