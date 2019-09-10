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

## License

The MIT License (MIT)
Copyright (c) 2019 Carlos Lira

Permission is hereby granted, free of charge, to any
person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the
Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall
be included in all copies or substantial portions of
the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
