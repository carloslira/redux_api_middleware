class InvalidRSAA extends Error {
  final String name = 'InvalidRSAA';
  final String message = 'Invalid RSAA';
  final List<String> validationErrors;

  InvalidRSAA(this.validationErrors);
}

class InternalError extends Error {
  final String name = 'InternalError';
  final String message;

  InternalError(this.message);
}

class RequestError extends Error {
  final String name = 'RequestError';
  final String message;

  RequestError(this.message);
}

class APIError extends Error {
  final String name = 'APIError';
  final String message;
  final int status;
  final String? statusText;
  final dynamic response;

  APIError(this.status, this.statusText, this.response)
      : message = '$status - $statusText';
}
