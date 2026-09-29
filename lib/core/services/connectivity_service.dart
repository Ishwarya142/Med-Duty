import 'package:http/http.dart' as http;

/// Checks network connectivity with a lightweight HTTP probe.
class ConnectivityService {
  Future<bool> hasInternet() async {
    try {
      final response = await http
          .head(Uri.parse('https://www.google.com/generate_204'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}
