import 'dart:convert';

import 'package:redux/redux.dart';

import 'package:http/http.dart' as http;
import 'package:redux_api_middleware/src/errors.dart';
import 'package:redux_api_middleware/src/type_descriptor.dart';

Future getJSON(http.StreamedResponse response) async {
  const emptyCodes = [204, 205];

  if (!emptyCodes.contains(response.statusCode)) {
    final String str = await response.stream.bytesToString();
    return json.decode(str);
  }

  return null;
}

List<TypeDescriptor> normalizeTypeDescriptors(List<dynamic> types) {
  var requestType = types[0];
  var successType = types[1];
  var failureType = types[2];

  if (requestType is String) {
    requestType = TypeDescriptor(type: requestType);
  }

  if (successType is String) {
    successType = TypeDescriptor(type: successType);
  }

  successType.payload = (Map<String, dynamic> action, dynamic state,
          http.StreamedResponse response) =>
      getJSON(response);

  if (failureType is String) {
    failureType = TypeDescriptor(type: failureType);
  }

  failureType.payload = (Map<String, dynamic> action, dynamic state,
          http.StreamedResponse response) =>
      getJSON(response).then(
          (json) => APIError(response.statusCode, response.reasonPhrase, json));

  return [
    requestType as TypeDescriptor,
    successType as TypeDescriptor,
    failureType as TypeDescriptor,
  ];
}

Future<Map<String, dynamic>> actionWith(TypeDescriptor descriptor,
    [Map<String, dynamic> action,
    dynamic state,
    http.StreamedResponse response]) async {
  try {
    descriptor.payload = descriptor.payload is Function
        ? await descriptor.payload(action, state, response)
        : descriptor.payload;
  } catch (e) {
    descriptor.payload = InternalError(e.toString());
    descriptor.error = true;
  }

  try {
    descriptor.meta = descriptor.meta is Function
        ? await descriptor.meta(action, state, response)
        : descriptor.meta;
  } catch (e) {
    descriptor.meta = InternalError(e.toString());
    descriptor.error = true;
  }

  return {
    'type': descriptor.type,
    'payload': descriptor.payload,
    'meta': descriptor.meta,
    'error': descriptor.error,
  };
}
