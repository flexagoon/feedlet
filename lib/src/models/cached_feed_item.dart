import 'package:hive/hive.dart';

part 'cached_feed_item.g.dart';

// TODO: Just store an update date instead of caching the items.
@HiveType(typeId: 1)
class CachedFeedItem {
  @HiveField(0)
  final String? guid;

  @HiveField(1)
  final String? title;

  CachedFeedItem({this.guid, this.title});
}
