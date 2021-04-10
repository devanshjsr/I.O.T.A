import 'package:flutter/cupertino.dart';

class Submission{
  String id;
  String name;
  DateTime submissionTime;
  String url;

  Submission({
    @required this.id,
    @required this.name,
    @required this.submissionTime,
    @required this.url
    });
}