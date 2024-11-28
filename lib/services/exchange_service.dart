import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  final String _apiKey = "f465350028d3f5d5ae4e0140"; // Masukkan API Key
  final String _baseUrl = "https://v6.exchangerate-api.com/v6";

  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/$_apiKey/latest/$baseCurrency"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load exchange rate data");
    }
  }
}
