import 'package:flutter/material.dart';
import '../../screens/home_screen.dart';

/// Named routes for the app. Only 'home' is a real screen this milestone -
/// everything else navigates via PlaceholderScreen directly for now and
/// will move here once each screen is actually built.
class AppRoutes {
  static const String home = '/';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
  };
}
