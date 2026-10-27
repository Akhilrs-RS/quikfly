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

    // GET /api/v1/orders
    router.get('/orders', (Request request) async {
      try {
        final statusParam = request.url.queryParameters['status'];
        final db = DatabaseService.instance;
        final orders = await db.getOrders(status: statusParam);
        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': orders.map((o) => o.toJson()).toList(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // GET /api/v1/bookings
    router.get('/bookings', (Request request) async {
      try {
        final db = DatabaseService.instance;
        final bookings = await db.getBookings();
        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': bookings.map((b) => b.toJson()).toList(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // GET /api/v1/profile
    router.get('/profile', (Request request) async {
      try {
        final db = DatabaseService.instance;
        final profile = await db.getUserProfile();
        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': profile.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // POST /api/v1/orders (Place new order or Reorder)
    router.post('/orders', (Request request) async {
      try {
        final body = await request.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final db = DatabaseService.instance;

        final newOrder = await db.createOrder(
          vendorName: json['vendor_name'] as String? ?? 'QuikFly Merchant',
          category: json['category'] as String? ?? 'FOOD',
          totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
          itemsSummary: json['items_summary'] as String? ?? 'Standard items',
        );

        return Response(
          201,
          body: jsonEncode({
            'status': 'success',
            'data': newOrder.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // POST /api/v1/orders/<id>/cancel
    router.post('/orders/<id>/cancel', (Request request, String id) async {
      try {
        final orderId = int.tryParse(id) ?? 0;
        final db = DatabaseService.instance;
        final updated = await db.cancelOrder(orderId);
        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': updated?.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // POST /api/v1/bookings (Create bus/rental/getaway booking)
    router.post('/bookings', (Request request) async {
      try {
        final body = await request.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final db = DatabaseService.instance;

        final newBooking = await db.createBooking(
          title: json['title'] as String? ?? 'Trip Booking',
          subtitle: json['subtitle'] as String? ?? 'Confirmed',
          price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
          route: json['route'] as String?,
          seatNo: json['seat_no'] as String?,
        );

        return Response(
          201,
          body: jsonEncode({
            'status': 'success',
            'data': newBooking.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // POST /api/v1/bookings/<id>/cancel
    router.post('/bookings/<id>/cancel', (Request request, String id) async {
      try {
        final bookingId = int.tryParse(id) ?? 0;
        final db = DatabaseService.instance;
        final updated = await db.cancelBooking(bookingId);
        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': updated?.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // POST /api/v1/rides/book (Quick Ride)
    router.post('/rides/book', (Request request) async {
      try {
        final body = await request.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final db = DatabaseService.instance;

        final booking = await db.bookRide(
          pickupAddress: json['pickup_address'] as String? ?? 'Indiranagar, Bengaluru',
          dropAddress: json['drop_address'] as String? ?? 'Kempegowda Airport T1',
          fare: double.tryParse(json['fare']?.toString() ?? '249') ?? 249.0,
          serviceCode: json['service_code'] as String? ?? 'car_taxi',
        );

        return Response(
          201,
          body: jsonEncode({
            'status': 'success',
            'data': booking.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // PUT /api/v1/profile (Update name, phone, email, locality)
    router.put('/profile', (Request request) async {
      try {
        final body = await request.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final db = DatabaseService.instance;

        final updated = await db.updateUserProfile(
          fullName: json['full_name'] as String? ?? 'Arjun Kumar',
          phone: json['phone'] as String? ?? '+919876548219',
          email: json['email'] as String? ?? 'arjun.kumar@quikfly.app',
          activeLocality: json['active_locality'] as String?,
        );

        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': updated.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // POST /api/v1/wallet/topup
    router.post('/wallet/topup', (Request request) async {
      try {
        final body = await request.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final amount = double.tryParse(json['amount']?.toString() ?? '500') ?? 500.0;
        final db = DatabaseService.instance;
        final newBalance = await db.topupWallet(amount);

        return Response.ok(
          jsonEncode({
            'status': 'success',
            'wallet_balance': newBalance,
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // GET /api/v1/preferences
    router.get('/preferences', (Request request) async {
      try {
        final db = DatabaseService.instance;
        final prefs = await db.getUserPreferences();
        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': prefs.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // PUT /api/v1/preferences
    router.put('/preferences', (Request request) async {
      try {
        final body = await request.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final db = DatabaseService.instance;

        final updated = await db.updateUserPreferences(
          pushNotifications: json['push_notifications'] as bool?,
          promotionalAlerts: json['promotional_alerts'] as bool?,
          biometricLock: json['biometric_lock'] as bool?,
          language: json['language'] as String?,
        );

        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': updated.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // GET /api/v1/addresses
    router.get('/addresses', (Request request) async {
      try {
        final db = DatabaseService.instance;
        final list = await db.getAddresses();
        return Response.ok(
          jsonEncode({
            'status': 'success',
            'data': list.map((a) => a.toJson()).toList(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // POST /api/v1/addresses
    router.post('/addresses', (Request request) async {
      try {
        final body = await request.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final db = DatabaseService.instance;

        final address = await db.createAddress(
          label: json['label'] as String? ?? 'Home',
          addressLine: json['address_line'] as String? ?? '',
          locality: json['locality'] as String? ?? 'Indiranagar',
          city: json['city'] as String? ?? 'Bengaluru',
          latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
          longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
          isDefault: json['is_default'] == true || json['is_default'] == 1 || json['is_default'] == '1',
        );

        return Response(
          201,
          body: jsonEncode({
            'status': 'success',
            'data': address.toJson(),
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // PUT /api/v1/addresses/<id>/default
    router.put('/addresses/<id>/default', (Request request, String id) async {
      try {
        final addressId = int.tryParse(id) ?? 0;
        final db = DatabaseService.instance;
        final success = await db.setDefaultAddress(addressId);
        return Response.ok(
          jsonEncode({
            'status': success ? 'success' : 'failed',
            'message': success ? 'Address set as default' : 'Could not set default address',
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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

    // DELETE /api/v1/addresses/<id>
    router.delete('/addresses/<id>', (Request request, String id) async {
      try {
        final addressId = int.tryParse(id) ?? 0;
        final db = DatabaseService.instance;
        final success = await db.deleteAddress(addressId);
        return Response.ok(
          jsonEncode({
            'status': success ? 'success' : 'failed',
            'message': success ? 'Address deleted' : 'Could not delete address',
            'source': db.isConnected ? 'mysql' : 'seed_fallback',
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
