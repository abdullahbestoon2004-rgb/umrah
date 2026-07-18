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

  print('Fetching packages from live database...');
  final url = Uri.parse('$baseUrl/rest/v1/packages?select=id,title,title_en,is_published');
  final res = await http.get(url, headers: headers);
  
  if (res.statusCode != 200) {
    print('Failed with status code ${res.statusCode}:');
    print(res.body);
    return;
  }
  
  final List<dynamic> packages = jsonDecode(res.body);
  print('Found ${packages.length} packages:');
  for (final pkg in packages) {
    print(' - ID: ${pkg['id']}, Title (EN): ${pkg['title_en']}, Published: ${pkg['is_published']}');
  }
}
