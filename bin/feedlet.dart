import 'dart:async';

import 'package:feedlet/feedlet.dart';
import 'package:feedlet/sot.dart';

Future<void> main() async {
  const updateInterval = Duration(seconds: 10);

  await initDatabase();
  teledart.start();
  Timer.periodic(updateInterval, (_) => fetchAll());

  teledart.onUrl().listen((message) {
    final url = Uri.tryParse(message.text!);
    if (url != null) {
      final feed = Feed(url);
      users.add(User(message.chat.id));
      final user = users.singleWhere((user) => user.id == message.chat.id);
      if (!user.subscriptions.containsKey(feed)) {
        user.subscribe(feed);
        message.reply('Subscribed to $url');
      } else {
        user.unsubscribe(feed);
        message.reply('Unsubscribed from $url');
      }
    }
  });
}
