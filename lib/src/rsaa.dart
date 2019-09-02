import 'package:meta/meta.dart';

class RSAA {
  final dynamic endpoint;
  final dynamic options;
  final String method;
  final dynamic body;
  final dynamic headers;
  final String credentials;
  final dynamic bailout;
  final List<dynamic> types;

  RSAA({
    @required this.endpoint,
    this.options,
    @required this.method,
    this.body,
    this.headers,
    this.credentials,
    this.bailout,
    @required this.types,
  });
}
