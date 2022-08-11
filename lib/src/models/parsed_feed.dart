import 'package:feedlet/src/models/feed_item.dart';
import 'package:webfeed/webfeed.dart';

class ParsedFeed {
  List<FeedItem> items = [];

  ParsedFeed(String xmlString) {
    try {
      final feed = RssFeed.parse(xmlString);
      items = (feed.items ?? [])
          .map((item) => FeedItem(item.guid, item.title, item.link))
          .toList();
    } catch (_) {
      final feed = AtomFeed.parse(xmlString);
      items = (feed.items ?? [])
          .map((item) => FeedItem(item.id, item.title, item.links?.first.href))
          .toList();
    }
  }
}
