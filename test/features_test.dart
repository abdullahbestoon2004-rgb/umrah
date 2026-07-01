import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:umrah_app/data/sample_data.dart';
import 'package:umrah_app/models/notification_model.dart';
import 'package:umrah_app/providers/app_provider.dart';
import 'package:umrah_app/screens/profile/help_support_screen.dart';
import 'package:umrah_app/screens/profile/notifications_screen.dart';
import 'package:umrah_app/screens/profile/payment_methods_screen.dart';
import 'package:umrah_app/screens/profile/privacy_security_screen.dart';
import 'package:umrah_app/l10n/generated/app_localizations.dart';

Widget wrap(Widget child, AppProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

void main() {
  group('AppProvider', () {
    test('cancelBooking marks booking cancelled and pushes notification', () {
      final p = AppProvider();
      final before = p.unreadNotifications;
      final booking = p.bookings.first;
      p.cancelBooking(booking.id);
      expect(p.bookings.first.status, 'Cancelled');
      expect(p.unreadNotifications, before + 1);
    });

    test('confirmBooking adds booking and notification', () {
      final p = AppProvider();
      final count = p.bookings.length;
      p.confirmBooking(sampleOffers.first, 2, 'Al-Safwah Travel');
      expect(p.bookings.length, count + 1);
      expect(p.bookings.first.travelers, 2);
      expect(p.notifications.first.type, NotificationType.bookingConfirmed);
    });

    test('card add/remove/default works', () {
      final p = AppProvider();
      expect(p.cards.length, 1);
      p.addCard(holder: 'Test User', number: '5555444433331111', expiry: '12/30');
      expect(p.cards.length, 2);
      expect(p.cards.last.brand, 'Mastercard');
      expect(p.cards.last.last4, '1111');
      p.setDefaultCard(p.cards.last.id);
      expect(p.defaultCardId, p.cards.last.id);
      p.removeCard(p.cards.last.id);
      expect(p.cards.length, 1);
      expect(p.defaultCardId, p.cards.first.id);
    });

    test('notifications mark read and clear', () {
      final p = AppProvider();
      expect(p.unreadNotifications, greaterThan(0));
      p.markAllNotificationsRead();
      expect(p.unreadNotifications, 0);
      p.clearNotifications();
      expect(p.notifications, isEmpty);
    });

    test('security settings toggle', () {
      final p = AppProvider();
      expect(p.biometricLock, false);
      p.setSecuritySetting('biometric', true);
      expect(p.biometricLock, true);
    });

    test('booking stores departure date', () {
      final p = AppProvider();
      final date = DateTime(2026, 12, 20);
      p.confirmBooking(sampleOffers.first, 1, 'Al-Safwah Travel', departureDate: date);
      expect(p.bookings.first.departureDate, date);
    });

    test('getFilteredOffers accepts a preview override without committing', () {
      final p = AppProvider();
      final all = p.getFilteredOffers().length;
      final byAir = p.getFilteredOffers(const OfferFilters(transport: 'plane')).length;
      expect(byAir, lessThan(all));
      // committed filters unchanged
      expect(p.filters.transport, 'all');
      expect(p.getFilteredOffers().length, all);
    });

    test('search suggestions all return results', () {
      final p = AppProvider();
      final suggestions = p.searchSuggestions;
      expect(suggestions, isNotEmpty);
      for (final s in suggestions) {
        expect(p.searchOffers(s), isNotEmpty, reason: 'suggestion "$s" returned no results');
      }
    });

    test('companyById resolves pending companies too', () {
      final p = AppProvider();
      expect(p.companyById('c7'), isNotNull);
      expect(p.companyById('nope'), isNull);
    });
  });

  group('Screens render', () {
    testWidgets('NotificationsScreen shows items and marks read on tap', (tester) async {
      final p = AppProvider();
      await tester.pumpWidget(wrap(const NotificationsScreen(), p));
      await tester.pump();
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Seasonal offers are live'), findsOneWidget);
      final unreadBefore = p.unreadNotifications;
      await tester.tap(find.text('Seasonal offers are live'));
      await tester.pump();
      expect(p.unreadNotifications, unreadBefore - 1);
    });

    testWidgets('PaymentMethodsScreen lists card and opens add sheet with validation', (tester) async {
      final p = AppProvider();
      await tester.pumpWidget(wrap(const PaymentMethodsScreen(), p));
      await tester.pump();
      expect(find.textContaining('Visa'), findsOneWidget);
      await tester.tap(find.text('Add card'));
      await tester.pumpAndSettle();
      expect(find.text('Add new card'), findsOneWidget);
      // save with empty fields -> validation error
      await tester.tap(find.text('Save card'));
      await tester.pump();
      expect(find.text('Enter the cardholder name.'), findsOneWidget);
    });

    testWidgets('PrivacySecurityScreen toggles update provider', (tester) async {
      final p = AppProvider();
      await tester.pumpWidget(wrap(const PrivacySecurityScreen(), p));
      await tester.pump();
      expect(find.text('Privacy & security'), findsOneWidget);
      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      expect(p.biometricLock, true);
    });

    testWidgets('HelpSupportScreen expands FAQ', (tester) async {
      final p = AppProvider();
      await tester.pumpWidget(wrap(const HelpSupportScreen(), p));
      await tester.pump();
      expect(find.text('How do I book an Umrah package?'), findsOneWidget);
      await tester.tap(find.text('How do I book an Umrah package?'));
      await tester.pump();
      expect(find.textContaining('Book this trip'), findsOneWidget);
    });
  });
}
