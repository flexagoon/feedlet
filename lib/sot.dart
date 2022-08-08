import 'package:feedlet/feedlet.dart';
import 'package:feedlet/src/models/cached_rss_item.dart';
import 'package:feedlet/token.dart';
import 'package:hive/hive.dart';
import 'package:teledart/teledart.dart';

Future<void> initDatabase() async {
  print('Initializing database...');
  Hive
    ..init('data/hive')
    ..registerAdapter(CachedRssItemAdapter());
  await Hive.openBox<List<String>>('subscriptions');
  await Hive.openBox<List<dynamic>>('cache');
  for (final id in _subscriptionsDB.keys) {
    final user = User(id);
    users.add(user);
    final subscriptions = [..._subscriptionsDB.get(id, defaultValue: [])!];
    for (final feed in subscriptions) {
      user.subscribe(Feed(Uri.parse(feed)), addToDb: false);
    }
  }
  for (final url in _cacheDB.keys) {
    final feed = feeds.singleWhere((f) => f.url.toString() == url);
    final cache = _cacheDB.get(url, defaultValue: []);
    // A typecast from dynamic is required here since Hive doesn't work well with lists of custom objects.
    // ignore: prefer_foreach
    for (CachedRssItem item in cache!) {
      feed.cache.add(item);
    }
  }
  print('Database initialized!');
}

final Set<Feed> feeds = {};
final Set<User> users = {};

final _subscriptionsDB = Hive.box<List<String>>('subscriptions');
final _cacheDB = Hive.box<List<dynamic>>('cache');

void addSubscriptionToDB(int userId, Feed feed) {
  final subscriptions = _subscriptionsDB.get(userId, defaultValue: []);
  subscriptions!.add(feed.url.toString());
  _subscriptionsDB.put(userId, subscriptions);
}

void removeSubscriptionFromDB(int userId, Feed feed) {
  final subscriptions = _subscriptionsDB.get(userId, defaultValue: []);
  subscriptions!.remove(feed.url.toString());
  _subscriptionsDB.put(userId, subscriptions);
}

void setDBCache(String feedUrl, List<CachedRssItem> cache) =>
    _cacheDB.put(feedUrl, cache);

void fetchAll() {
  for (final feed in feeds) {
    print('fetching ${feed.url}');
    feed.fetch();
  }
}

final teledart = TeleDart(
  token,
  Event('feedlet_bot'),
);
