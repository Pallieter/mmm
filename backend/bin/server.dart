import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:backend/database_service.dart';
import 'package:backend/node_repository.dart';
import 'package:backend/node_api.dart';
import 'package:path/path.dart' as p;

Middleware corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        });
      }
      final response = await handler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
      });
    };
  };
}

void main(List<String> args) async {
  // Fail fast if required env vars are missing
  final dbHost = Platform.environment['DB_HOST'];
  final dbUser = Platform.environment['DB_USER'];
  final dbPass = Platform.environment['DB_PASS'];
  final dbName = Platform.environment['DB_NAME'];

  if (dbHost == null || dbUser == null || dbPass == null || dbName == null) {
    print('Error: Missing required environment variables.');
    print('Please set DB_HOST, DB_USER, DB_PASS, and DB_NAME.');
    exit(1);
  }

  final dbPort = int.tryParse(Platform.environment['DB_PORT'] ?? '3306') ?? 3306;

  final db = DatabaseService(
    host: dbHost,
    port: dbPort,
    user: dbUser,
    password: dbPass,
    database: dbName,
  );

  try {
     // await db.connect();
     // await db.initSchema();
     print('Database connection initialized (lazy).');
  } catch (e) {
    print('Failed to connect to DB: $e');
    // If DB is strictly required for startup, exit(1) here.
  }

  final nodeRepo = NodeRepository(db);
  final nodeApi = NodeApi(nodeRepo);

  final app = Router();
  app.mount('/api/nodes/', nodeApi.router);

  // Serve static files from 'public' directory
  final staticHandler = createStaticHandler('public', defaultDocument: 'index.html');

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler((request) {
        if (request.url.path.startsWith('api/')) {
          return app(request);
        }
        return staticHandler(request);
      });

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Server listening on port ${server.port}');
}
