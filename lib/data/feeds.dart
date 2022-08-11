import 'package:feedlet/feedlet.dart';

final feeds = <Feed>{};

void fetchAll() {
  for (final feed in feeds) {
    print('fetching ${feed.url}');
    feed.fetch();
  }
}
