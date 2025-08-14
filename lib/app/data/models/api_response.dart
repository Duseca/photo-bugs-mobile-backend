// Generic API Response Model
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
    this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data:
          json['data'] != null && fromJsonT != null
              ? fromJsonT(json['data'])
              : json['data'],
      error: json['error'],
      statusCode: json['statusCode'] ?? json['status_code'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': toJsonT != null ? toJsonT(data as T) : data,
      if (error != null) 'error': error,
      if (statusCode != null) 'statusCode': statusCode,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, error: $error}';
  }
}

// Paginated Response Model
class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int totalPages;
  final int totalItems;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalItems,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = json['data'] as List? ?? [];

    return PaginatedResponse<T>(
      data:
          dataList
              .map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList(),
      page: json['page'] ?? json['currentPage'] ?? 1,
      limit: json['limit'] ?? json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? json['total_pages'] ?? 1,
      totalItems:
          json['totalItems'] ?? json['total_items'] ?? json['total'] ?? 0,
      hasNext: json['hasNext'] ?? json['has_next'] ?? false,
      hasPrevious: json['hasPrevious'] ?? json['has_previous'] ?? false,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
    };
  }

  @override
  String toString() {
    return 'PaginatedResponse{page: $page, totalItems: $totalItems, dataCount: ${data.length}}';
  }
}

// Error Response Model
class ErrorResponse {
  final String message;
  final String? code;
  final int? statusCode;
  final List<ValidationError>? validationErrors;
  final String? stackTrace;

  ErrorResponse({
    required this.message,
    this.code,
    this.statusCode,
    this.validationErrors,
    this.stackTrace,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] ?? json['error'] ?? 'Unknown error',
      code: json['code'] ?? json['errorCode'],
      statusCode: json['statusCode'] ?? json['status_code'],
      validationErrors:
          json['validationErrors'] != null
              ? List<ValidationError>.from(
                json['validationErrors'].map(
                  (x) => ValidationError.fromJson(x),
                ),
              )
              : json['validation_errors'] != null
              ? List<ValidationError>.from(
                json['validation_errors'].map(
                  (x) => ValidationError.fromJson(x),
                ),
              )
              : null,
      stackTrace: json['stackTrace'] ?? json['stack_trace'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (code != null) 'code': code,
      if (statusCode != null) 'statusCode': statusCode,
      if (validationErrors != null)
        'validationErrors': validationErrors!.map((x) => x.toJson()).toList(),
      if (stackTrace != null) 'stackTrace': stackTrace,
    };
  }

  @override
  String toString() {
    return 'ErrorResponse{message: $message, code: $code, statusCode: $statusCode}';
  }
}

// Validation Error Model
class ValidationError {
  final String field;
  final String message;
  final dynamic value;

  ValidationError({required this.field, required this.message, this.value});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
      if (value != null) 'value': value,
    };
  }

  @override
  String toString() {
    return 'ValidationError{field: $field, message: $message}';
  }
}

// File Upload Response Model
class FileUploadResponse {
  final String url;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;

  FileUploadResponse({
    required this.url,
    this.fileName,
    this.fileSize,
    this.mimeType,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      url: json['url'] ?? '',
      fileName: json['fileName'] ?? json['file_name'],
      fileSize: json['fileSize'] ?? json['file_size'],
      mimeType: json['mimeType'] ?? json['mime_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (fileName != null) 'fileName': fileName,
      if (fileSize != null) 'fileSize': fileSize,
      if (mimeType != null) 'mimeType': mimeType,
    };
  }

  @override
  String toString() {
    return 'FileUploadResponse{url: $url, fileName: $fileName}';
  }
}
