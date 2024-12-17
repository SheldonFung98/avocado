import 'package:avocado/search_delegate/lychee_search.dart';
import 'package:avocado/search_delegate/seach_base.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class HijackNotify with ChangeNotifier {
  SearchBase searchDelegate = SearchBase();
  bool submitting = false;

  Future<void> searchSubmit(text, Function resCallBack) async {
    submitting = true;
    if (await searchDelegate.searchSubmit(text)) {
      resCallBack();
    }
    submitting = false;
    notifyListeners();
  }

  bool isSubmitting() {
    return submitting;
  }

  void setSearchDelegate(SearchBase sb) {
    searchDelegate = sb;
  }
}
