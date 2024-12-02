import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pjpacktrack/future/store_provider.dart'; // Đảm bảo import đúng các provider

final storeSelectedProvider = StateProvider<Store?>((ref) => null);
