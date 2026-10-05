import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected bottom-nav tab: 0 Home, 1 Sales, 2 Warehouse, 3 Settings.
final currentTabProvider = StateProvider<int>((ref) => 0);
