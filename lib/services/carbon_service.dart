import 'dart:convert';
import 'package:http/http.dart' as http;

class CarbonService {
  final String _baseUrl = "https://api.carbonintensity.org.uk";

  Future<Map<String, dynamic>> getCarbonIntensity() async {
    final response = await http.get(Uri.parse("$_baseUrl/intensity"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load carbon intensity data");
    }
  }
}
