class ServiceResponse {
  final int status;
  final String message;
  final dynamic data;

  ServiceResponse({
    this.status,
    this.message,
    this.data,
  });
}
