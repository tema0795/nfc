String platformBaseUrl() {
  final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
  final scheme = Uri.base.scheme.isEmpty ? 'http' : Uri.base.scheme;
  return '$scheme://$host:8000';
}
