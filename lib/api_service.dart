import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String nutritionixAppId = 'c64858ce';
  static const String nutritionixAppKey = '4becb344250e5b4b90be011ff0a11ee3';

  Future<List<dynamic>> searchNutritionix(String query) async {
    final url = 'https://trackapi.nutritionix.com/v2/search/instant?query=$query';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-app-id': nutritionixAppId,
        'x-app-key': nutritionixAppKey,
      },
    );
    print('Nutritionix API Response: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['common']; // Adjust according to the actual response structure
    } else {
      throw Exception('Failed to load data from Nutritionix');
    }
  }

  Future<Map<String, dynamic>> getNutritionixFoodDetails(String foodId) async {
    final url = 'https://trackapi.nutritionix.com/v2/natural/nutrients';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'x-app-id': nutritionixAppId,
        'x-app-key': nutritionixAppKey,
        'Content-Type': 'application/json',
      },
      body: json.encode({'query': foodId}),
    );
    print('Nutritionix Food Details API Response: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['foods'][0]; // Adjust according to the actual response structure
    } else {
      throw Exception('Failed to load food details from Nutritionix');
    }
  }
}
