import 'dart:async';

import 'package:feedlet/data/feeds.dart';
import 'package:feedlet/src/models/feed_item.dart';
import 'package:feedlet/src/models/parsed_feed.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

final _box = Hive.box<int>('fetchDates');

class Feed {
  final String url;
  final StreamController<FeedItem> _streamController;

  DateTime _lastFetched;

  Feed._fromUrl(this.url)
      : _lastFetched = DateTime.fromMillisecondsSinceEpoch(_box.get(url) ?? 0),
        _streamController = StreamController<FeedItem>.broadcast(
          onCancel: () => feeds.remove(Feed._fromUrl(url)),
        );

  @override
  int get hashCode => url.hashCode;

  Stream<FeedItem> get stream => _streamController.stream;

  Future<String?> getTitle() async {
    final response = await http.get(Uri.parse(url));
    final feed = ParsedFeed(response.body);

    return feed.title;
  }

  @override
  bool operator ==(Object other) => other is Feed && url == other.url;

  Future<void> fetch() async {
    final response = await http.get(Uri.parse(url));
    final feed = ParsedFeed(response.body);
    feed.items
        .where((item) => item.date.isAfter(_lastFetched))
        .toList()
        .forEach(_streamController.add);
    _lastFetched = DateTime.now().toUtc();
    _box.put(url, _lastFetched.millisecondsSinceEpoch);
  }

  Future<bool> _validate() async {
    final response = await http.get(Uri.parse(url));

    try {
      ParsedFeed(response.body);
    } on Exception {
      return false;
    }

    return true;
  }

  static Feed create(String url) {
    var feed = Feed._fromUrl(url);

    if (!feeds.add(feed)) {
      feed = getInstance(url);
    }

    return feed;
  }

  static Future<Feed?> createSafe(String url) async {
    var feed = Feed._fromUrl(url);

    if (!await feed._validate()) return null;

    if (!feeds.add(feed)) {
      feed = getInstance(url);
    }

    return feed;
  }

  static Feed getInstance(String url) => feeds.singleWhere((f) => f.url == url);
}
