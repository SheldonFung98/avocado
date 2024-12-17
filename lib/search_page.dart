import 'dart:developer';

import 'package:avocado/audio.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import 'audio_notification.dart';
import 'hijack_notification.dart';

class SearchPage extends StatefulWidget {
  final PageController pageViewController;
  const SearchPage({
    Key? key,
    required this.pageViewController,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchIDController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchIDController.text = "92747960";
  }

  String? get _errorText {
    final text = searchIDController.value.text;
    if (text.isNotEmpty && text.length < 4) {
      return 'Too short';
    }
    // else if (widget.searchDelegator.regExpFMID.hasMatch(text)) {
    //   return 'Invalid FM ID';
    // }
    return null;
  }

  Future<void> chooseAudio(BuildContext context, int index) async {
    Audio audio =
        await context.read<HijackNotify>().searchDelegate.getAudio(index);
    context.read<AudioNotify>().setCurrentAudio(audio);
    context.read<AudioNotify>().play();
  }

  @override
  Widget build(BuildContext context) {
    // context.read<HijackNotify>().searchSubmit("", (){});
    List<Audio> audioList =
        context.watch<HijackNotify>().searchDelegate.audioList;

    Album album = context.watch<HijackNotify>().searchDelegate.album;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_upward_sharp),
                  iconSize: 40,
                  onPressed: () {
                    widget.pageViewController.animateToPage(0,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInExpo);
                  }),
              Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_left),
                      iconSize: 50,
                      onPressed: () {}),
                  Text(album.currentPage.toString(),
                      style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.normal)),
                  IconButton(
                      icon: const Icon(Icons.arrow_right),
                      iconSize: 50,
                      onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(bottom: 220.0, right: 5.0, left: 5.0),
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: audioList.length,
                itemBuilder: (c, index) {
                  Audio aData = audioList[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Card(
                      elevation: 5.0,
                      child: InkWell(
                        onTap: () {
                          chooseAudio(context, index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Hero(
                                  tag: aData.id,
                                  child: Text(
                                    aData.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.normal),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(aData.releaseDate,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                                decoration: TextDecoration.none,
                                                fontWeight:
                                                    FontWeight.normal))),
                                    Expanded(
                                        child: Text(
                                            aData.durationMin +
                                                '\'' +
                                                aData.durationSec +
                                                '\'\'',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                                decoration: TextDecoration.none,
                                                fontWeight:
                                                    FontWeight.normal))),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        )
      ],
    );
  }
}
