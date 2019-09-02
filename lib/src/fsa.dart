import 'package:meta/meta.dart';

class FSA {
  final String type;
  dynamic payload;
  dynamic meta;
  bool error;

  FSA({
    @required this.type,
    this.payload,
    this.meta,
    this.error,
  });
}
