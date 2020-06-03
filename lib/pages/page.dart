import 'package:gameroom_app/pages/home_page.dart';
import 'package:provider/provider.dart';

import '../utils/imports.dart';

/// Class for creating top level pages to display to the screen
mixin Page on Widget {
  /// The title that is displayed on the [appBar]
  String get title;

  PageSelection get selection;

  bool get hasBackButton => true;

  /// Switches display to [page]
  static goto(BuildContext context, Page page) {
    Provider.of<HomePageState>(context, listen: false).selectPage(page);
  }
}

enum PageSelection {
  game,
  friends,
  chat,
  history,
  profile,
}