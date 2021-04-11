import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../styles.dart';

class PostTile extends StatelessWidget {
  final PostModel post;

  PostTile({@required this.post});

  String name = "name";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: CustomStyle.subjectTileStyle(),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ListTile(
            onTap: () {},
            leading: Hero(
              tag: post.id,
              child: CircleAvatar(
                radius: 35,
                backgroundColor: CustomStyle.secondaryColor,
                child: CircleAvatar(
                  backgroundColor: CustomStyle.primaryColor,
                  radius: 25,
                  child: Text(
                    name.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                        color: CustomStyle.backgroundColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                FutureBuilder(
                  future: PostModel.getNamefromUid(post.uid),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text(
                          snapshot.data,
                          style: CustomStyle.customButtonTextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                SizedBox(
                  width: 50,
                ),
                Text(DateTime.parse(post.postTime).toString().substring(0, 19),
                    style: TextStyle(fontSize: 13))
              ],
            ),
            subtitle: Text(
              post.postDes,
            )),
      ),
    );
  }
}
