import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../dialog/custom_dialog.dart';
import '../../models/caller_model.dart';
import '../../models/shared_preferences.dart';
import '../../models/subject_model.dart';
import '../../services/call.dart';
import '../../styles.dart';

// import '../services/call.dart';
// import '../styles.dart';
// import 'dialogs.dart';

class IndexPage extends StatefulWidget {
  static const routeName = '/video_call';
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  String channelName = '';
  Subject subject;
  Future resultsLoaded;
  bool loading = true;
  final _searchController = TextEditingController();

  List _channels = [];
  List _subjectChannels = [];
  List _filteredChannels = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // will not call keep waiting the build method and will only run once on State class run
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resultsLoaded = getChannels();
    // print("depencency changed");
  }

  _onSearchChanged() {
    performSearch();
    // print(_searchController.text);
  }

  getChannels() async {
    // get all channels from channel collection

    // final snapshot =
    //     await FirebaseFirestore.instance.collection('channels').get();
    // setState(() {
    //   snapshot.docs.forEach((doc) => _channels.add(doc.data()['name']));
    // });

    // get channel from subject collection
    final subjectSnapshot =
        await FirebaseFirestore.instance.collection('Subjects').get();
    // print(subject);
    subjectSnapshot.docs.forEach((doc) {
      if (doc.data()['subject_name'] == subject.name) {
        _channels = List<String>.from(doc.data()['channels'] ?? []);
      }
    });

    // when the data from firebase has loaded change the loading variable
    // and when performSearch runs it calls setState() which will build again
    loading = false;
    performSearch();
    // can return anything; just an indication of function end
    return "Completed";
  }

  performSearch() {
    var showResults = [];
    if (_searchController.text.isNotEmpty) {
      // when we have something in the search box
      for (var chan in _channels) {
        if (chan.toLowerCase().contains(_searchController.text.toLowerCase())) {
          showResults.add(chan);
          // print('channel added : $chan');
        }
      }
    } else {
      showResults = List.from(_channels);
    }
    setState(() {
      _filteredChannels = showResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      subject = ModalRoute.of(context).settings.arguments;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Channels'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                decoration: CustomStyle.customTextFieldDecoration(
                  labelText: 'Channel Name',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onJoin,
                        child: Text('Join'),
                        style: CustomStyle.customElevatedButtonStyle(),
                      ),
                    )
                  ],
                ),
              ),
              !loading
                  ? Expanded(
                      child: createListView(),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.orangeAccent,
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget createListView() {
    // print('lenght odf channels ' + _filteredChannels.length.toString());
    if (_filteredChannels.length == 0) {
      return Center(
        child: Text('No channels yet'),
      );
    } else {
      return ListView.builder(
        itemCount: _filteredChannels.length,
        itemBuilder: (context, index) {
          return Card(
            color: CustomStyle.secondaryColor,
            elevation: 3.0,
            child: InkWell(
              onTap: () => _searchController.text = _filteredChannels[index],
              splashFactory: InkRipple.splashFactory,
              child: Container(
                margin: EdgeInsets.all(15.0),
                child: Text(_filteredChannels[index]),
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> onJoin() async {
    channelName = _searchController.text;
    if (channelName.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      print('Hello');
      // push video page with given channel name and token
      final db = FirebaseFirestore.instance;
      final snapshot = await db
          .collection('channels')
          .where('name', isEqualTo: channelName)
          .get();

      // check if the channel is present in the DB or not
      if (snapshot.size == 0) {
        print('NO CHANNEL');
        // no channel with the specified name
        // return CustomDialog.noChannelDialog(context);
      } else {
        String token = '';
        snapshot.docs.forEach((doc) {
          token = doc.data()['token'];
        });

        //to map firebase uid with agora uid
        final caller = Caller(
          callerFirebaseUid: FirebaseAuth.instance.currentUser.uid,
          channelName: channelName,
          isStudent: MySharedPreferences.isStudent,
          callerAgoraUid: null,
        );
        Map<String, dynamic> callMap = caller.toMap(caller);
        await db
            .collection('channels')
            .doc('live')
            .collection(channelName)
            .add(callMap);

        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallPage(
                channelName: channelName,
                token: token,
                subject: subject,
              ),
            ));
      }
    }
    // }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
