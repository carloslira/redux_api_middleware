import 'package:redux_api_middleware/src/rsaa.dart';

const validCallAPIKeys = [
  'endpoint',
  'options',
  'method',
  'body',
  'headers',
  'credentials',
  'bailout',
  'types',
  'fetch',
  'ok'
];

const validHTTPMethods = [
  'GET',
  'HEAD',
  'POST',
  'PUT',
  'PATCH',
  'DELETE',
  'OPTIONS',
];

const validCredentials = [
  'omit',
  'same-origin',
  'include',
];

bool isMap(obj) {
  return (obj != null && obj.entries != null);
}

bool isRSAA(action) {
  return isMap(action) && action.containsKey(RSAA);
}

bool isValidTypeDescriptor(obj) {
  const validKeys = [
    'type',
    'payload',
    'meta',
  ];

  if (!isMap(obj)) {
    return false;
  }

  for (var key in obj) {
    if (!validKeys.contains(key)) {
      return false;
    }
  }

  if (!validKeys.contains('type')) {
    return false;
  } else if (obj['type'] is! String) {
    return false;
  }

  return true;
}

List<String> validateRSAA(action) {
  List<String> errors = [];

  if (!isRSAA(action)) {
    errors.add(
        'RSAAs must be Map<String, dynamic> objects with an [RSAA] property');
  }

  var callAPI = action[RSAA];
  if (!isMap(callAPI)) {
    errors.add('[RSAA] property must be a Map<String, dynamic> object');
  }

  for (var key in callAPI.keys) {
    if (!validCallAPIKeys.contains(key)) {
      errors.add('Invalid [RSAA] key: $key');
    }
  }

  var endpoint = callAPI['endpoint'];
  var method = callAPI['method'];
  var headers = callAPI['headers'];
  var options = callAPI['options'];
  var credentials = callAPI['credentials'];
  var types = callAPI['types'];
  var bailout = callAPI['bailout'];
  var fetch = callAPI['fetch'];
  var ok = callAPI['ok'];

  if (endpoint == null || endpoint == '') {
    errors.add('[RSAA] must have a endpoint property');
  } else if (endpoint is! String && endpoint is! Function) {
    errors.add('[RSAA].endpoint property must be a String or a Function');
  }

  if (method == null || method == '') {
    errors.add('[RSAA] must have a method property');
  } else if (endpoint is! String) {
    errors.add('[RSAA].method property must be a String');
  } else if (!validHTTPMethods.contains(method.toUpperCase())) {
    errors.add('Invalid [RSAA].method: ${method.toUpperCase()}');
  }

  if (headers != null && !isMap(headers) && headers is! Function) {
    errors.add(
        '[RSAA].headers property must be a Map<String, dynamic> object, or a Function');
  }

  if (options != null && !isMap(options) && options is! Function) {
    errors.add(
        '[RSAA].options property must be a Map<String, dynamic> object, or a Function');
  }

  if (credentials != null) {
    if (credentials is! String) {
      errors.add('[RSAA].credentials property must be a String');
    } else if (!validCredentials.contains(credentials)) {
      errors.add('Invalid [RSAA].credentials: $credentials');
    }
  }

  if (bailout != null && bailout is! bool && bailout is! Function) {
    errors.add('[RSAA].bailout property must be a bool, or a Function');
  }

  if (types == null) {
    errors.add('[RSAA] must have a types property');
  } else if (types is! List<String> || types.length != 3) {
    errors.add('[RSAA].types property must be an List of length 3');
  } else {
    var requestType = types[0];
    var successType = types[1];
    var failureType = types[2];

    if (requestType is! String && !isValidTypeDescriptor(requestType)) {
      errors.add('Invalid request type');
    }

    if (successType is! String && !isValidTypeDescriptor(successType)) {
      errors.add('Invalid success type');
    }

    if (failureType is! String && !isValidTypeDescriptor(failureType)) {
      errors.add('Invalid failure type');
    }
  }

  if (fetch != null && fetch is! Function) {
    errors.add('[RSAA].fetch property must be a Function');
  }

  if (ok != null && ok is! Function) {
    errors.add('[RSAA].ok property must be a Function');
  }

  return errors;
}
