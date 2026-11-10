import 'dart:async';

import 'package:flutter/material.dart';

/// Motion tokens. Every animation in the app reads its duration and curve
/// from here, and all of them collapse to zero when the OS asks to reduce
/// motion (MediaQuery.disableAnimations).
abstract final class Motion {
  static const short = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 280);
  static const long = Duration(milliseconds: 450);
  static const stagger = Duration(milliseconds: 45);

  /// Decelerate in, used for things arriving.
  static const enter = Curves.easeOutCubic;

  /// Emphasized for state changes.
  static const emphasized = Curves.easeInOutCubicEmphasized;

  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration of(BuildContext context, Duration d) => reduced(context) ? Duration.zero : d;
}

/// Fades and rises a child in once, after [delay]. Use [index] for a
/// staggered list entrance; the delay is capped so long lists stay snappy.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.offset = 14,
    this.onceKey,
  });

  /// When set, the entrance plays only the first time this key appears in
  /// the session; revisiting a tab shows the item at rest.
  final String? onceKey;

  static final _played = <String>{};

  /// For tests.
  @visibleForTesting
  static void resetPlayed() => _played.clear();

  final Widget child;
  final int index;
  final Duration delay;

  /// Pixels to rise from.
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Motion.long);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Motion.enter);
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final key = widget.onceKey;
    final seen = key != null && !FadeSlideIn._played.add(key);
    if (Motion.reduced(context) || seen) {
      _c.value = 1;
      return;
    }
    final delay = widget.delay + Motion.stagger * widget.index.clamp(0, 8);
    if (delay == Duration.zero) {
      _c.forward();
    } else {
      _timer = Timer(delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _t,
    child: widget.child,
    builder: (context, child) => Opacity(
      opacity: _t.value,
      child: Transform.translate(offset: Offset(0, (1 - _t.value) * widget.offset), child: child),
    ),
  );
}

/// Counts a number to its new value, e.g. credit balances.
class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({super.key, required this.value, required this.format, this.style});
  final double value;
  final String Function(double) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: value),
    duration: Motion.of(context, const Duration(milliseconds: 700)),
    curve: Motion.enter,
    builder: (context, v, _) => Text(format(v), style: style),
  );
}

/// A progress bar that eases to its value.
class AnimatedBar extends StatelessWidget {
  const AnimatedBar({super.key, required this.value, this.color, this.background, this.height = 10});
  final double value;
  final Color? color;
  final Color? background;
  final double height;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: value.clamp(0, 1)),
    duration: Motion.of(context, const Duration(milliseconds: 600)),
    curve: Motion.emphasized,
    builder: (context, v, _) => ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(value: v, minHeight: height, color: color, backgroundColor: background),
    ),
  );
}

/// A dot that softly pulses, for busy states.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.color, this.size = 9, this.pulsing = true});
  final Color color;
  final double size;
  final bool pulsing;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(PulseDot old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = widget.pulsing && !Motion.reduced(context);
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_c.value);
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (widget.pulsing)
                Container(
                  width: s * (1 + t * 1.6),
                  height: s * (1 + t * 1.6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.45 * (1 - t)),
                  ),
                ),
              AnimatedContainer(
                duration: Motion.of(context, Motion.medium),
                width: s,
                height: s,
                decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Cross-fades and slightly scales between children keyed by state.
class StateSwitcher extends StatelessWidget {
  const StateSwitcher({super.key, required this.child, this.alignment = Alignment.center});
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: Motion.of(context, Motion.medium),
    switchInCurve: Motion.enter,
    switchOutCurve: Curves.easeIn,
    layoutBuilder: (current, previous) => Stack(alignment: alignment, children: [...previous, ?current]),
    transitionBuilder: (child, a) => FadeTransition(
      opacity: a,
      child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(a), child: child),
    ),
    child: child,
  );
}

/// Fade-through between top-level destinations: the old page fades out, the
/// new one fades in while scaling up a touch (Material motion).
class FadeThrough extends StatelessWidget {
  const FadeThrough({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: Motion.of(context, const Duration(milliseconds: 320)),
    switchInCurve: const Interval(0.35, 1, curve: Motion.enter),
    switchOutCurve: const Interval(0, 0.35, curve: Curves.easeIn),
    layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
    transitionBuilder: (child, a) => FadeTransition(
      opacity: a,
      child: ScaleTransition(scale: Tween(begin: 0.97, end: 1.0).animate(a), child: child),
    ),
    child: child,
  );
}
