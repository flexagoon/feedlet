import 'dart:async';
import 'dart:collection';

import 'package:feedlet/feedlet.dart';
import 'package:hive/hive.dart';
import 'package:webfeed/webfeed.dart';

final _box = Hive.box<List<String>>('subscriptions');
final _subscriptions = <int, Map<String, StreamSubscription<RssItem>>>{};

class Subscriptions {
  final state = UnmodifiableMapView(_subscriptions);

  Subscriptions() {
    _loadData();
  }

  void add(int userId, Feed feed) {
    if (!feeds.add(feed)) {
      // Avoid creating duplicate streams.
      // ignore: parameter_assignments
      feed = Feed.getInstance(feed.url);
    }
    final subscription =
        feed.stream.listen((item) => bot.sendMessage(userId, item.title!));
    _subscriptions.update(
      userId,
      (subscriptions) => subscriptions
        ..putIfAbsent(
          feed.url,
          () => subscription,
        ),
      ifAbsent: () => {feed.url: subscription},
    );
    _saveData();
  }

  void remove(int userId, Feed feed) {
    final url = feed.url;
    final subscription = _subscriptions[userId]?[url];
    subscription?.cancel();
    _subscriptions[userId]?.remove(url);
    _saveData();
  }

  void _loadData() {
    for (int userId in _box.keys) {
      final subscriptions = _box.get(userId)!;
      for (final url in subscriptions) {
        // TODO: refactor this.
        var feed = Feed(url);
        if (!feeds.add(feed)) {
          feed = Feed.getInstance(feed.url);
        }
        final subscription =
            feed.stream.listen((item) => bot.sendMessage(userId, item.title!));
        _subscriptions.putIfAbsent(userId, () => {url: subscription});
      }
    }
  }

  void _saveData() {
    for (final userId in _subscriptions.keys) {
      _box.put(userId, _subscriptions[userId]!.keys.toList());
    }
  }
}
