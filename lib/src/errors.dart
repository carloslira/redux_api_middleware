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
  String message;
  int status;
  String statusText;
  dynamic response;

  APIError(int status, String statusText, dynamic response) {
    this.status = status;
    this.statusText = statusText;
    this.response = response;
    this.message = '${status} - ${statusText}';
  }
}
