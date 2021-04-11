import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dialog/custom_dialog.dart';
import '../models/avatar.dart';
import '../models/shared_preferences.dart';
import '../styles.dart';
import 'settings.dart';
import 'token.dart';

class RoomCallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// non-modifiable client role of the page
  final String token;

  /// Creates a call page with given channel name.
  const RoomCallPage({Key key, this.channelName, this.token}) : super(key: key);

  @override
  _RoomCallPageState createState() => _RoomCallPageState();
}

class _RoomCallPageState extends State<RoomCallPage> {
  final _users = <int>[];
  final _anonUsers = <int>[];
  final _infoStrings = <String>[];
  String _currentUsername;
  int _currentUid;
  bool muted = false;
  bool video = true;
  bool frontCamera = true;
  Map<int, dynamic> agoraToFirebaseMap = Map();

  RtcEngine _engine;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    // CallMethods.liveEnded(_currentUid, widget.channelName);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    var userType =
        MySharedPreferences.isStudent == true ? "Student" : "Faculty";
    User _currentUser = FirebaseAuth.instance.currentUser;
    // print(userType);
    FirebaseFirestore.instance
        .collection(userType)
        .doc(_currentUser.uid)
        .collection("MyData")
        .get()
        .then((value) => value.docs.forEach((element) {
              setState(() {
                _currentUsername = element.data()['name'];
                print('current username : $_currentUsername');
              });
            }));

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(widget.token, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    RtcEngineConfig config = RtcEngineConfig(APP_ID);
    _engine = await RtcEngine.createWithConfig(config);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.Communication);
    // await _engine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) async {
        _currentUid = uid;
        // var _docId;
        // final db = FirebaseFirestore.instance;
        // await db
        //     .collection('channels')
        //     .doc('live')
        //     .collection(widget.channelName)
        //     .where('callerFirebaseUid',
        //         isEqualTo: FirebaseAuth.instance.currentUser.uid)
        //     .get()
        //     .then((value) => value.docs.forEach((element) {
        //           _docId = element.id;
        //         }));
        // await db
        //     .collection('channels')
        //     .doc('live')
        //     .collection(widget.channelName)
        //     .doc(_docId)
        //     .update({'callerAgoraUid': uid});
        // // await getUserNamesFromAgoraUid();
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
          // if (widget.role == ClientRole.Broadcaster) {
          _users.add(uid);

