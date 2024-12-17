import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio_notification.dart';
import 'home_page.dart';
import 'intro_page.dart';

void main() {
  runApp(ChangeNotifierProvider<AudioNotify>(
      create: (_) => AudioNotify(), child: const Avocado()));
}

class Avocado extends StatelessWidget {
  const Avocado({Key? key}) : super(key: key);
  static const String title = "Avocado";
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // context.read<AudioNotify>().init(["https://cz-sycdn.kuwo.cn/65ba5a44e389ef197d14abb7e8defc4c/62053b4f/resource/n3/97/59/2473102955.mp3"]);
    // context.read<AudioNotify>().play();
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const IntroPage(
        title: title,
        mainPage: HomePage(
          title: title,
        ),
      ),
    );
  }
}
