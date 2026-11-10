import 'package:flutter/widgets.dart';

/// The app's one icon set: Phosphor (MIT, fonts in assets/fonts), regular
/// weight for the mockups' rounded outline style and fill for selected
/// navigation items. Widgets use these names, never `Icons.*`, so the set
/// stays consistent. Code points are from Phosphor 2.1.
abstract final class AppIcons {
  // Navigation.
  static const IconData servers = IconData(0xe2a0, fontFamily: 'PhosphorRegular');
  static const IconData serversSelected = IconData(0xe2a0, fontFamily: 'PhosphorFill');
  static const IconData console = IconData(0xe47e, fontFamily: 'PhosphorRegular');
  static const IconData consoleSelected = IconData(0xe47e, fontFamily: 'PhosphorFill');
  static const IconData credits = IconData(0xe54c, fontFamily: 'PhosphorRegular');
  static const IconData creditsSelected = IconData(0xe54c, fontFamily: 'PhosphorFill');
  static const IconData settings = IconData(0xe272, fontFamily: 'PhosphorRegular');
  static const IconData settingsSelected = IconData(0xe272, fontFamily: 'PhosphorFill');
  static const IconData back = IconData(0xe138, fontFamily: 'PhosphorRegular');
  static const IconData next = IconData(0xe13a, fontFamily: 'PhosphorRegular');
  static const IconData expand = IconData(0xe136, fontFamily: 'PhosphorRegular');
  static const IconData more = IconData(0xe208, fontFamily: 'PhosphorRegular');
  static const IconData close = IconData(0xe4f6, fontFamily: 'PhosphorRegular');

  // Actions.
  static const IconData add = IconData(0xe3d4, fontFamily: 'PhosphorRegular');
  static const IconData decrease = IconData(0xe32a, fontFamily: 'PhosphorRegular');
  static const IconData refresh = IconData(0xe036, fontFamily: 'PhosphorRegular');
  static const IconData search = IconData(0xe30c, fontFamily: 'PhosphorRegular');
  static const IconData copy = IconData(0xe1ca, fontFamily: 'PhosphorRegular');
  static const IconData delete = IconData(0xe4a6, fontFamily: 'PhosphorRegular');
  static const IconData undo = IconData(0xe038, fontFamily: 'PhosphorRegular');
  static const IconData share = IconData(0xeaf0, fontFamily: 'PhosphorRegular');
  static const IconData openExternal = IconData(0xe5de, fontFamily: 'PhosphorRegular');
  static const IconData send = IconData(0xe06c, fontFamily: 'PhosphorRegular');
  static const IconData follow = IconData(0xe03e, fontFamily: 'PhosphorRegular');
  static const IconData history = IconData(0xe1a0, fontFamily: 'PhosphorRegular');
  static const IconData topUp = IconData(0xe1d2, fontFamily: 'PhosphorRegular');
  static const IconData importLegacy = IconData(0xe20c, fontFamily: 'PhosphorRegular');
  static const IconData signOut = IconData(0xe42a, fontFamily: 'PhosphorRegular');
  static const IconData addPlayer = IconData(0xe4d0, fontFamily: 'PhosphorRegular');
  static const IconData removeItem = IconData(0xe32c, fontFamily: 'PhosphorRegular');
  static const IconData timer = IconData(0xe492, fontFamily: 'PhosphorRegular');
  static const IconData show = IconData(0xe220, fontFamily: 'PhosphorRegular');
  static const IconData hide = IconData(0xe224, fontFamily: 'PhosphorRegular');

  // Things.
  static const IconData token = IconData(0xe2d6, fontFamily: 'PhosphorRegular');
  static const IconData folder = IconData(0xe24a, fontFamily: 'PhosphorRegular');
  static const IconData file = IconData(0xe230, fontFamily: 'PhosphorRegular');
  static const IconData textFile = IconData(0xe23a, fontFamily: 'PhosphorRegular');
  static const IconData configFile = IconData(0xe434, fontFamily: 'PhosphorRegular');
  static const IconData java = IconData(0xe1c2, fontFamily: 'PhosphorRegular');
  static const IconData bedrock = IconData(0xe1da, fontFamily: 'PhosphorRegular');
  static const IconData alertsOn = IconData(0xe5e8, fontFamily: 'PhosphorRegular');
  static const IconData alertsOff = IconData(0xe0d4, fontFamily: 'PhosphorRegular');

  // States.
  static const IconData check = IconData(0xe182, fontFamily: 'PhosphorRegular');
  static const IconData success = IconData(0xe184, fontFamily: 'PhosphorRegular');
  static const IconData done = IconData(0xe184, fontFamily: 'PhosphorFill');
  static const IconData warning = IconData(0xe4e0, fontFamily: 'PhosphorRegular');
  static const IconData error = IconData(0xe4e2, fontFamily: 'PhosphorRegular');
  static const IconData failed = IconData(0xe4f8, fontFamily: 'PhosphorFill');
  static const IconData info = IconData(0xe2ce, fontFamily: 'PhosphorRegular');
  static const IconData locked = IconData(0xe308, fontFamily: 'PhosphorRegular');
  static const IconData secure = IconData(0xe308, fontFamily: 'PhosphorFill');
  static const IconData insecure = IconData(0xe306, fontFamily: 'PhosphorRegular');
  static const IconData offline = IconData(0xe4f2, fontFamily: 'PhosphorRegular');
  static const IconData revoked = IconData(0xe2fe, fontFamily: 'PhosphorRegular');
  static const IconData noResults = IconData(0xe30c, fontFamily: 'PhosphorRegular');
  static const IconData waiting = IconData(0xe19a, fontFamily: 'PhosphorRegular');
}
