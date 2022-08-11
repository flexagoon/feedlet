import 'package:feedlet/src/models/feed_item.dart';
import 'package:webfeed/webfeed.dart';

class ParsedFeed {
  List<FeedItem> items = [];

  ParsedFeed(String xmlString) {
    try {
      final feed = RssFeed.parse(xmlString);
      items = (feed.items ?? [])
          .map(
            (item) => FeedItem(
              guid: item.guid,
              title: item.title,
              link: item.link,
              date: item.pubDate!.add(item.pubDate!.timeZoneOffset).toUtc(),
            ),
          )
          .toList();
    } catch (_) {
      final feed = AtomFeed.parse(xmlString);
      items = (feed.items ?? [])
          .map(
            (item) => FeedItem(
              guid: item.id,
              title: item.title,
              link: item.links?.first.href,
              date: item.updated!.add(item.updated!.timeZoneOffset).toUtc(),
            ),
          )
          .toList();
    }
  }
}
