import 'dart:async';

import 'package:feedlet/feedlet.dart';
import 'package:feedlet/src/models/feed_item.dart';

String _buildMessage(FeedItem item) => '${item.title}\n\n${item.link}';

StreamSubscription<FeedItem> buildSubscription(Feed feed, int userId) =>
    feed.stream.listen(
      (item) => bot.sendMessage(
        userId,
        _buildMessage(item),
      ),
    );
