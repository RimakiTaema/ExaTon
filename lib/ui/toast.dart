import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'app_icons.dart';
import 'components.dart' show WindowSize;
import 'motion.dart';
import 'tokens.dart';

/// Short, non-blocking feedback that floats above everything in the root
/// overlay. One toast at a time: a new one replaces the current one.
///
/// Needs no setup; any context under a [Navigator] can show one. When the
/// context will not survive an async gap, take a [Toaster] first:
///
/// ```dart
/// final toaster = Toaster.of(context);
/// await something();
/// toaster?.show('Done', tone: Tone.success);
/// ```
void showToast(
  BuildContext context,
  String text, {
  Tone? tone,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) => Toaster.of(context)?.show(text, tone: tone, actionLabel: actionLabel, onAction: onAction, duration: duration);

/// A handle on the root overlay's toast slot, safe to keep across awaits.
class Toaster {
  Toaster._(this._overlay);
  final OverlayState _overlay;

  static final _current = Expando<_ToastEntry>('toast');

  /// Null when there is no overlay (no Navigator above [context]).
  static Toaster? of(BuildContext context) {
    final o = Overlay.maybeOf(context, rootOverlay: true);
    return o == null ? null : Toaster._(o);
  }

  /// How long a toast stays: longer with an action, and scaled for long text.
  static Duration defaultDuration(String text, {bool hasAction = false}) {
    final base = hasAction ? 8000 : 4000;
    return Duration(milliseconds: (base + text.length * 40).clamp(base, 10000));
  }

  void show(String text, {Tone? tone, String? actionLabel, VoidCallback? onAction, Duration? duration}) {
    if (!_overlay.mounted) return;
    _current[_overlay]?.dismiss(animate: false);
    final hasAction = actionLabel != null && onAction != null;
    final entry = _ToastEntry(
      text: text,
      tone: tone,
      actionLabel: hasAction ? actionLabel : null,
      onAction: hasAction ? onAction : null,
      duration: duration ?? defaultDuration(text, hasAction: hasAction),
      onRemoved: (e) {
        if (identical(_current[_overlay], e)) _current[_overlay] = null;
      },
    );
    _current[_overlay] = entry;
    _overlay.insert(entry.overlayEntry);
    final dir = Directionality.maybeOf(_overlay.context) ?? TextDirection.ltr;
    SemanticsService.sendAnnouncement(View.of(_overlay.context), text, dir);
  }

  /// Hides the current toast, if any.
  void hide() => _current[_overlay]?.dismiss();
}

class _ToastEntry {
  _ToastEntry({
    required this.text,
    required this.tone,
    required this.actionLabel,
    required this.onAction,
    required this.duration,
    required this.onRemoved,
  }) {
    overlayEntry = OverlayEntry(builder: (_) => _ToastView(key: _key, entry: this));
  }

  final String text;
  final Tone? tone;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final void Function(_ToastEntry) onRemoved;
  final _key = GlobalKey<_ToastViewState>();
  late final OverlayEntry overlayEntry;
  bool _removed = false;

  void dismiss({bool animate = true}) {
    final s = _key.currentState;
    if (animate && s != null && s.mounted) {
      s.close();
    } else {
      remove();
    }
  }

  void remove() {
    if (_removed) return;
    _removed = true;
    overlayEntry.remove();
    overlayEntry.dispose();
    onRemoved(this);
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({super.key, required this.entry});
  final _ToastEntry entry;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Motion.medium);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Motion.enter, reverseCurve: Curves.easeInCubic);
  Timer? _timer;
  bool _hovered = false;
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _c.duration = Motion.of(context, Motion.medium);
    _c.reverseDuration = Motion.of(context, Motion.short);
    if (_c.status == AnimationStatus.dismissed && !_closing) {
      _c.forward();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    // Screen readers need time to reach the action, so actions wait.
    final a11y = MediaQuery.maybeAccessibleNavigationOf(context) ?? false;
    if (a11y && widget.entry.actionLabel != null) return;
    _timer = Timer(widget.entry.duration, () {
      if (!_hovered) close();
    });
  }

  Future<void> close() async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    if (mounted) await _c.reverse();
    widget.entry.remove();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final e = widget.entry;
    final tone = e.tone;
    final bg = tone == null ? t.surface : t.container(tone);
    final fg = tone == null ? t.onSurface : t.onContainer(tone);
    final iconColor = tone == null ? t.primary : fg;
    final icon = switch (tone) {
      null => AppIcons.info,
      Tone.success => AppIcons.success,
      Tone.warning => AppIcons.warning,
      Tone.error => AppIcons.error,
    };

    final mq = MediaQuery.of(context);
    final size = WindowSize.fromWidth(mq.size.width);
    // Clear the bottom NavigationBar (72) on compact layouts.
    final bottom = mq.viewPadding.bottom + mq.viewInsets.bottom + (size == WindowSize.compact ? 88 : 24);
    final alignment = size == WindowSize.expanded ? Alignment.bottomRight : Alignment.bottomCenter;

    final card = Material(
      color: bg,
      elevation: 6,
      shadowColor: t.scrim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: tone == null ? t.outline : const Color(0x00000000)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 6, 6),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  e.text,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600, height: 1.35, fontSize: 15),
                ),
              ),
            ),
            if (e.actionLabel != null)
              TextButton(
                style: TextButton.styleFrom(foregroundColor: tone == null ? t.primary : fg),
                onPressed: () {
                  e.onAction!();
                  close();
                },
                child: Text(e.actionLabel!, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            IconButton(
              tooltip: 'Dismiss',
              icon: Icon(AppIcons.close, size: 18, color: fg.withValues(alpha: 0.8)),
              onPressed: close,
            ),
          ],
        ),
      ),
    );

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottom,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: FadeTransition(
              opacity: _t,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(_t),
                child: MouseRegion(
                  onEnter: (_) {
                    _hovered = true;
                    _timer?.cancel();
                  },
                  onExit: (_) {
                    _hovered = false;
                    if (!_closing) _startTimer();
                  },
                  child: Dismissible(
                    key: ObjectKey(e),
                    direction: DismissDirection.horizontal,
                    onDismissed: (_) {
                      _closing = true;
                      _timer?.cancel();
                      e.remove();
                    },
                    child: Semantics(container: true, child: card),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
