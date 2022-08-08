import 'dart:async';

import 'package:feedlet/feedlet.dart';
import 'package:feedlet/sot.dart';
import 'package:webfeed/webfeed.dart';

class User {
  final int id;

  User(this.id);

  final Map<Feed, StreamSubscription<RssItem>> subscriptions = {};

  void subscribe(Feed feed, {bool addToDb = true}) {
    if (!feeds.add(feed)) {
      // Avoid creating duplicate streams.
      // ignore: parameter_assignments
      feed = feeds.singleWhere((f) => f == feed);
    }
    final subscription =
        feed.stream.listen((item) => teledart.sendMessage(id, item.title!));
    subscriptions.putIfAbsent(feed, () => subscription);
    if (addToDb) addSubscriptionToDB(id, feed);
  }

  void unsubscribe(Feed feed) {
    final subscription = subscriptions[feed];
    subscription?.cancel();
    subscriptions.remove(feed);
    removeSubscriptionFromDB(id, feed);
  }

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is User && id == other.id;
}
