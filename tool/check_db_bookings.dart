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

  print('=== REAL-TIME DATABASE INSPECTION ===');

  // 1. Fetch profiles (users)
  print('\n--- Users / Profiles ---');
  final profilesUrl = Uri.parse('$baseUrl/rest/v1/profiles?select=id,full_name,role');
  final profilesRes = await http.get(profilesUrl, headers: headers);
  if (profilesRes.statusCode == 200) {
    final List<dynamic> profiles = jsonDecode(profilesRes.body);
    for (final p in profiles) {
      print('Profile ID: ${p['id']} | Name: ${p['full_name']} | Role: ${p['role']}');
    }
  } else {
    print('Failed to fetch profiles: ${profilesRes.body}');
  }

  // 2. Fetch bookings
  print('\n--- All Bookings ---');
  final bookingsUrl = Uri.parse('$baseUrl/rest/v1/bookings?select=id,client_id,ref,status,operational_stage,created_at');
  final bookingsRes = await http.get(bookingsUrl, headers: headers);
  if (bookingsRes.statusCode == 200) {
    final List<dynamic> bookings = jsonDecode(bookingsRes.body);
    for (final b in bookings) {
      print('Booking ID: ${b['id']} | Client ID: ${b['client_id']} | Ref: ${b['ref']} | Status: ${b['status']} | Stage: ${b['operational_stage']} | Created: ${b['created_at']}');
    }
  } else {
    print('Failed to fetch bookings: ${bookingsRes.body}');
  }
}
