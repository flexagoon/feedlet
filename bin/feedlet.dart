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

  bot.onCommand('start').listen(
        (message) => message.reply(
          'Send me a link to a feed to subscribe to it. '
          'Send the same link again to unsubscribe.',
        ),
      );

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

  bot.onCommand('subscriptions').listen((message) async {
    final userSubscriptions = subscriptions.state[message.chat.id] ?? {};
    if (userSubscriptions.isNotEmpty) {
      var messageText = '';
      for (final url in userSubscriptions.keys) {
        final feed = Feed.getInstance(url);
        final title = await feed.getTitle();
        messageText += '$title: ${feed.url}\n';
      }
      message.reply(messageText);
    } else {
      message.reply('You don\'t have any subscriptions!');
    }
  });
}
