import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../assets.dart';
import '../comments/comments.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _connected = false;

  var _initialChunk;
  var _initialInfo;

  Socket _socket;

  @override
  void initState() {
    super.initState();

    // start connecting to server
    _socket = io('https://wsbsynth.com:3000',
        OptionBuilder().setTransports(['websocket']).build());

    _socket.onConnect((_) {
      setState(() {
        _connected = true;
      });
    });
    _socket.on('chunk', (data) {
      setState(() {
        print('initial chunk');
        _socket.off('chunk');
        _initialChunk = data;
      });
    });
    _socket.on('info', (data) {
      setState(() {
        print('initial info');
        _socket.off('info');
        _initialInfo = data;
      });
    });
    //_socket.onDisconnect((_) => print('disconnect'));
  }

  @override
  Widget build(BuildContext context) {
    // on connection update
    if (_connected && _initialInfo != null && _initialChunk != null) {
      Timer(
          Duration(seconds: 1),
          () => Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) =>
                  Comments(_socket, _initialChunk, _initialInfo))));
    }

    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(AssetLogoPath,
            height: 350, width: 350, fit: BoxFit.scaleDown),
        Container(
            margin: EdgeInsets.fromLTRB(0, 35, 0, 0),
            child: Text(
                (_connected)
                    ? ((_initialChunk == null || _initialInfo == null)
                        ? 'Getting info . . .'
                        : 'Complete')
                    : 'Connecting . . .',
                style: Theme.of(context).textTheme.bodyText1))
      ]),
    );
  }
}
