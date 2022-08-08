import 'dart:async';

import 'package:feedlet/sot.dart';
import 'package:feedlet/src/models/cached_rss_item.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

class Feed {
  final Uri url;
  final StreamController<RssItem> _streamController;

  Feed(this.url)
      : _streamController = StreamController<RssItem>.broadcast(
          onCancel: () => feeds.remove(Feed(url)),
        );

  Stream<RssItem> get stream => _streamController.stream;

  final List<CachedRssItem> cache = [];

  Future<void> fetch() async {
    final response = await http.get(url);
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
    setDBCache(url.toString(), cache);
    items.forEach(_streamController.add);
  }

  @override
  int get hashCode => url.hashCode;

  @override
  bool operator ==(Object other) => other is Feed && url == other.url;
}
