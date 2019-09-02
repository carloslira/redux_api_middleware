import 'dart:convert';

import 'package:redux/redux.dart';

import 'package:http/http.dart' as http;
import 'package:redux_api_middleware/src/fsa.dart';
import 'package:redux_api_middleware/src/rsaa.dart';
import 'package:redux_api_middleware/src/errors.dart';

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

List<FSA> normalizeFSAs(List<dynamic> types) {
  dynamic requestType = types[0];
  dynamic successType = types[1];
  dynamic failureType = types[2];

  if (requestType is String) {
    requestType = FSA(type: requestType as String);
  }

  if (successType is String) {
    successType = FSA(type: successType as String);
  }
  successType.payload = (RSAA action, Store store, http.StreamedResponse response) => getJSON(response);

  if (failureType is String) {
    failureType = FSA(type: failureType as String);
  }
  failureType.payload = (RSAA action, Store store, http.StreamedResponse response) {
    getJSON(response).then((dynamic jsonObj) => APIError(response.statusCode, response.reasonPhrase, jsonObj));
  };

  return [
    requestType as FSA,
    successType as FSA,
    failureType as FSA,
  ];
}

Future<FSA> normalizeFSA(FSA fsa, [RSAA action, Store store, http.StreamedResponse response]) async {
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
