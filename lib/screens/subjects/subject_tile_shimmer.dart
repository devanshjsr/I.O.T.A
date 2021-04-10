import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../styles.dart';

//  Shimmer Tile to be shown to the user when subject data is being fetched from firebase
class SubjectShimmerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6),
      decoration: CustomStyle.subjectTileStyle(),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        leading: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: Icon(
            Icons.menu_book_rounded,
            size: 35,
            color: CustomStyle.primaryColor,
          ),
        ),
        title: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: FractionallySizedBox(
            alignment: Alignment.topLeft,
            widthFactor: 0.8,
            child: Container(
              height: 16,
              color: CustomStyle.primaryColor,
            ),
          ),
        ),
        subtitle: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: FractionallySizedBox(
            alignment: Alignment.topLeft,
            widthFactor: 0.7,
            child: Container(
              margin: EdgeInsets.only(top: 5),
              height: 14,
              color: CustomStyle.primaryColor,
            ),
          ),
        ),
        trailing: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: Icon(
            Icons.more_vert_outlined,
            size: 35,
            color: CustomStyle.primaryColor,
          ),
        ),
      ),
    );
  }
}
