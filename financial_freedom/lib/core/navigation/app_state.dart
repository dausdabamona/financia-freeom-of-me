import 'package:flutter/widgets.dart';

/// Global callback to reset the app to the welcome screen.
/// Set by AppEntryPoint, called by Settings page after data deletion.
VoidCallback? resetAppToWelcome;
