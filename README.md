# redux_api_middleware

[Redux](https://pub.dartlang.org/packages/redux) middleware for calling APIs.

The `apiMiddleware` intercepts and calls [*Redux Standard API-calling Actions*](#redux-standard-api-calling-actions) (RSAAs), and dispatches [*Flux Standard Actions*](#flux-standard-actions) (FSAs) to the next middleware.


### Redux Standard API-calling Actions

The definition of a *Redux Standard API-calling Action* below is the one used to validate RSAA actions.
  - actions that are not instances of `RSAA` will be passed to the next middleware without any modifications;
  - actions that are instancesof `RSAA` that fail validation will result in an error *request* FSA.

A *Redux Standard API-calling Action* MUST

- be a `RSAA` instance,

### Flux Standard Actions

For convenience, we recall here the definition of a [*Flux Standard Action*](https://github.com/acdlite/flux-standard-action).

An action MUST

- be a `RSAA` instance,
- have a `type` property.

An action MAY

- have an `error` property,
- have a `payload` property,
- have a `meta` property.


## Credits

This lib is [redux-api-middleware](https://github.com/agraboso/redux-api-middleware) library simply adapted to Dart.