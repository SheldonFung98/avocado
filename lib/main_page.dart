import 'dart:developer';
import 'package:avocado/search_delegate/himalayas_search.dart';
import 'package:avocado/search_delegate/lychee_search.dart';
import 'package:avocado/search_delegate/seach_base.dart';
import 'package:avocado/search_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hijack_notification.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController pageViewController = PageController();
  final searchController = TextEditingController();
  List<Source> sources = [
    Source(
        icon: "assets/images/lychee.png",
        title: "Lychee",
        searchLabelText: "Lychee FM Host ID",
        searchDelegate: LycheeSearch(),
        pageviewID: 1),
    Source(
        icon: "assets/images/mountain.png",
        title: "Himalayas",
        searchLabelText: "Himalayas Album ID",
        searchDelegate: HimalayasSearch(),
        pageviewID: 1),
  ];
  int sourceIndex = -1;
  @override
  void initState() {
    super.initState();
    searchController.text = "92747960";
    searchController.text = "35350539";
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
        controller: pageViewController,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          buildSearchPage(context),
          SearchPage(pageViewController: pageViewController)
        ]);
  }

  Center buildSearchPage(BuildContext context) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            "Which source do you wanna hijack?",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        buildOptions(context),
        buildSearchBox(context),
      ],
    ));
  }

  void selectOption(index, BuildContext context) {
    sources.forEach((element) => element.isSelected = false);
    sources[index].isSelected = true;
    context
        .read<HijackNotify>()
        .setSearchDelegate(sources[index].searchDelegate);
    setState(() {
      sourceIndex = index;
    });
  }

  GridView buildOptions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: List.generate(sources.length, (index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => selectOption(index, context),
                  child: Card(
                      elevation: sources[index].isSelected ? 15 : 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: EdgeInsets.all(
                            sources[index].isSelected ? 5.0 : 12.0),
                        child: Image.asset(sources[index].icon,
                            fit: BoxFit.scaleDown),
                      )),
                ),
              ),
              Center(
                  child: Container(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        sources[index].title,
                        style: TextStyle(
                            fontSize: sources[index].isSelected ? 16 : 14,
                            fontWeight: sources[index].isSelected
                                ? FontWeight.bold
                                : FontWeight.normal),
                      )))
            ],
          ),
        );
      }),
    );
  }

  void searchSubmmit(String text, BuildContext context) {
    context.read<HijackNotify>().searchSubmit(text, () {
      pageViewController.animateToPage(sources[0].pageviewID,
          duration: const Duration(seconds: 1), curve: Curves.easeInExpo);
    });
  }

  Padding buildSearchBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            prefixIcon: context.watch<HijackNotify>().isSubmitting()
                ? Transform.scale(
                    scale: 0.4,
                    child: const CircularProgressIndicator(color: Colors.black),
                  )
                : const Icon(Icons.search_sharp),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(20),
            )),
            hintText: sourceIndex == -1
                ? "Please choose the sources"
                : sources[sourceIndex].searchLabelText,
            // errorText: _errorText,
          ),
          onSubmitted: (text) {
            searchSubmmit(text, context);
          }),
    );
  }
}

class Source {
  final String icon;
  final String title;
  final int pageviewID;
  final String searchLabelText;
  final SearchBase searchDelegate;
  bool isSelected = false;

  Source(
      {required this.title,
      required this.icon,
      required this.pageviewID,
      required this.searchLabelText,
      required this.searchDelegate});
}
