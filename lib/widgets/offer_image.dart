import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/offer_model.dart';
import '../providers/app_provider.dart';
import 'gradient_card.dart';

/// Cover visual for an offer: the agency-uploaded photo when one exists,
/// otherwise the offer's gradient placeholder.
class OfferImage extends StatelessWidget {
  final Offer offer;
  final double? height;
  final double? width;
  final BorderRadius borderRadius;
  final String? heroTag;

  const OfferImage({
    super.key,
    required this.offer,
    this.height,
    this.width,
    this.borderRadius = BorderRadius.zero,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = GradientCard(
      colors: offer.gradColors,
      height: height ?? 100,
      width: width,
      borderRadius: borderRadius,
    );

    Widget imageWidget;
    final bytes = context.watch<AppProvider>().getOfferImage(offer.id);
    if (bytes != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius,
        child: Image.memory(
          bytes,
          height: height,
          width: width,
          fit: BoxFit.cover,
        ),
      );
    } else if ((offer.imageUrl ?? '').isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          offer.imageUrl!,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        ),
      );
    } else {
      imageWidget = fallback;
    }

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: imageWidget);
    }
    return imageWidget;
  }
}
