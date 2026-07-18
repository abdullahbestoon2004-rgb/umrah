void main() {
  print('Testing Dart Map casting behavior...');
  
  // Replicating the database row where 'packages' is null:
  final Map<String, dynamic> r = {
    'packages': null,
    'companies': {
      'name': 'itland',
      'tint': '#3d5a3d',
      'name_ar': null,
      'name_en': 'itland',
      'is_verified': true
    }
  };

  try {
    print('Testing cast: (r[\'packages\'] ?? const {}) as Map<String, dynamic>');
    final pkg = (r['packages'] ?? const {}) as Map<String, dynamic>;
    print('Cast succeeded! pkg: $pkg');
  } catch (e, stack) {
    print('Cast failed with error: $e');
    print(stack);
  }
}
