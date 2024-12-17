// import 'dart:ffi';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:avocado/audio.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import 'audio_notification.dart';

class AudioPlayer extends StatefulWidget {
  const AudioPlayer({Key? key}) : super(key: key);

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Audio currentAudio = context.watch<AudioNotify>().currentAudio;
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              buildBackground(currentAudio.thumbnailURL),
              buildSkipButtons(),
              buildPlayButtion(context)
            ],
          ),
          buildSideController(),
          buildTitles(currentAudio.author, currentAudio.name),
          buildProgressBar(context),
        ],
      ),
    );
  }

  Container buildProgressBar(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ValueListenableBuilder<ProgressBarState>(
            valueListenable: context.read<AudioNotify>().progressNotifier,
            builder: (_, value, __) {
              return ProgressBar(
                progressBarColor: const Color.fromRGBO(127, 145, 194, 1),
                thumbColor: const Color.fromRGBO(127, 145, 194, 1),
                baseBarColor: const Color.fromRGBO(220, 225, 241, 1),
                bufferedBarColor: Colors.white54,
                timeLabelTextStyle: const TextStyle(
                    fontSize: 12, color: Color.fromRGBO(101, 122, 156, 1)),
                progress: value.current,
                buffered: value.buffered,
                total: value.total,
                onSeek: context.read<AudioNotify>().seek,
              );
            }),
      ),
    );
  }

  Container buildTitles(String authorName, String audioName) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(authorName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 22, color: Color.fromRGBO(204, 207, 214, 1))),
            Text(audioName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 28, color: Color.fromRGBO(101, 122, 156, 1))),
          ],
        ),
      ),
    );
  }

  Padding buildSideController() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.fast_rewind,
            size: 40,
            color: Color.fromRGBO(202, 211, 227, 1),
          ),
          Icon(
            Icons.repeat,
            size: 40,
            color: Color.fromRGBO(202, 211, 227, 1),
          ),
          Icon(
            Icons.fast_forward,
            size: 40,
            color: Color.fromRGBO(202, 211, 227, 1),
          ),
        ],
      ),
    );
  }

  Container buildBackground(String backgroundImageURL) {
    return Container(
        clipBehavior: Clip.hardEdge,
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), BlendMode.dstATop),
              image: NetworkImage(backgroundImageURL)),
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromRGBO(207, 104, 154, 1),
              Color.fromRGBO(170, 120, 173, 1),
              Color.fromRGBO(99, 167, 222, 1),
            ],
          ),
        ));
  }

  Padding buildSkipButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 270.0),
      child: Center(
        child: Container(
          width: 240,
          height: 60,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10.0, spreadRadius: 1.0)
              ],
              borderRadius: BorderRadius.circular(24),
              color: const Color.fromRGBO(220, 225, 241, 1)),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.skip_previous_sharp,
                  size: 40,
                  color: Color.fromRGBO(127, 145, 194, 1),
                ),
                Icon(Icons.skip_next_sharp,
                    size: 40, color: Color.fromRGBO(127, 145, 194, 1))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding buildPlayButtion(BuildContext context) {
    double iconSize = 60.0;
    return Padding(
        padding: const EdgeInsets.only(top: 250.0),
        child: Center(
          child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10.0, spreadRadius: 1.0)
              ], shape: BoxShape.circle, color: Colors.white),
              child: Builder(builder: (c) {
                switch (context.watch<AudioNotify>().bState) {
                  case ButtonState.loading:
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      width: iconSize,
                      height: iconSize,
                      child: const CircularProgressIndicator(
                          color: Color.fromRGBO(127, 145, 194, 1)),
                    );
                  case ButtonState.paused:
                    return IconButton(
                      icon: const Icon(Icons.play_arrow_sharp,
                          color: Color.fromRGBO(127, 145, 194, 1)),
                      iconSize: iconSize,
                      color: Colors.white,
                      onPressed: context.watch<AudioNotify>().play,
                    );
                  case ButtonState.playing:
                    return IconButton(
                      icon: const Icon(Icons.pause_sharp,
                          color: Color.fromRGBO(127, 145, 194, 1)),
                      iconSize: iconSize,
                      color: Colors.white,
                      onPressed: context.watch<AudioNotify>().pause,
                    );
                }
              })),
        ));
  }
}
