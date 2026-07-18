import 'dart:convert';
import 'package:http/http.dart' as http;
import '../lib/supabase_config.dart';

void main() async {
  final baseUrl = SupabaseConfig.url;
  final apikey = SupabaseConfig.publishableKey;
  
  final token = 'eyJhbGciOiJFUzI1NiIsImtpZCI6ImYzYzk3NzQyLTExMzMtNGY3Ni04YmViLWU5ZTZmYzA3YTdjNyIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3d2Z3JkbXplendkd2N5aWN3Z2V2LnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiJmODBmNTgyNy00OTc2LTRkMzUtODNiOC1lN2Y0NWJkZmI5YWEiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzg0MzkxMTY5LCJpYXQiOjE3ODQzODc1NjksImVtYWlsIjoiYWJkdWxsYWJlc3Rvb240MDBAZ21haWwuY29tIiwicGhvbmUiOiIiLCJhcHBfbWV0YWRhdGEiOnsicHJvdmlkZXIiOiJlbWFpbCIsInByb3ZpZGVycyI6WyJlbWFpbCJdfSwidXNlcl9tZXRhZGF0YSI6eyJlbWFpbCI6ImFiZHVsbGFiZXN0b29uNDAwQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJmdWxsX25hbWUiOiJhYmR1bGxhIiwicGhvbmUiOiIwNzUwMjA0NTYzNCIsInBob25lX3ZlcmlmaWVkIjpmYWxzZSwicm9sZSI6ImNsaWVudCIsInN1YiI6ImY4MGY1ODI3LTQ5NzYtNGQzNS04M2I4LWU3ZjQ1YmRmYjlhYSJ9LCJyb2xlIjoiYXV0aGVudGljYXRlZCIsImFhbCI6ImFhbDEiLCJhbXIiOlt7Im1ldGhvZCI6InBhc3N3b3JkIiwidGltZXN0YW1wIjoxNzg0MzgwNDM3fV0sInNlc3Npb25faWQiOiI0MzVmM2E0Ni0xMGE3LTRhZjYtYTVjYi01ODk0ZGY3YjU4NmEiLCJpc19hbm9ueW1vdXMiOmZhbHNlfQ.zwNcHKSANoPKLciRAoV-Cg9hnnlVAjSLfS9vHtHZz_L5Kb4vVg1eYcffmutxhL5pLL6WKK3XlFkrn5JGf2MdwQ';
  
  final headers = {
    'apikey': apikey,
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  print('Fetching bookings for active user f80f5827-4976-4d35-83b8-e7f45bdfb9aa...');
  final url = Uri.parse('$baseUrl/rest/v1/bookings?client_id=eq.f80f5827-4976-4d35-83b8-e7f45bdfb9aa&select=id,status,created_at');
  final res = await http.get(url, headers: headers);
  
  if (res.statusCode != 200) {
    print('Failed to fetch bookings: ${res.statusCode}');
    print(res.body);
    return;
  }
  
  final List<dynamic> bookings = jsonDecode(res.body);
  print('Found ${bookings.length} bookings for this user:');
  for (final b in bookings) {
    print(' - ID: ${b['id']} | Status: ${b['status']} | Created: ${b['created_at']}');
  }
}
