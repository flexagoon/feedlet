import 'package:hive/hive.dart';

part 'cached_rss_item.g.dart';

@HiveType(typeId: 1)
class CachedRssItem {
  @HiveField(0)
  final String? guid;

  @HiveField(1)
  final String? title;

  CachedRssItem({this.guid, this.title});
}
