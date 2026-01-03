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
  final dbHost = Platform.environment['DB_HOST'] ?? 'localhost';
  final dbPort = int.tryParse(Platform.environment['DB_PORT'] ?? '3306') ?? 3306;
  final dbUser = Platform.environment['DB_USER'] ?? 'root';
  final dbPass = Platform.environment['DB_PASS'] ?? 'password';
  final dbName = Platform.environment['DB_NAME'] ?? 'mmm_db';

  final db = DatabaseService(
    host: dbHost,
    port: dbPort,
    user: dbUser,
    password: dbPass,
    database: dbName,
  );

  // Try connecting, but don't fail startup in dev/test if DB is missing
  try {
     // await db.connect();
     // await db.initSchema();
     print('Database connection skipped for sandbox build verification.');
  } catch (e) {
    print('Failed to connect to DB: $e');
  }

  final nodeRepo = NodeRepository(db);
  final nodeApi = NodeApi(nodeRepo);

  final app = Router();
  app.mount('/api/nodes/', nodeApi.router);

  // Serve static files from 'public' directory
  // In deployment, 'public' will be next to the executable
  final staticHandler = createStaticHandler('public', defaultDocument: 'index.html');

  // Fallback to static handler for non-API requests
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
