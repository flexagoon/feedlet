import 'dart:async';

import 'package:feedlet/feedlet.dart';
import 'package:hive/hive.dart';

Future<void> main() async {
  Hive.init('database');
  await Hive.openBox<List<String>>('subscriptions');
  await Hive.openBox<int>('fetchDates');

  final subscriptions = Subscriptions();

  const updateInterval = Duration(seconds: 10);

  bot.start();
  Timer.periodic(updateInterval, (_) => fetchAll());

  bot.onUrl().listen((message) async {
    final url = Uri.tryParse(message.text!)?.toString();
    if (url != null) {
      final feed = await Feed.createSafe(url);
      if (feed == null) {
        message.reply('Invalid feed!');

        return;
      }
      final userSubscriptions = subscriptions.state[message.chat.id] ?? {};
      if (!userSubscriptions.containsKey(url)) {
        subscriptions.add(message.chat.id, feed);
        message.reply('Subscribed to $url');
      } else {
        subscriptions.remove(message.chat.id, feed);
        message.reply('Unsubscribed from $url');
      }
    } else {
      message.reply('Invalid feed!');
    }
  });
}
