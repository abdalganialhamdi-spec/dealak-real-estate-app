class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, this.statusCode, this.errors});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException() : super(message: 'غير مصرح، يرجى تسجيل الدخول', statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException() : super(message: 'غير مصرح بهذا الإجراء', statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException() : super(message: 'المورد غير موجود', statusCode: 404);
}

class ValidationException extends ApiException {
  ValidationException(Map<String, dynamic> errors)
      : super(message: 'بيانات غير صالحة', statusCode: 422, errors: errors);
}

class ServerException extends ApiException {
  ServerException() : super(message: 'خطأ في الخادم', statusCode: 500);
}

class NetworkException extends ApiException {
  NetworkException() : super(message: 'لا يوجد اتصال بالإنترنت');
}
