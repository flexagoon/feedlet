import 'dart:async';
import 'dart:collection';

import 'package:feedlet/feedlet.dart';
import 'package:feedlet/src/helpers/build_subscription.dart';
import 'package:feedlet/src/models/feed_item.dart';
import 'package:hive/hive.dart';

final _box = Hive.box<List<String>>('subscriptions');
final _subscriptions = <int, Map<String, StreamSubscription<FeedItem>>>{};

class Subscriptions {
  final state = UnmodifiableMapView(_subscriptions);

  Subscriptions() {
    _loadData();
  }

  void add(int userId, Feed feed) {
    final subscription = buildSubscription(feed, userId);
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
        final feed = Feed.create(url);
        final subscription = buildSubscription(feed, userId);
        _subscriptions.update(
          userId,
          (current) => current..putIfAbsent(url, () => subscription),
          ifAbsent: () => {url: subscription},
        );
      }
    }
  }

  void _saveData() {
    for (final userId in _subscriptions.keys) {
      _box.put(userId, _subscriptions[userId]!.keys.toList());
    }
  }
}
