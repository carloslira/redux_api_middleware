import 'dart:convert';

import 'package:redux/redux.dart';

import 'package:http/http.dart' as http;

import 'package:redux_api_middleware/src/rsaa.dart';
import 'package:redux_api_middleware/src/errors.dart';
import 'package:redux_api_middleware/src/type_descriptor.dart';

Future<dynamic> getJSON(http.StreamedResponse response) async {
  String contentType = response.headers['Content-Type'];
  const emptyCodes = [204, 205];

  if (!emptyCodes.contains(response.statusCode) &&
      (contentType != null && contentType.contains('json'))) {
    return await response.stream.bytesToString().then<dynamic>((text) {
      return json.decode(text);
    });
  }

  return null;
}

List<TypeDescriptor> normalizeTypeDescriptors(List<dynamic> types) {
  dynamic requestType = types[0];
  dynamic successType = types[1];
  dynamic failureType = types[2];

  if (requestType is String) {
    requestType = TypeDescriptor(type: requestType as String);
  }

  if (successType is String) {
    successType = TypeDescriptor(type: successType as String);
  }
  successType.payload = (RSAA action, Store store, http.StreamedResponse response) => getJSON(response);

  if (failureType is String) {
    failureType = TypeDescriptor(type: failureType as String);
  }
  failureType.payload = (RSAA action, Store store, http.StreamedResponse response) {
    getJSON(response).then((dynamic jsonObj) => APIError(response.statusCode, response.reasonPhrase, jsonObj));
  };

  return [
    requestType as TypeDescriptor,
    successType as TypeDescriptor,
    failureType as TypeDescriptor,
  ];
}

Future<TypeDescriptor> actionWith(TypeDescriptor descriptor, [RSAA action, Store store, http.StreamedResponse response]) async {
  try {
    descriptor.payload = descriptor.payload is Function
        ? await descriptor.payload(action, store, response)
        : descriptor.payload;
  } catch (e) {
    descriptor.payload = InternalError(e.toString());
    descriptor.error = true;
  }

  try {
    descriptor.meta = descriptor.meta is Function
        ? await descriptor.meta(action, store, response)
        : descriptor.meta;
  } catch (e) {
    descriptor.meta = InternalError(e.toString());
    descriptor.error = true;
  }

  return descriptor;
}
