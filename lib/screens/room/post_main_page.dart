import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../models/data_model.dart';
import '../../models/post_model.dart';
import '../../models/subject_model.dart';
import '../../styles.dart';
import 'post_tile.dart';

class Post extends StatelessWidget {
  static final routeName = "/post";
  final _formKey = GlobalKey<FormState>();

  final Map<String, String> postDetail = {
    "uid": "",
    "post Time": "",
    "post description": "",
  };
  @override
  Widget build(BuildContext context) {
    Subject subject = ModalRoute.of(context).settings.arguments;
    void addPost() async {
      bool valid = _formKey.currentState.validate();

      if (valid) {
        _formKey.currentState.save();

        await Provider.of<PostProvider>(context, listen: false)
            .postCurrentPost(subject, postDetail);

        Fluttertoast.showToast(
            msg: "Post Published",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Post",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: Provider.of<PostProvider>(context, listen: false)
                  .fetchSubjectPost(subject),
              builder: (ctx, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (dataSnapshot.hasError) {
                  return Center(
                    child: Text(DataModel.SOMETHING_WENT_WRONG),
                  );
                } else {
                  return Consumer<PostProvider>(
                    builder: (ctx, postData, child) => RefreshIndicator(
                        child: ListView.builder(
                            itemCount: postData.getAllPost.length,
                            itemBuilder: (ctx, index) => PostTile(
                                post: postData.getAllPost.toList()[index])),
                        onRefresh: () {
                          return Provider.of<PostProvider>(context,
                                  listen: false)
                              .fetchSubjectPost(subject);
                        }),
                  );
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              elevation: 40,
              child: Row(children: <Widget>[
                Form(
                  key: _formKey,
                  child: Container(
                    width: 240,
                    height: 60,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: CustomStyle.customTextFieldDecoration(
                          labelText: "Enter the Post"),
                      onSaved: (data) {
                        postDetail["post description"] = data;
                      },
                      validator: (value) {
                        if (value == null || value.trim() == "") {
                          return "Can't Post Empty Field";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                FloatingActionButton(
                    child: Icon(Icons.image), onPressed: () {}),
                FloatingActionButton(
                    child: Icon(Icons.send_rounded),
                    onPressed: () {
                      addPost();
                    }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
