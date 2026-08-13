import 'package:flutter/material.dart';

/// Fades and rises a child into place on first build — used to give lists
/// of cards (Dashboard sections, learning path cards) a staggered
/// entrance instead of appearing all at once, flat and static.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delayPerIndex = const Duration(milliseconds: 60),
  });

  final Widget child;

  /// Position in a list — later indices start slightly later, so a
  /// column of cards animates in as a gentle cascade.
  final int index;
  final Duration delayPerIndex;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delayPerIndex * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_curved),
        child: widget.child,
      ),
    );
  }
}
