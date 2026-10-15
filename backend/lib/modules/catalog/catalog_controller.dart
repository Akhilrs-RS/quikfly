import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:quikfly_core/quikfly_core.dart';
import '../../database/mysql_db.dart';

class CatalogController {
  Router get router {
    final router = Router();

    // GET /api/v1/home/feed
    router.get('/home/feed', (Request request) async {
      try {
        final db = DatabaseService.instance;
        final user = await db.getUserProfile();
        final heroBanners = await db.getBanners(type: 'hero');
        final services = await db.getServices(featuredOnly: true);
        final merchants = await db.getPopularMerchants();
        final safetyBanners = await db.getBanners(type: 'safety');

        final feed = HomeFeedDTO(
          user: user,
          heroBanners: heroBanners,
          services: services,
          popularMerchants: merchants,
          safetyBanner: safetyBanners.isNotEmpty ? safetyBanners.first : null,
        );

        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': feed.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e, stack) {
        print('Error in /home/feed: $e\n$stack');
        return Response.internalServerError(
          body: jsonEncode({'status': 'error', 'message': e.toString()}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    // GET /api/v1/explore
    router.get('/explore', (Request request) async {
      try {
        final categoryParam = request.url.queryParameters['category'] ?? 'all';
        final db = DatabaseService.instance;

        final allServices = await db.getServices(
          category: categoryParam != 'all' ? categoryParam : null,
        );
        final stories = await db.getBanners(type: 'story');
        final travelServices = await db.getServices(category: 'travel');

        final exploreDTO = ExploreFeedDTO(
          categories: ['all', 'everyday', 'travel', 'shopping'],
          services: allServices,
          weekendInspiration: stories.isNotEmpty ? stories.first : null,
          travelOfferings: travelServices,
        );

        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': exploreDTO.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e, stack) {
        print('Error in /explore: $e\n$stack');
        return Response.internalServerError(
          body: jsonEncode({'status': 'error', 'message': e.toString()}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    // GET /api/v1/services
    router.get('/services', (Request request) async {
      try {
        final db = DatabaseService.instance;
        final services = await db.getServices();
        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': services.map((s) => s.toJson()).toList(),
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'status': 'error', 'message': e.toString()}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    return router;
  }
}
