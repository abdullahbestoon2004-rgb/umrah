import 'dart:convert';
import 'package:http/http.dart' as http;
import '../lib/supabase_config.dart';

void main() async {
  print('Starting HTTP-based real-time Supabase booking integration test...');
  
  final baseUrl = SupabaseConfig.url;
  final apikey = SupabaseConfig.publishableKey;
  
  final email = 'client_test_${DateTime.now().millisecondsSinceEpoch}@test.com';
  final password = 'TestPassword123!';
  
  final headers = {
    'apikey': apikey,
    'Content-Type': 'application/json',
  };

  print('Step 1: Signing up a new test client user ($email)...');
  final signupUrl = Uri.parse('$baseUrl/auth/v1/signup');
  final signupBody = jsonEncode({
    'email': email,
    'password': password,
  });
  
  final signupRes = await http.post(signupUrl, headers: headers, body: signupBody);
  if (signupRes.statusCode != 200 && signupRes.statusCode != 201) {
    print('ERROR: Signup failed with status code ${signupRes.statusCode}:');
    print(signupRes.body);
    return;
  }
  
  final signupData = jsonDecode(signupRes.body);
  final accessToken = signupData['access_token'];
  final user = signupData['user'];
  if (accessToken == null || user == null) {
    print('ERROR: access_token or user object is missing in signup response.');
    return;
  }
  
  final clientId = user['id'];
  print('SUCCESS: Signed up test client. ID: $clientId');

  // Authenticated headers for REST and RPC requests
  final authHeaders = {
    'apikey': apikey,
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation', // Request details back from POST/RPC if supported
  };

  // We use the real package ID with a future departure date: f9844a3f-ea87-4ee0-a3fa-85b74abe132d
  final packageId = 'f9844a3f-ea87-4ee0-a3fa-85b74abe132d'; 
  
  print('Step 2: Creating a booking request via RPC create_booking_request...');
  final rpcUrl = Uri.parse('$baseUrl/rest/v1/rpc/create_booking_request');
  final rpcBody = jsonEncode({
    'p_package_id': packageId,
    'p_travellers': 2,
    'p_pay_method': 'fib',
    'p_room_occupancy': 2, // 2 = Double occupancy
    'p_contact_phone': '+9647700000000',
    'p_note': 'Real-time test booking from agent',
    'p_request_key': 'test_req_${DateTime.now().millisecondsSinceEpoch}',
    'p_pilgrims': [
      {
        'full_name': 'Realtime Test Pilgrim 1',
        'passport_no': 'A12345678',
        'date_of_birth': '1990-01-01',
        'phone': '+9647700000000',
        'is_lead': true,
      },
      {
        'full_name': 'Realtime Test Pilgrim 2',
        'passport_no': 'B87654321',
        'date_of_birth': '1992-02-02',
        'phone': '+9647711111111',
        'is_lead': false,
      }
    ],
  });

  final rpcRes = await http.post(rpcUrl, headers: authHeaders, body: rpcBody);
  if (rpcRes.statusCode != 200 && rpcRes.statusCode != 201 && rpcRes.statusCode != 204) {
    print('ERROR: Booking request RPC failed with status code ${rpcRes.statusCode}:');
    print(rpcRes.body);
    return;
  }
  print('SUCCESS: Booking request RPC completed.');

  print('Step 3: Querying bookings table to verify the booking is recorded and visible to the client...');
  final queryUrl = Uri.parse('$baseUrl/rest/v1/bookings?client_id=eq.$clientId&select=*');
  final queryRes = await http.get(queryUrl, headers: authHeaders);
  if (queryRes.statusCode != 200) {
    print('ERROR: Querying bookings table failed with status code ${queryRes.statusCode}:');
    print(queryRes.body);
    return;
  }

  final List<dynamic> rows = jsonDecode(queryRes.body);
  print('Retrieved bookings:');
  for (final row in rows) {
    print(' - Booking ID: ${row['id']}, Ref: ${row['ref']}, Status: ${row['status']}, Payment: ${row['payment_status']}, Created At: ${row['created_at']}');
  }
  
  if (rows.isEmpty) {
    print('FAIL: Booking was not found in the bookings table!');
  } else {
    print('PASS: Booking was successfully created and retrieved in real-time!');
  }

  print('Done.');
}
