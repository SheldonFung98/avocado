import 'package:avocado/audio.dart';
import 'package:avocado/page_router.dart';
import 'package:avocado/search_delegate/seach_base.dart';
import 'package:http/http.dart' as http;
import 'package:quiver/iterables.dart';
import 'package:provider/provider.dart';

import 'dart:developer';

class LycheeSearch extends SearchBase {
  String page = "";

  String realID = "";

  String fmID = "";

  String name = "";

  int pageID = 1;

  RegExp regExpRealID = RegExp(
    r'<link rel="canonical" href="//www.lizhi.fm/user/([0-9]+)"/>',
    caseSensitive: false,
    multiLine: false,
  );

  RegExp regExpTitle = RegExp(
    r'<p class="audioName">(.*?)</p>',
    caseSensitive: false,
    multiLine: false,
  );

  RegExp regExpName = RegExp(
    r'<div class="left"><a href="/">.*</a>(.*)</div>',
    caseSensitive: false,
    multiLine: false,
  );

  RegExp regExpDuration = RegExp(
    r'<div class="right duration">([0-9]+)&#x27;([0-9]+)&#x27;&#x27;</div>',
    // r'<p class="audioName">(.*?)</p>',
    caseSensitive: false,
    multiLine: false,
  );

  RegExp regExpDate = RegExp(
    r'<p class="aduioTime">(\d{4}[-/]\d{2}[-/]\d{2}).*?</p>',
    caseSensitive: false,
    multiLine: false,
  );

  RegExp regExpAudioID = RegExp(
    r'<a href="/[0-9]+/([0-9]+)"',
    caseSensitive: false,
    multiLine: false,
  );

  RegExp regExpFMID = RegExp(
    r'[^0-9]',
    caseSensitive: false,
    multiLine: false,
  );

  RegExp regExpPageTrim = RegExp(
    r'<h2 class="span">声音列表</h2>([\s\S]*)</html>',
    caseSensitive: false,
    multiLine: false,
  );

  fetchIDPage(String id) async {
    fmID = id;
    final response = await http.get(Uri.parse(
        'https://cors-anywhere.herokuapp.com/https://www.lizhi.fm/' + fmID));
    return getListFromPage(response);
  }

  fetchPage(String realID, int pageNum) async {
    final response = await http.get(Uri.parse(
        'https://cors-anywhere.herokuapp.com/https://www.lizhi.fm/user/' +
            realID +
            '/p/' +
            pageNum.toString()));
    return getListFromPage(response);
  }

  bool getListFromPage(http.Response response) {
    if (response.statusCode == 200) {
      audioList.clear();
      // If the server did return a 200 OK response,
      // then parse the JSON.
      page = response.body;
      name = regExpName.firstMatch(page)!.group(1)!;
      realID = regExpRealID.firstMatch(page)!.group(1)!;
      album.setValue(0, 1, name);

      String pageTrim = regExpPageTrim.firstMatch(page)!.group(1)!;
      var matchZip = zip([
        regExpTitle.allMatches(pageTrim),
        regExpDate.allMatches(pageTrim),
        regExpAudioID.allMatches(pageTrim),
        regExpDuration.allMatches(pageTrim),
      ]);
      for (var triplet in matchZip) {
        final titleMatch = triplet[0].group(1);
        final timeMatch = triplet[1].group(1);
        final idMatch = triplet[2].group(1);
        final durationMin = triplet[3].group(1);
        final durationSec = triplet[3].group(2);
        if (titleMatch != null &&
            timeMatch != null &&
            idMatch != null &&
            durationMin != null &&
            durationSec != null) {
          String begin = "https://cdn5.lizhi.fm/audio/" +
              timeMatch.replaceAll("-", "/") +
              "/" +
              idMatch;
          audioList.add(Audio(
              authorID: fmID,
              releaseDate: timeMatch,
              id: idMatch,
              name: titleMatch,
              durationMin: durationMin,
              durationSec: durationSec,
              audioURLs: [begin + "_ud.mp3", begin + "_hd.mp3"],
              author: name,
              thumbnailURL: '',
              duration: Duration()));
        }
      }
      return true;
    } else if (response.statusCode == 404) {
      log("Failed to find user");
      return false;
    } else {
      log(response.statusCode.toString());
      log("Failed to find user");
      return false;
    }
  }

  @override
  Future<bool> searchSubmit(text) async {
    if (text.length > 4 && !regExpFMID.hasMatch(text)) {
      return await fetchIDPage(text);
    } else {
      return Future.value(false);
    }
  }

  @override
  Future<Audio> getAudio(int idx) async {
    Audio audio = audioList[idx];
    return audio;
  }
}
