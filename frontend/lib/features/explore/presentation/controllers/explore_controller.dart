import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quikfly_core/quikfly_core.dart';
import '../../../../core/network/api_client.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

final exploreFeedProvider = FutureProvider.autoDispose<ExploreFeedDTO>((ref) async {
  final client = ref.watch(apiClientProvider);
  final category = ref.watch(selectedCategoryProvider);
  return client.fetchExploreFeed(category: category);
});
