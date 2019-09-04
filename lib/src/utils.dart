import 'dart:convert';

import 'package:redux/redux.dart';

import 'package:http/http.dart' as http;
import 'package:redux_api_middleware/src/fsa.dart';
import 'package:redux_api_middleware/src/rsaa.dart';
import 'package:redux_api_middleware/src/errors.dart';
import 'package:redux_api_middleware/src/type_descriptor.dart';

Future<dynamic> getJSON(http.StreamedResponse response) async {
  String contentType = response.headers['content-type'];
  const emptyCodes = [204, 205];

  if (!emptyCodes.contains(response.statusCode) &&
      (contentType != null && contentType.contains('json'))) {
    return await response.stream.bytesToString().then<dynamic>((text) {
      return json.encode(text);
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
  successType.payload =
      (RSAA action, Store store, http.StreamedResponse response) =>
          getJSON(response);

  if (failureType is String) {
    failureType = TypeDescriptor(type: failureType as String);
  }
  failureType.payload =
      (RSAA action, Store store, http.StreamedResponse response) {
    getJSON(response).then((dynamic jsonObj) =>
        APIError(response.statusCode, response.reasonPhrase, jsonObj));
  };

  return [
    requestType as TypeDescriptor,
    successType as TypeDescriptor,
    failureType as TypeDescriptor,
  ];
}

Future<FSA> prepareFSA(TypeDescriptor descriptor,
    [RSAA action, Store store, http.StreamedResponse response]) async {
  FSA fsa = FSA(
    type: descriptor.type,
    payload: descriptor.payload,
    meta: descriptor.meta,
    error: descriptor.error,
  );

  try {
    fsa.payload = fsa.payload is Function
        ? await fsa.payload(action, store, response)
        : fsa.payload;
  } catch (e) {
    fsa.payload = InternalError(e.toString());
    fsa.error = true;
  }

  try {
    fsa.meta = fsa.meta is Function
        ? await fsa.meta(action, store, response)
        : fsa.meta;
  } catch (e) {
    fsa.meta = InternalError(e.toString());
    fsa.error = true;
  }

  return fsa;
}
