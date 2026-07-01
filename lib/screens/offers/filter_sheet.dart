import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../l10n/generated/app_localizations.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late OfferFilters _local;

  @override
  void initState() {
    super.initState();
    _local = context.read<AppProvider>().filters;
  }

  void _apply() {
    context.read<AppProvider>().updateFilters(_local);
    Navigator.pop(context);
  }

  void _reset() {
    setState(() => _local = const OfferFilters());
    context.read<AppProvider>().resetFilters();
  }

  int _countMatching() => context.read<AppProvider>().getFilteredOffers(_local).length;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 14, bottom: 6),
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 4),
              child: Row(
                children: [
                  Text(t.filterSheetTitle, style: AppTheme.serif(24)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _reset,
                    child: Text(t.filterSheetReset, style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ),

            // price
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Row(
                children: [
                  Text(t.filterSheetMaxPricePerPerson, style: AppTheme.sans(14, weight: FontWeight.w700)),
                  const Spacer(),
                  Text('\$${_local.priceMax.round()}', style: AppTheme.serif(20, color: AppColors.primary)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(activeTrackColor: AppColors.primary, thumbColor: AppColors.primary, inactiveTrackColor: AppColors.primary.withOpacity(0.15)),
                child: Slider(
                  min: 1000,
                  max: 5000,
                  divisions: 40,
                  value: _local.priceMax,
                  onChanged: (v) => setState(() => _local = _local.copyWith(priceMax: v)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$1,000', style: AppTheme.sans(11, color: AppColors.mutedLight)),
                  Text('\$5,000+', style: AppTheme.sans(11, color: AppColors.mutedLight)),
                ],
              ),
            ),

            _Section(label: t.filterSheetTransportation),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Row(
                children: [
                  Expanded(child: _Opt(label: t.filterSheetAll, active: _local.transport == 'all', onTap: () => setState(() => _local = _local.copyWith(transport: 'all')))),
                  const SizedBox(width: 9),
                  Expanded(child: _Opt(label: t.filterSheetByAir, icon: Icons.flight_rounded, active: _local.transport == 'plane', onTap: () => setState(() => _local = _local.copyWith(transport: 'plane')))),
                  const SizedBox(width: 9),
                  Expanded(child: _Opt(label: t.filterSheetByCoach, icon: Icons.directions_bus_rounded, active: _local.transport == 'bus', onTap: () => setState(() => _local = _local.copyWith(transport: 'bus')))),
                ],
              ),
            ),

            _Section(label: t.filterSheetAccommodation),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Row(
                children: [
                  Expanded(child: _Opt(label: t.filterSheetAny, active: _local.acc == 'all', onTap: () => setState(() => _local = _local.copyWith(acc: 'all')))),
                  const SizedBox(width: 9),
                  Expanded(child: _Opt(label: '5★', active: _local.acc == '5', onTap: () => setState(() => _local = _local.copyWith(acc: '5')))),
                  const SizedBox(width: 9),
                  Expanded(child: _Opt(label: '4★', active: _local.acc == '4', onTap: () => setState(() => _local = _local.copyWith(acc: '4')))),
                  const SizedBox(width: 9),
                  Expanded(child: _Opt(label: '3★', active: _local.acc == '3', onTap: () => setState(() => _local = _local.copyWith(acc: '3')))),
                ],
              ),
            ),

            _Section(label: t.filterSheetTripDuration),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Wrap(
                spacing: 9,
                children: [
                  _Opt(label: t.filterSheetAny, active: _local.dur == 'all', onTap: () => setState(() => _local = _local.copyWith(dur: 'all'))),
                  _Opt(label: t.filterSheetDuration7to9, active: _local.dur == 'short', onTap: () => setState(() => _local = _local.copyWith(dur: 'short'))),
                  _Opt(label: t.filterSheetDuration10to14, active: _local.dur == 'mid', onTap: () => setState(() => _local = _local.copyWith(dur: 'mid'))),
                  _Opt(label: t.filterSheetDuration15Plus, active: _local.dur == 'long', onTap: () => setState(() => _local = _local.copyWith(dur: 'long'))),
                ],
              ),
            ),

            _Section(label: t.filterSheetAgencyRating),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Row(
                children: [
                  Expanded(child: _Opt(label: t.filterSheetAny, active: _local.rating == 0, onTap: () => setState(() => _local = _local.copyWith(rating: 0)))),
                  const SizedBox(width: 9),
                  Expanded(child: _Opt(label: '★ 4.5+', active: _local.rating == 4.5, onTap: () => setState(() => _local = _local.copyWith(rating: 4.5)))),
                  const SizedBox(width: 9),
                  Expanded(child: _Opt(label: '★ 4.8+', active: _local.rating == 4.8, onTap: () => setState(() => _local = _local.copyWith(rating: 4.8)))),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
              child: GestureDetector(
                onTap: _apply,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 14)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t.filterSheetShowPackages(_countMatching()),
                    style: AppTheme.sans(15, weight: FontWeight.w800, color: const Color(0xFFF6F2E9)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
      child: Text(label, style: AppTheme.sans(14, weight: FontWeight.w700)),
    );
  }
}

class _Opt extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;
  const _Opt({required this.label, this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFF6F2E9) : const Color(0xFF3C4A43);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.primary.withOpacity(0.16),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 5)],
            Text(
              label,
              style: AppTheme.sans(13, weight: FontWeight.w700, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
