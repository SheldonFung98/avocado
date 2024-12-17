class Audio {
  final String name;
  final String author;
  final String authorID;
  final String releaseDate;
  final String id;
  List<String> audioURLs;
  final String thumbnailURL;
  
  final Duration duration;
  final String durationMin;
  final String durationSec;

  Audio({
    required this.authorID,
    required this.name,
    required this.author,
    required this.releaseDate,
    required this.id,
    required this.audioURLs,
    required this.thumbnailURL,
    required this.durationMin,
    required this.durationSec,
    required this.duration,
  });
}

class Album {
  int maxPage = 0;
  int currentPage = 0;
  String name = "";
  void setValue(int max, int current, String n){
    name = n;
    maxPage = max;
    currentPage = current;
  }
}