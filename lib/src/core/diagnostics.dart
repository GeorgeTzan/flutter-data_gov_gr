import '../exceptions/data_gov_exception.dart';

/// Removes credential headers, secret URL parameters, and URL user information.
String sanitizeDiagnostic(String value) => sanitizeExceptionText(value);
