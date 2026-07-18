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

  print('Fetching details for package f9844a3f-ea87-4ee0-a3fa-85b74abe132d...');
  final url = Uri.parse('$baseUrl/rest/v1/packages?id=eq.f9844a3f-ea87-4ee0-a3fa-85b74abe132d&select=*');
  final res = await http.get(url, headers: headers);
  
  if (res.statusCode != 200) {
    print('Failed: ${res.body}');
    return;
  }
  
  print(res.body);
}
