class TypeDescriptor {
  final String type;
  dynamic payload;
  dynamic meta;
  bool? error;

  TypeDescriptor({
    required this.type,
    this.payload,
    this.meta,
    this.error,
  });
}
