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
  if (!isRSAA(action)) {
    next(action);
    return;
  }

  var callAPI = action[RSAA];

  List<String> validationErrors = validateRSAA(action);
  if (validationErrors.isNotEmpty) {
    if (callAPI['types'] && callAPI['types'] is List) {
      var requestType = callAPI['types'][0];
      if (requestType != null && requestType['type'] != null) {
        requestType = requestType['type'];
      }

      next({
        'type': requestType,
        'payload': InvalidRSAA(validationErrors),
        'error': true,
      });
    }

    return;
  }

  var endpoint = callAPI['endpoint'];
  var body = callAPI['body'];
  var headers = callAPI['headers'];
  var options = callAPI['options'];
  var method = callAPI['method'];
  var credentials = callAPI['credentials'];
  var bailout = callAPI['bailout'];
  var types = callAPI['types'];

  types = normalizeTypeDescriptors(types);

  TypeDescriptor requestType = types[0];
  TypeDescriptor successType = types[1];
  TypeDescriptor failureType = types[2];

  try {
    if ((bailout is bool && bailout) || (bailout is Function && bailout(store.state))) {
      return;
    }
  } catch (e) {
    failureType.payload = InternalError('[RSAA].bailout function failed');
    failureType.error = true;

    next(await actionWith(failureType, action, store.state));

    return;
  }

  if (endpoint is Function) {
    try {
      endpoint = await endpoint(store.state);
    } catch (e) {
      failureType.payload = RequestError('[RSAA].endpoint function failed');
      failureType.error = true;

      next(await actionWith(failureType, action, store.state));

      return;
    }
  }

  if (body is Function) {
    try {
      body = await body(store.state);
    } catch (e) {
      failureType.payload = RequestError('[RSAA].body function failed');
      failureType.error = true;

      next(await actionWith(failureType, action, store.state));

      return;
    }
  }

  if (headers is Function) {
    try {
      headers = await headers(store.state);
    } catch (e) {
      failureType.payload = RequestError('[RSAA].headers function failed');
      failureType.error = true;

      next(await actionWith(failureType, action, store.state));

      return;
    }
  }

  if (options is Function) {
    try {
      options = await options(store.state);
    } catch (e) {
      failureType.payload = RequestError('[RSAA].options function failed');
      failureType.error = true;

      next(await actionWith(failureType, action, store.state));

      return;
    }
  }

  if (requestType.payload == Function || requestType.meta == Function) {
    next(await actionWith(requestType, action, store.state));
  } else {
    next(await actionWith(requestType));
  }

  http.StreamedResponse response;

  try {
    http.Client client = http.Client();
    http.Request request = http.Request(method, Uri.parse(endpoint));

    if (body != null) {
      request.body = body;
    }

    if (headers != null) {
      headers.forEach((k, v) => request.headers[k] = v);
    }

    response = await client.send(request);
  } catch (e) {
    failureType.payload = RequestError(e.toString());
    failureType.error = true;

    next(await actionWith(failureType, action, store.state));

    return;
  }

  if (response.statusCode == 200) {
    next(await actionWith(successType, action, store.state, response));
  } else {
    failureType.error = true;

    next(await actionWith(failureType, action, store.state, response));
  }

  return;
}
