import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'audio_notification.dart';
import 'audio_player.dart';
import 'collapsed_audio_player.dart';
import 'hijack_notification.dart';
import 'main_page.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  final PanelController _pc = PanelController();
  final BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0)
  );

@override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HijackNotify>(
      create: (_) => HijackNotify(),
      child: Scaffold(
          appBar: buildAppBar(),
          body: SlidingUpPanel(
            controller: _pc,
            borderRadius: radius,
            maxHeight: MediaQuery.of(context).size.height*0.8,
            panel: AudioPlayer(),
            collapsed: CollapsedAudioPlayer(radius: radius, pc: _pc),
            body: MainPage(),
          ),
        )
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Hero(tag: "mainIcon", child: Image.asset("assets/icon/icon.png")),
        ),
      ],
      title: Hero(
          tag: "appBarTitle",
          child: Text(widget.title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                decoration: TextDecoration.none,
              ))),
    );
  }
}

