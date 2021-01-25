import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../style.dart';
import '../navdrawer/navdrawer.dart';
import 'comment.dart';

class Comments extends StatefulWidget {
  Socket _socket;

  var _initialChunk;
  var _initialInfo;

  Comments(this._socket, this._initialChunk, this._initialInfo);

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final _player = AudioPlayer();

  // info
  int listeners = 0;
  String ddTitle = '';
  String ddLink = '';

  // state vars
  List<Comment> comments = [];
  List<Comment> commentsDisplayed = [];
  Comment curComment;

  bool playStream = true;

  int maxBacklog = 25;
  int maxDisplayed = 30;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _initPlayer();

    var info = widget._initialInfo;
    var chunk = widget._initialChunk;

    processInfo(info);
    processChunk(chunk);
  }

  void _initSocket() {
    Socket socket = widget._socket;

    socket.on('chunk', (data) => processChunk(data));

    socket.on('info', (data) {
      processInfo(data);
      setState(() {});
    });
  }

  void _initPlayer() async {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onCommentPlayed();
      }
    });
  }

  void processInfo(data) {
    this.listeners = data['listeners'];
    this.ddTitle = data['current_dd_title'];
    this.ddLink = data['current_dd_url'];
  }

  void processChunk(data) {
    List<Comment> newComments = [];

    // can't allow more comments tha the max allowed in comment backlog
    var numBacklogged = comments.length;
    var numUntilMaxBacklog = maxBacklog - numBacklogged;

    for (var i = 0; i < data.length && numUntilMaxBacklog > 0; i++) {
      String id = data[i]['id'];
      String msg = data[i]['body'];
      String author = data[i]['username'];
      String flair = data[i]['flair'];
      flair = (flair == null) ? '' : flair;
      String permalink = data[i]['permalink'];
      //String symbols = data[i]['symbols'];
      var symbols = ['appl', 'tsla'];
      String mp3 = 'https://wsbsynth.com/synthesized/' + data[i]['mp3'];
      newComments.add(Comment(id, author, flair, msg, permalink, symbols, mp3));
      numUntilMaxBacklog--;
    }

    setState(() {
      comments.addAll(newComments);
    });

    if (!_player.playing && playStream) {
      _getAndPlayNextComment();
    }
  }

  void _playComment(Comment comment) async {
    print('playing comment' + comment.id);
    curComment = comment;
    commentsDisplayed.add(comment);
    if (commentsDisplayed.length > maxDisplayed) {
      commentsDisplayed.remove(commentsDisplayed.first);
    }
    setState(() {});
    await _player.setUrl(comment.audio);
    _player.play();
  }

  void _onCommentPlayed() {
    _player.stop();
    comments.remove(curComment);
    curComment = null;
    _getAndPlayNextComment();
  }

  void _getAndPlayNextComment() {
    // grab a new comment to play.
    for (var i = 0; i < comments.length; i++) {
      var comment = comments[i];
      if (curComment == null || comment.id != curComment.id) {
        _playComment(comment);
      }
    }
  }

  Comment _getComment(String id) {
    for (var i = 0; i < comments.length; i++) {
      if (comments[i].id == id) {
        return comments[i];
      }
    }
  }

  void togglePlay() {
    setState(() {
      playStream = !playStream;
      if (!playStream)
        _player.pause();
      else
        _player.play();
    });
  }

  void _launchDDUrl() async {
    if (await canLaunch(ddLink)) {
      await launch(ddLink);
    } else {
      throw 'Could not launch $ddLink';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.headset),
            Container(
                margin: EdgeInsets.fromLTRB(5, 0, 20, 0),
                child: Text(listeners.toString())),
            Icon(Icons.bookmark),
            Container(
                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                child: Text(comments.length.toString()))
          ],
        ),
      ),
      backgroundColor: AppSecondaryColor,
      body: Column(children: [
        InkWell(
            onTap: () => _launchDDUrl(),
            child: Container(
              padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
              decoration: BoxDecoration(color: AppSuperDarkColor),
              child: Text(ddTitle,
                  style: TextStyle(color: AppLightColor, fontSize: 16)),
            )),
        Expanded(
          child: ListView.builder(
              itemCount: commentsDisplayed.length,
              itemBuilder: (BuildContext context, int idx) {
                return commentsDisplayed[(commentsDisplayed.length - 1 - idx)];
              }),
        )
      ]),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: Container(
          height: 80,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () => togglePlay(),
              child: Icon((playStream) ? Icons.pause : Icons.play_arrow),
              backgroundColor: AppPrimaryColor,
              foregroundColor: AppTextColor,
            ),
          )),
    );
  }
}
