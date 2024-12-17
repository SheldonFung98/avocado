import 'package:avocado/audio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:developer';

class AudioNotify with ChangeNotifier {
  // ignore: prefer_const_constructors
  Audio currentAudio = Audio(
      authorID: "",
      name: "Your Power",
      author: "Billie Eillish",
      releaseDate: "",
      id: "",
      audioURLs: [
        "https://m8.music.126.net/20220212140604/f3072cf5ec09b37b7df61dcffd10fcee/ymusic/obj/w5zDlMODwrDDiGjCn8Ky/9947386471/500a/8272/2dab/0d624eac25d5fb16c1d9fc81ca16d734.mp3"
      ],
      thumbnailURL:
          "https://tse1-mm.cn.bing.net/th/id/R-C.f2860ceb40857fd2fae040acca8996af?rik=zPcLMcbVl4ogYw&pid=ImgRaw&r=0",
      durationMin: "",
      durationSec: "",
      duration: const Duration(seconds: 0));
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  ButtonState bState = ButtonState.paused;
  late AudioPlayer _audioPlayer;

  AudioNotify() {
    init(currentAudio.audioURLs);
  }

  void setCurrentAudio(Audio audio) {
    _audioPlayer.pause();
    currentAudio = audio;
    init(currentAudio.audioURLs);
    notifyListeners();
  }

  Future<bool> init(List<String> urls) async {
    log(urls.toString());

    _audioPlayer = AudioPlayer();

    for (int i = 0; i < urls.length; i++) {
      try {
        await _audioPlayer.setUrl(urls[i]);
        break;
      } catch (e) {
        log(e.toString());
        if (i == (urls.length - 1)) {
          Fluttertoast.showToast(
              msg: "Failed to load audio",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);
          return Future.value(false);
        }
      }
    }

    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        bState = ButtonState.loading;
        notifyListeners();
      } else if (!isPlaying) {
        bState = ButtonState.paused;
        notifyListeners();
      } else if (processingState != ProcessingState.completed) {
        bState = ButtonState.playing;
        notifyListeners();
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
        notifyListeners();
      }
    });

    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });

    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });

    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
    return Future.value(true);
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState { paused, playing, loading }
