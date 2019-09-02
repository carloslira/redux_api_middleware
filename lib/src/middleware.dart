import 'package:redux/redux.dart';

import 'package:http/http.dart' as http;

import 'package:redux_api_middleware/src/rsaa.dart';
import 'package:redux_api_middleware/src/utils.dart';
import 'package:redux_api_middleware/src/errors.dart';
import 'package:redux_api_middleware/src/validation.dart';
import 'package:redux_api_middleware/src/type_descriptor.dart';

void apiMiddleware<State>(
  Store<State> store,
  dynamic action,
  NextDispatcher next,
) async {
  if (action is! RSAA) {
    next(action); return;
  }

  RSAA rsaa = action as RSAA;

  List<String> validationErrors = validateRSAA(rsaa);
  if (validationErrors.isNotEmpty) {
    if (rsaa.types != null && rsaa.types.isNotEmpty) {
      handleInvalidRSAA(rsaa, next, validationErrors);
    }

    return;
  }

  List<TypeDescriptor> types = normalizeTypeDescriptors(rsaa.types);

  TypeDescriptor requestType = types[0];
  TypeDescriptor successType = types[1];
  TypeDescriptor failureType = types[2];

  try {
    if (rsaa.bailout != null) {
      if (
        (rsaa.bailout is bool && rsaa.bailout as bool) || 
        (rsaa.bailout is Function && rsaa.bailout(store) as bool)
      ) {
        return;
      }
    }
  } catch(e) {
    await handleError(store, rsaa, next, requestType, RequestError('RSAA bailout function failed')); return;
  }

  String endpoint = await normalizeEndpoint(store, rsaa, next, requestType);
  String body = await normalizeBody(store, rsaa, next, requestType);
  Map<String, String> headers = await normalizeHeaders(store, rsaa, next, requestType);
  Map<String, String> options = await normalizeOptions(store, rsaa, next, requestType);

  if (requestType.payload is Function || requestType.meta is Function) {
    next(
      await actionWith(
        requestType,
        rsaa,
        store,
      ),      
    );
  }

  http.StreamedResponse response;

  try {
    http.Client client = http.Client();
    http.Request request = http.Request(rsaa.method, Uri.parse(endpoint));

    if (body != null) {
      request.body = body;
    }

    if (headers != null) {
      headers.forEach((k, v) => request.headers[k] = v);
    }

    response = await client.send(request);
  } catch (e) {
      await handleError(store, rsaa, next, requestType, RequestError(e.toString())); return;
  }

  if (response.statusCode == 200) {
    next(
      await actionWith(
        successType,
        rsaa,
        store,
        response,
      ),
    );

    return;
  } else {
    failureType.error = true;

    next(
      await actionWith(
        failureType,
        rsaa,
        store,
        response,
      ),
    );
  }
}

void handleInvalidRSAA(RSAA rsaa, NextDispatcher next, List<String> validationErrors) {
  String requestType = rsaa.types[0] as String;

  next(
    TypeDescriptor(
      type: requestType,
      payload: InvalidRSAA(validationErrors),
      error: true,
    ),
  );
}

Future<String> normalizeEndpoint(Store store, RSAA rsaa, NextDispatcher next, TypeDescriptor descriptor) async {
  String endpoint;
  if (rsaa.endpoint is Function) {
    try {
      endpoint = rsaa.endpoint(store) as String;
    } catch(e) {
      await handleError(store, rsaa, next, descriptor, RequestError('RSAA endpoint function failed'));
    }
  } else {
    endpoint = rsaa.endpoint as String;
  }

  return endpoint;
}

Future<String> normalizeBody(Store store, RSAA rsaa, NextDispatcher next, TypeDescriptor descriptor) async {
  String body;
  if (rsaa.body is Function) {
    try {
      body = rsaa.body(store) as String;
    } catch(e) {
      await handleError(store, rsaa, next, descriptor, RequestError('RSAA body function failed'));
    }
  } else {
    body = rsaa.body as String;
  }

  return body;
}

Future<Map<String, String>> normalizeHeaders(Store store, RSAA rsaa, NextDispatcher next, TypeDescriptor descriptor) async {
  Map<String, String> headers;
  if (rsaa.headers is Function) {
    try {
      headers = rsaa.headers(store) as Map<String, String>;
    } catch(e) {
      await handleError(store, rsaa, next, descriptor, RequestError('RSAA headers function failed'));
    }
  } else {
    headers = rsaa.headers as Map<String, String>;
  }

  return headers;
}

Future<Map<String, String>> normalizeOptions(Store store, RSAA rsaa, NextDispatcher next, TypeDescriptor descriptor) async {
  Map<String, String> options;
  if (rsaa.options is Function) {
    try {
      options = rsaa.options(store) as Map<String, String>;
    } catch(e) {
      await handleError(store, rsaa, next, descriptor, RequestError('RSAA options function failed'));
    }
  } else {
    options = rsaa.options as Map<String, String>;
  }

  return options;
}

void handleError(Store store, RSAA rsaa, NextDispatcher next, TypeDescriptor descriptor, Error err) async {
  descriptor.error = true;
  descriptor.payload = err;

  next(
    await actionWith(
      descriptor,
      rsaa,
      store,
    ),
  );
}
