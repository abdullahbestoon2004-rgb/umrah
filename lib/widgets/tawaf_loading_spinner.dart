import 'package:flutter/material.dart';

/// A branded loading indicator with a stationary Kaaba and rotating tawaf ring.
///
/// Animation is disabled when the platform requests reduced motion.
class TawafLoadingSpinner extends StatefulWidget {
  const TawafLoadingSpinner({
    super.key,
    this.size = 96,
    this.semanticLabel = 'Loading',
  });

  /// The square width and height of the spinner.
  final double size;

  /// Label announced by assistive technologies while this indicator is visible.
  final String semanticLabel;

  @override
  State<TawafLoadingSpinner> createState() => _TawafLoadingSpinnerState();
}

class _TawafLoadingSpinnerState extends State<TawafLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;

    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _controller.stop();
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RotationTransition(
            turns: _controller,
            child: const Image(
              image: AssetImage('assets/images/tawaf_loader_outer.png'),
              filterQuality: FilterQuality.high,
            ),
          ),
          const Image(
            image: AssetImage('assets/images/tawaf_loader_center.png'),
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );

    return Semantics(
      label: widget.semanticLabel,
      liveRegion: true,
      child: image,
    );
  }
}