          // }
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        // getUserNamesFromAgoraUid();
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
          // Future.delayed(Duration(seconds: 5), getUserNamesFromAgoraUid());
        });
      },
      userOffline: (uid, elapsed) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          _users.remove(uid);
          // Map<int, dynamic> nMap = Map();
          // for (int i in _users) {
          //   if (agoraToFirebaseMap.containsKey(i)) {
          //     nMap[i] = agoraToFirebaseMap[i];
          //   }
          // }
          // print('New agora Map : $nMap');
          // agoraToFirebaseMap = nMap;
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideo: $uid ${width}x $height';
          _infoStrings.add(info);
        });
      },
      remoteVideoStateChanged: (uid, state, reason, elapsed) {
        // state = 1 for video starting
        // state = [0,2,3,4] for video stopped,decoding,frozen,failed
        debugPrint(
            'Remote Video State Changed uid : $uid state : $state reason : $reason');
        setState(() {
          if (reason == VideoRemoteStateReason.RemoteMuted) {
            _users.remove(uid);
            _anonUsers.add(uid);
          } else if (reason == VideoRemoteStateReason.RemoteUnmuted) {
            _users.add(uid);
            _anonUsers.remove(uid);
          }
        });
      },
      connectionStateChanged: (state, reason) async {
        // print('Hellloooo I"m here');
        if (reason == ConnectionChangedReason.TokenExpired) {
          await deleteTokensOfRooms(channelName: widget.channelName);
          // await CallMethods.liveEnded(_currentUid, widget.channelName);
          final expired = await CustomDialog.tokenExpireDialog(context);
          setState(() {
            _infoStrings.add('reason : $reason');
            print('reason : $reason');
            return expired;
          });
        }
      },
    ));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];

    for (var i = 0; i < _users.length; i++) {
      if (_users[i] == _currentUid) {
        if (video) {
          list.add(RtcLocalView.SurfaceView());
        } else {
          list.add(Avatar(uid: _currentUid));
        }
      } else {
        debugPrint('making remote view for ${_users[i]}');
        list.add(RtcRemoteView.SurfaceView(
          uid: _users[i],
        ));
      }
    }
    print(_anonUsers);
    if (_anonUsers.isNotEmpty) {
      for (var i = 0; i < _anonUsers.length; i++) {
        list.add(Avatar(uid: _anonUsers[i]));
      }
    }
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : CustomStyle.primaryColor,
              size: 30.0,
            ),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              elevation: 2.0,
              primary: muted ? CustomStyle.primaryColor : Colors.white,
              padding: const EdgeInsets.all(8.0),
            ),
          ),
          ElevatedButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              frontCamera ? Icons.camera_front : Icons.camera_rear,
              color: CustomStyle.primaryColor,
              size: 30.0,
            ),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              elevation: 2.0,
              primary: Colors.white,
              padding: const EdgeInsets.all(8.0),
            ),
          ),
          ElevatedButton(
            onPressed: _onToggleVideo,
            child: Icon(
              video ? Icons.videocam : Icons.videocam_off,
              color: video ? CustomStyle.primaryColor : Colors.white,
              size: 30.0,
            ),
            style: ElevatedButton.styleFrom(
                primary: video ? Colors.white : CustomStyle.primaryColor,
                shape: CircleBorder(),
                elevation: 2.0,
                padding: const EdgeInsets.all(8.0)),
          ),
          ElevatedButton(
              onPressed: () => _onCallEnd(context),
              child: Icon(
                Icons.call_end,
                color: Colors.white,
                size: 30.0,
              ),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                elevation: 2.0,
                primary: Colors.redAccent,
                padding: const EdgeInsets.all(12.0),
              )),
        ],
      ),
    );
  }

  /// Info panel to show logs for debugging
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
    Navigator.pop(context);
    // CallMethods.liveEnded(_currentUid, widget.channelName);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onToggleVideo() {
    print('Toggling video');
    setState(() {
      video = !video;
    });
    _engine.muteLocalVideoStream(!video);
  }

  void _onSwitchCamera() {
    setState(() {
      frontCamera = !frontCamera;
    });
    _engine.switchCamera();
  }

  // getUserNamesFromAgoraUid() async {
  //   final liveRef = FirebaseFirestore.instance
  //       .collection('channels')
  //       .doc('live')
  //       .collection(widget.channelName);
  //   await liveRef.get().then((value) => value.docs.forEach((doc) {
  //         print('doc data : ' + doc.data().toString());
  //         agoraToFirebaseMap[doc.data()['callerAgoraUid']] =
  //             doc.data()['callerFirebaseUid'];
  //       }));
  //   setState(() {
  //     return true;
  //   });
  //   // debugPrint('users list : ' + _users.toString());
  //   // debugPrint('username list : ' + usernames.toString());

  //   // TODO : map firebase uid to username
  //   // Map<int,dynamic> usernames =
  //   // for(int i in agoraToFirebase.keys) {
  //   //   usernames[i] = agoraToFirebase[i].
  //   // }
  // }

  List<Widget> list = [];

  // List<Widget> _attendees() {
  //   // TODO : Map from agoraToFirebaseMap to usernamesMap
  //   // Map<int, String> _usernamesMap = Map.of(other);
  //   // debugPrint('Final usernames $_usernames');

  //   print('users : ' + '$_users');
  //   print('agoraMap : $agoraToFirebaseMap');
  //   print(
  //       'map lenght : ${agoraToFirebaseMap.length} and list lenght : ${_users.length}');
  //   if (_users.length == 0 ||
  //       agoraToFirebaseMap.length != _users.length ||
  //       agoraToFirebaseMap.containsKey(null)) {
  //     return [Text('Updating list ... ')];
  //   } else {
  //     list = [
  //       Container(
  //         color: CustomStyle.secondaryColor,
  //         height: 100,
  //         child: Center(
  //           child: Text(
  //             'Attendees',
  //             style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //       ),
  //     ];
  //     _users.forEach(
  //       (int uid) => list.add(
  //         Padding(
  //           padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
  //           child: ListTile(
  //             tileColor: CustomStyle.backgroundColor,
  //             leading: Icon(Icons.person),
  //             trailing: Icon(Icons.more_vert_sharp),
  //             title: Text(
  //               agoraToFirebaseMap[uid],
  //               style: TextStyle(
  //                 fontSize: 20,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //     return list;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    debugPrint('========== Building again ============');
    // _attendees();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
      ),
      // endDrawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: _attendees(),
      //   ),
      // ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            // _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
