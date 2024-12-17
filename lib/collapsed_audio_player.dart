import 'dart:developer';

import 'package:avocado/audio.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'audio_notification.dart';

class CollapsedAudioPlayer extends StatefulWidget {
  final PanelController pc;

  const CollapsedAudioPlayer({Key? key, required this.radius, required this.pc})
      : super(key: key);

  final BorderRadiusGeometry radius;

  @override
  State<CollapsedAudioPlayer> createState() => _CollapsedAudioPlayerState();
}

class _CollapsedAudioPlayerState extends State<CollapsedAudioPlayer> {
  final String title = "Six Feet under";

  final String auther = "Billie Eillish";

  @override
  Widget build(BuildContext context) {
    Audio currentAudio = context.watch<AudioNotify>().currentAudio;

    return GestureDetector(
      onTap: () {
        widget.pc.open();
      },
      child: Container(
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromRGBO(207, 104, 154, 1),
                  Color.fromRGBO(170, 120, 173, 1),
                  Color.fromRGBO(99, 167, 222, 1),
                ],
              ),
              borderRadius: widget.radius),
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildPlayButton(context),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      child: Text(currentAudio.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white)),
                    ),
                    Container(
                      width: 200,
                      child: Text(currentAudio.author,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                    ValueListenableBuilder<ProgressBarState>(
                        valueListenable:
                            context.read<AudioNotify>().progressNotifier,
                        builder: (_, value, __) {
                          return Container(
                            width: 220,
                            child: ProgressBar(
                              progressBarColor: Colors.white,
                              thumbColor: Colors.white,
                              baseBarColor: Colors.white30,
                              bufferedBarColor: Colors.white54,
                              timeLabelTextStyle:
                                  TextStyle(fontSize: 12, color: Colors.white),
                              progress: value.current,
                              buffered: value.buffered,
                              total: value.total,
                              onSeek: context.read<AudioNotify>().seek,
                            ),
                          );
                        }),
                  ],
                )
              ],
            ),
          )),
    );
  }

  Widget buildPlayButton(BuildContext context) {
    double iconSize = 70.0;
    return Builder(builder: (c) {
      switch (context.watch<AudioNotify>().bState) {
        case ButtonState.loading:
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: iconSize,
            height: iconSize,
            child: const CircularProgressIndicator(color: Colors.white),
          );
        case ButtonState.paused:
          return IconButton(
            icon: const Icon(Icons.play_circle_outline_outlined),
            iconSize: iconSize,
            color: Colors.white,
            onPressed: context.watch<AudioNotify>().play,
          );
        case ButtonState.playing:
          return IconButton(
            icon: const Icon(Icons.pause_circle_outline_outlined),
            iconSize: iconSize,
            color: Colors.white,
            onPressed: context.watch<AudioNotify>().pause,
          );
      }
    });
  }
}
