import 'package:redux/redux.dart';

import 'package:redux_api_middleware/redux_api_middleware.dart';

void main() {
  // First, create a quick reducer
  String reducer(String state, dynamic action) {
    switch (action.type) {
      case 'request':
        return 'dispatched a request :)';
      case 'success':
        return 'dispatched a success :D';
      case 'failure':
        return 'dispatched a failure :(';
      default:
        return state;
    }
  }

  // Next, apply the `apiMiddleware` to the Store
  final store = Store<String>(
    reducer,
    middleware: [apiMiddleware],
  );

  // Create a `RSAA`.
  var rsaa = RSAA(
    method: 'GET',
    endpoint: 'http://url.com/api/test',
    types: [
      'request',
      'success',
      'failure',
    ],
  );

  // Dispatch the action! The `apiMiddleware` will intercept and invoke
  // the action function. It will go to the reduces as an FSA.
  store.dispatch(rsaa);
}
