import 'package:redux_api_middleware/src/rsaa.dart';
import 'package:redux_api_middleware/src/type_descriptor.dart';

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

List<String> validateRSAA(RSAA rsaa) {
  List<String> errors = [];

  if (!validHTTPMethods.contains(rsaa.method.toUpperCase())) {
    errors.add('Invalid RSAA method: ${rsaa.method.toUpperCase()}');
  }

  if (rsaa.endpoint is! String && rsaa.endpoint is! Function) {
    errors.add('RSAA endpoint must be a string or a function');
  }

  if (rsaa.headers != null && rsaa.headers is! Map<String, String> && rsaa.headers is! Function) {
    errors.add('RSAA headers can only be a string or a function');
  }

  if (rsaa.options != null && rsaa.options is! Map<String, String> && rsaa.options is! Function) {
    errors.add('RSAA options can only be a string or a function');
  }

  if (rsaa.credentials != null && !validCredentials.contains(rsaa.credentials))  {
    errors.add('Invalid RSAA credentials: ${rsaa.credentials}');
  }

  if (rsaa.bailout != null && rsaa.bailout is! bool && rsaa.bailout is! Function) {
    errors.add('RSAA bailout can only be a bool or a function');
  }

  if (rsaa.types.length != 3) {
    errors.add('RSAA types length must be 3');
  } else {
    dynamic requestType = rsaa.types[0];
    dynamic successType = rsaa.types[1];
    dynamic failureType = rsaa.types[2];

    if (requestType is! String && requestType is! TypeDescriptor) {
      errors.add('Invalid request type');
    }

    if (successType is! String && successType is! TypeDescriptor) {
      errors.add('Invalid success type');
    }

    if (failureType is! String && failureType is! TypeDescriptor) {
      errors.add('Invalid failure type');
    }
  }

  return errors;
}
