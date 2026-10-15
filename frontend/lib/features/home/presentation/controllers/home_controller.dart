import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quikfly_core/quikfly_core.dart';
import '../../../../core/network/api_client.dart';

final selectedLocationProvider = StateProvider<String>((ref) => 'Indiranagar, Bengaluru');

final homeFeedProvider = FutureProvider.autoDispose<HomeFeedDTO>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.fetchHomeFeed();
});
