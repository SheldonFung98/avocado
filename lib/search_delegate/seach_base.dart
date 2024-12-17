import 'package:avocado/audio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SearchBase with ChangeNotifier {
  List<Audio> audioList = <Audio>[];
  Album album = Album();

  Future<bool> searchSubmit(text) async {
    Fluttertoast.showToast(
        msg: "Please Choose Audio Source to Hijack",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
    return Future.value(false);
  }

  Future<Audio> getAudio(int idx) async {
    // ignore: null_argument_to_non_null_type
    return Future.value(null);
  }
}
