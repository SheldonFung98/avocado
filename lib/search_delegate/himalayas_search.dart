import 'dart:convert';
import 'dart:developer';
import 'package:avocado/audio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:avocado/search_delegate/seach_base.dart';

class HimalayasSearch extends SearchBase {
  Map<String, dynamic> rawData = {};

  Future<bool> getTrackList(
      String albumID, int pageID, bool isAscending) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String url =
        "https://mobile.ximalaya.com/mobile/v1/album/track/ts-$timestamp?ac=WIFI&albumId=$albumID&device=android&isAsc=$isAscending&pageId=$pageID&pageSize=200";
    Map<String, String> userHeader = {
      "User-Agent": "ting_6.3.60(sdk, Android16)",
      "Accept-Language": "zh-CN,zh;q=0.9"
    };
    final response = await http.get(Uri.parse(url), headers: userHeader);
    rawData = json.decode(response.body);
    if (rawData["ret"] == 0) {
      getAudioListFromJson();
      return Future.value(true);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to load Data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      return Future.value(false);
    }
  }

  void getAudioListFromJson() {
    List<dynamic> listData = rawData["data"]["list"];
    log(listData[0].toString());
    for (int i = 0; i < listData.length; i++) {
      int durationSec = listData[i]["duration"];
      var date = DateTime.fromMillisecondsSinceEpoch(listData[i]["createdAt"]);
      audioList.add(Audio(
          authorID: listData[i]["nickname"],
          name: listData[i]["title"],
          author: listData[i]["nickname"],
          releaseDate: date.year.toString() +
              '-' +
              date.month.toString() +
              '-' +
              date.day.toString(),
          id: listData[i]["trackId"].toString(),
          audioURLs: [listData[i]["playPathAacv224"]],
          thumbnailURL: listData[i]["coverLarge"],
          durationMin: (durationSec / 60).floor().toString(),
          durationSec: (durationSec % 60).toString(),
          duration: Duration(seconds: durationSec)));
    }
  }

  Future<String> getVIPAudioSourceURL(String trackID) async {
    log(trackID);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String url =
        "https://mpay.ximalaya.com/mobile/track/pay/$trackID/$timestamp?device=pc&isBackend=true&_=$timestamp";
    Map<String, String> userHeader = {
      "User-Agent": "ting_6.3.60(sdk, Android16)",
      "Accept-Language": "zh-CN,zh;q=0.9",
      "Cookie": ""
    };
    final response = await http.get(Uri.parse(url), headers: userHeader);
    rawData = json.decode(response.body);
    if (rawData["ret"] == 0) {
      String audioSourceURL = processVIPRes(rawData);
      return Future.value(audioSourceURL);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to Audio Source",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      return Future.value("");
    }
  }

  String processVIPRes(Map<String, dynamic> res) {
    String fileName = decryptFileName(res["seed"], res["fileId"].toString());
    Map<String, String> params = decryptURLParams(res["ep"]);
    String? sign = params["sign"];
    String? buyKey = params["buyKey"];
    String? token = params["token"];
    String? timestamp = params["timestamp"];
    String? duration = res["duration"].toString();
    String args =
        "?sign=$sign&buy_key=$buyKey&token=$token&timestamp=$timestamp&duration=$duration";
    String domain = res["domain"];
    String apiVersion = res["apiVersion"];
    String path = "$domain/download/$apiVersion$fileName$args";
    return path;
  }

  String decryptFileName(int s, String fileID) {
    String fn = "";
    String key =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/\\:._-1234567890";
    int seed = s.toInt();
    String rkey = "";
    int kl = key.length;
    for (int i = 0; i < kl; i++) {
      seed = (211 * seed + 30031) % 65536;
      int ikey = (seed.toDouble() / 65536.0 * key.length.toDouble()).toInt();
      rkey += key[ikey];
      key = key.replaceAll(key[ikey], "");
    }
    var fileIDList = fileID.split("*");
    for (int i = 0; i < fileIDList.length - 1; i++) {
      fn += rkey[int.parse(fileIDList[i])];
    }
    if (fn[0] != "/") fn = "/" + fn;
    return fn;
  }

  Map<String, String> decryptURLParams(String ep) {
    String o = "g3utf1k6yxdwi0";
    List<int> u = [
      19,
      1,
      4,
      7,
      30,
      14,
      28,
      8,
      24,
      17,
      6,
      35,
      34,
      16,
      9,
      10,
      13,
      22,
      32,
      29,
      31,
      21,
      18,
      3,
      2,
      23,
      25,
      27,
      11,
      20,
      5,
      15,
      12,
      0,
      33,
      26
    ];
    List<String> ss =
        decrypt1(decrypt2("d" + o + "9", u), decrypt3(ep)).split("-");
    return {"sign": ss[1], "buyKey": ss[0], "token": ss[2], "timestamp": ss[3]};
  }

  String decrypt1(String e, List<int> t) {
    int n = 0;
    List<int> r = List<int>.generate(256, (i) => i);
    int a = 0;
    int o = 0;
    String s = "";
    for (o = 0; o < 256; o++) {
      a = (a + r[o] + e.codeUnitAt(o % e.length)) % 256;
      n = r[o];
      r[o] = r[a];
      r[a] = n;
    }

    a = 0;
    o = 0;
    for (int u = 0; u < t.length; u++) {
      o = (o + 1) % 256;
      a = (a + r[o]) % 256;
      n = r[o];
      r[o] = r[a];
      r[a] = n;
      s += String.fromCharCode(t[u] ^ r[(r[o] + r[a]) % 256]);
    }
    return s;
  }

  String decrypt2(String s, List<int> u) {
    List<String> n = [];

    for (int r = 0; r < s.length; r++) {
      int a = "a".codeUnitAt(0);
      if (a <= s.codeUnitAt(r) && "z".codeUnitAt(0) >= s.codeUnitAt(r)) {
        a = s.codeUnitAt(r) - 97;
      } else {
        a = s.codeUnitAt(r) - 48 + 26;
      }
      n.add("");
      for (int i = 0; i < 36; i++) {
        if (u[i] == a) {
          a = i;
          break;
        }
      }
      if (a > 25) {
        n[r] = String.fromCharCode((a - 26 + 48));
      } else {
        n[r] = String.fromCharCode((a + 97));
      }
    }
    String res = "";
    if (n.isNotEmpty) {
      res = n.join(res);
    }
    return res;
  }

  List<int> decrypt3(String s) {
    int t = 0;
    int n = 0;
    int r = 0;
    int sLen = s.length;
    List<int> i = [];
    List<int> o = [
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      62,
      -1,
      -1,
      -1,
      63,
      52,
      53,
      54,
      55,
      56,
      57,
      58,
      59,
      60,
      61,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      26,
      27,
      28,
      29,
      30,
      31,
      32,
      33,
      34,
      35,
      36,
      37,
      38,
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
      48,
      49,
      50,
      51,
      -1,
      -1,
      -1,
      -1,
      -1
    ];
    while (r < sLen) {
      t = o[255 & s.codeUnitAt(r)];
      r += 1;
      while (r < sLen && t == -1) {
        t = o[255 & s.codeUnitAt(r)];
        r += 1;
      }
      if (t == -1) break;

      n = o[255 & s.codeUnitAt(r)];
      r += 1;
      while (r < sLen && n == -1) {
        n = o[255 & s.codeUnitAt(r)];
        r += 1;
      }
      if (n == -1) break;

      i.add(((t << 2) | ((48 & n) >> 4)));

      t = 255 & s.codeUnitAt(r);
      r += 1;
      if (t == 61) return i;
      t = o[t];
      while (r < sLen && t == -1) {
        t = 255 & s.codeUnitAt(r);
        r += 1;
        if (t == 61) return i;
        t = o[t];
      }
      if (t == -1) break;

      i.add((((15 & n) << 4) | ((60 & t) >> 2)));

      n = 255 & s.codeUnitAt(r);
      r += 1;
      if (n == 61) return i;
      n = o[n];
      while (r < sLen && n == -1) {
        n = 255 & s.codeUnitAt(r);
        r += 1;
        if (n == 61) return i;
        n = o[n];
      }
      if (n == -1) break;
      i.add((((3 & t) << 6) | n));
    }
    return i;
  }

  @override
  Future<bool> searchSubmit(text) async {
    return getTrackList(text, 1, true);
    getVIPAudioSourceURL(audioList[0].id);
    return Future.value(true);
  }

  @override
  Future<Audio> getAudio(int idx) async {
    Audio audio = audioList[idx];
    audio.audioURLs = [await getVIPAudioSourceURL(audioList[idx].id)];
    return audio;
  }
}
