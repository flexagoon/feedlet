import 'dart:async';

import 'package:feedlet/feedlet.dart';
import 'package:webfeed/webfeed.dart';

String _buildMessage(RssItem item) => '${item.title}\n\n${item.link}';

StreamSubscription<RssItem> buildSubscription(Feed feed, int userId) =>
    feed.stream.listen(
      (item) => bot.sendMessage(
        userId,
        _buildMessage(item),
      ),
    );
