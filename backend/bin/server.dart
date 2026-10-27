import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import '../lib/database/mysql_db.dart';
import '../lib/modules/catalog/catalog_controller.dart';

void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;

  print('🚀 Initializing QuikFly Full-Stack Dart Backend...');

  // Initialize Database connection
  await DatabaseService.instance.initialize();

  // Root router
  final app = Router();

  // Healthcheck endpoint
  app.get('/health', (Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'healthy',
        'service': 'quikfly_backend',
        'timestamp': DateTime.now().toIso8601String(),
        'mysql_connected': DatabaseService.instance.isConnected,
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // Mount API V1 routes
  final catalogController = CatalogController();
  app.mount('/api/v1/', catalogController.router.call);

  // Middleware pipeline: Logging -> CORS -> Router
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(
        headers: {
          ACCESS_CONTROL_ALLOW_ORIGIN: '*',
          ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PUT, DELETE, OPTIONS',
          ACCESS_CONTROL_ALLOW_HEADERS: 'Origin, Content-Type, Authorization, Accept',
        },
      ))
      .addHandler(app.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('====================================================');
  print('✨ QuikFly Dart Backend is live on: http://${server.address.host}:${server.port}');
  print('📍 Health Check: http://localhost:${server.port}/health');
  print('🏠 Home Feed:    http://localhost:${server.port}/api/v1/home/feed');
  print('🔍 Explore Feed: http://localhost:${server.port}/api/v1/explore');
  print('📦 Orders:       http://localhost:${server.port}/api/v1/orders');
  print('🎫 Bookings:     http://localhost:${server.port}/api/v1/bookings');
  print('👤 Profile:      http://localhost:${server.port}/api/v1/profile');
  print('====================================================');

  ProcessSignal.sigint.watch().listen((_) async {
    print('Shutting down QuikFly server...');
    await server.close(force: true);
    exit(0);
  });
}
