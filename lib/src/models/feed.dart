import 'dart:async';

import 'package:feedlet/data/feeds.dart';
import 'package:feedlet/src/models/cached_rss_item.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

final _box = Hive.box<List<dynamic>>('cache');

// TODO: Support Atom feeds.
class Feed {
  final String url;
  final StreamController<RssItem> _streamController;
  final List<CachedRssItem> cache;

  Feed(this.url)
      // This terrible hack is required for Hive unfortunately.
      : cache = _box.get(url)?.map<CachedRssItem>((e) => e).toList() ?? [],
        _streamController = StreamController<RssItem>.broadcast(
          onCancel: () => feeds.remove(Feed(url)),
        );

  @override
  int get hashCode => url.hashCode;

  Stream<RssItem> get stream => _streamController.stream;

  @override
  bool operator ==(Object other) => other is Feed && url == other.url;

  Future<void> fetch() async {
    final response = await http.get(Uri.parse(url));
    final feed = RssFeed.parse(response.body);
    final items = feed.items ?? []
      ..removeWhere((item) {
        return item.guid != null
            ? cache.any((cachedItem) => cachedItem.guid == item.guid)
            : cache.any((cachedItem) => cachedItem.title == item.title);
      });
    final newCache = items.map(
      (item) => CachedRssItem(guid: item.guid, title: item.title),
    );
    cache.addAll(newCache);
    _box.put(url, cache);
    items.forEach(_streamController.add);
  }

  Future<bool> validate() async {
    final response = await http.get(Uri.parse(url));

    try {
      RssFeed.parse(response.body);
    } on Exception {
      return false;
    }

    return true;
  }

  static Feed getInstance(String url) => feeds.singleWhere((f) => f.url == url);
}
