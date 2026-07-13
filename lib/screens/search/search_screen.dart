import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/offer_model.dart';
import '../offers/offer_detail_screen.dart';
import '../../widgets/offer_image.dart';
import '../../widgets/star_rating.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/interactive_scale.dart';
import '../../widgets/islamic_pattern.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<Offer> _results = [];
  bool _hasTyped = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    final results = context.read<AppProvider>().searchOffers(q);
    setState(() {
      _results = results;
      _hasTyped = q.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const IslamicPattern(opacity: 0.04, isEightFold: true),
            Column(
              children: [
                // search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _ctrl,
                            autofocus: true,
                            onChanged: _onChanged,
                            style: AppTheme.sans(14),
                            decoration: InputDecoration(
                              hintText: t.searchHint,
                              hintStyle: AppTheme.sans(
                                14,
                                color: AppColors.mutedLight,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              suffixIcon: _ctrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: AppColors.muted,
                                      ),
                                      onPressed: () {
                                        _ctrl.clear();
                                        _onChanged('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // results
                Expanded(
                  child: !_hasTyped
                      ? _Suggestions(
                          onTap: (q) {
                            _ctrl.text = q;
                            _onChanged(q);
                          },
                        )
                      : _results.isEmpty
                      ? _NoResults(query: _ctrl.text)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) =>
                              _ResultCard(offer: _results[i]),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _Suggestions({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Built from live data so every chip is guaranteed to return results,
    // whatever language the UI is in.
    final suggestions = context.watch<AppProvider>().searchSuggestions;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.searchPopularSearches,
            style: AppTheme.sans(
              12,
              weight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map(
                  (s) => InteractiveScale(
                    onTap: () => onTap(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Text(
                        s,
                        style: AppTheme.sans(13, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 52,
            color: AppColors.mutedLight,
          ),
          const SizedBox(height: 14),
          Text(t.searchNoResultsFor(query), style: AppTheme.serif(20)),
          const SizedBox(height: 6),
          Text(
            t.searchTryDifferentTerm,
            style: AppTheme.sans(13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Offer offer;
  const _ResultCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final company = context.read<AppProvider>().companyById(offer.companyId);
    final tag = 'offer-search-${offer.id}';
    return InteractiveScale(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OfferDetailScreen(offer: offer, heroTag: tag),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            OfferImage(
              offer: offer,
              height: 80,
              width: 80,
              borderRadius: BorderRadius.circular(12),
              heroTag: tag,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company?.nameFor(
                          Localizations.localeOf(context).languageCode,
                        ) ??
                        '',
                    style: AppTheme.sans(
                      10.5,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.titleFor(
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: AppTheme.serif(16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StarRating(rating: offer.rating),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: t.searchFromPrefix,
                              style: AppTheme.sans(11, color: AppColors.muted),
                            ),
                            TextSpan(
                              text: offer.priceFmt,
                              style: AppTheme.serif(
                                16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
