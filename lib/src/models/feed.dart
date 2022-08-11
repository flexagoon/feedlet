import 'dart:async';

import 'package:feedlet/data/feeds.dart';
import 'package:feedlet/src/models/cached_feed_item.dart';
import 'package:feedlet/src/models/feed_item.dart';
import 'package:feedlet/src/models/parsed_feed.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

final _box = Hive.box<List<dynamic>>('cache');

class Feed {
  final String url;
  final StreamController<FeedItem> _streamController;
  final List<CachedFeedItem> cache;

  Feed(this.url)
      // This terrible hack is required for Hive unfortunately.
      : cache = _box.get(url)?.map<CachedFeedItem>((e) => e).toList() ?? [],
        _streamController = StreamController<FeedItem>.broadcast(
          onCancel: () => feeds.remove(Feed(url)),
        );

  @override
  int get hashCode => url.hashCode;

  Stream<FeedItem> get stream => _streamController.stream;

  @override
  bool operator ==(Object other) => other is Feed && url == other.url;

  Future<void> fetch() async {
    final response = await http.get(Uri.parse(url));
    final feed = ParsedFeed(response.body);
    final items = feed.items
      ..removeWhere((item) {
        return item.guid != null
            ? cache.any((cachedItem) => cachedItem.guid == item.guid)
            : cache.any((cachedItem) => cachedItem.title == item.title);
      });
    final newCache = items.map(
      (item) => CachedFeedItem(guid: item.guid, title: item.title),
    );
    cache.addAll(newCache);
    _box.put(url, cache);
    items.forEach(_streamController.add);
  }

  Future<bool> validate() async {
    final response = await http.get(Uri.parse(url));

    try {
      ParsedFeed(response.body);
    } on Exception {
      return false;
    }

    return true;
  }

  static Feed getInstance(String url) => feeds.singleWhere((f) => f.url == url);
}
