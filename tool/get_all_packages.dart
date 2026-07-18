import 'dart:convert';
import 'package:http/http.dart' as http;
import '../lib/supabase_config.dart';

void main() async {
  final baseUrl = SupabaseConfig.url;
  final apikey = SupabaseConfig.publishableKey;
  
  final headers = {
    'apikey': apikey,
    'Content-Type': 'application/json',
  };

  print('Fetching all packages and their departure dates...');
  final url = Uri.parse('$baseUrl/rest/v1/packages?select=id,title_en,departure_date,lifecycle_status,is_published');
  final res = await http.get(url, headers: headers);
  
  if (res.statusCode != 200) {
    print('Failed: ${res.body}');
    return;
  }
  
  final List<dynamic> packages = jsonDecode(res.body);
  for (final pkg in packages) {
    print('ID: ${pkg['id']} | Title: ${pkg['title_en']} | Departure: ${pkg['departure_date']} | Status: ${pkg['lifecycle_status']} | Published: ${pkg['is_published']}');
  }
}
