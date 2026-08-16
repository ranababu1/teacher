import 'package:flutter/material.dart';

/// A shimmering placeholder rectangle — reads as "content is coming" more
/// than a bare spinner does, without pulling in an animation package.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = colorScheme.surfaceContainerHigh;
    final sheen = colorScheme.onSurface.withValues(alpha: 0.06);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(-1 + 3 * t, 0),
                end: Alignment(1 + 3 * t, 0),
                colors: [base, sheen, base],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              color: base,
            ),
          );
        },
      ),
    );
  }
}

/// A preset skeleton matching the rough silhouette of a card-per-row list
/// screen (Practice, Review, Progress, Learning Paths) — used as
/// [AsyncValueView]'s loading state on screens where that's a better fit
/// than a bare spinner.
class SkeletonCardList extends StatelessWidget {
  const SkeletonCardList({super.key, this.itemCount = 4, this.itemHeight = 88});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          ShimmerBox(height: itemHeight, borderRadius: 16),
    );
  }
}
