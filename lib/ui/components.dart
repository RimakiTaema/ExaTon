import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/exaroton/client.dart';
import '../core/modrinth/modrinth.dart';
import '../core/exaroton/models.dart';
import 'motion.dart';
import 'tokens.dart';
import 'app_icons.dart';

// ── Layout ─────────────────────────────────────────────────────────────

/// Breakpoints by width only, no device detection.
enum WindowSize {
  compact,
  medium,
  expanded;

  static WindowSize of(BuildContext context) => fromWidth(MediaQuery.sizeOf(context).width);

  /// Under 600 compact, 600 to 839 medium, 840 and over expanded.
  static WindowSize fromWidth(double w) => w < 600
      ? WindowSize.compact
      : w < 840
      ? WindowSize.medium
      : WindowSize.expanded;

  /// Width of the server list next to the detail pane.
  static double listPaneWidth(double windowWidth) => windowWidth < 1024 ? 340 : 400;
}

const gutter = 20.0;

// ── Formatting ─────────────────────────────────────────────────────────

final _credits = NumberFormat('#,##0.00');
String formatCredits(double v) => _credits.format(v);

String formatPerHour(double v) => v >= 10 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

String formatClock(DateTime t) => DateFormat.Hm().format(t);

String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var v = bytes.toDouble();
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return '${v.toStringAsFixed(i == 0 || v >= 100 ? 0 : 1)} ${units[i]}';
}

// ── Status ─────────────────────────────────────────────────────────────

Color statusColor(BuildContext context, ServerStatus s) {
  final t = context.tokens;
  return switch (s.group) {
    StatusGroup.online => t.success,
    StatusGroup.offline => t.idle,
    StatusGroup.busy => t.busy,
    StatusGroup.crashed => t.error,
  };
}

/// Dot plus the exact status name, so colour is never the only signal.
class StatusLabel extends StatelessWidget {
  const StatusLabel(this.status, {super.key, this.suffix, this.style});
  final ServerStatus status;
  final String? suffix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final c = statusColor(context, status);
    final text = suffix == null ? status.label : '${status.label} - $suffix';
    return Semantics(
      label: 'Status: $text',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PulseDot(color: c, pulsing: status.group == StatusGroup.busy),
          const SizedBox(width: 7),
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: Motion.of(context, Motion.medium),
              curve: Motion.emphasized,
              style: (style ?? Theme.of(context).textTheme.labelLarge ?? const TextStyle()).copyWith(
                color: c,
                fontWeight: FontWeight.w700,
              ),
              child: StateSwitcher(
                alignment: Alignment.centerLeft,
                child: Text(text, key: ValueKey(text), overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Surfaces ───────────────────────────────────────────────────────────

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.borderColor,
    this.color,
    this.selected = false,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? color;
  final bool selected;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(18);
    final border = selected ? t.primary : (borderColor ?? t.outline);
    final fill = color ?? (selected ? Color.alphaBlend(t.primary.withValues(alpha: 0.06), t.surface) : t.surface);
    final d = Motion.of(context, Motion.medium);
    // Border, fill and the selection bar ease between states.
    final body = AnimatedContainer(
      duration: d,
      curve: Motion.emphasized,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(color: border, width: selected ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(padding: padding, child: child),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: d,
                  curve: Motion.emphasized,
                  width: selected ? 4 : 0,
                  color: t.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return semanticLabel == null
        ? body
        : Semantics(button: onTap != null, selected: selected, label: semanticLabel, child: body);
  }
}

/// A grouped list in one card with dividers.
class CardList extends StatelessWidget {
  const CardList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: t.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) Divider(color: t.outline, height: 1), children[i]],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    // The note moves under the title when both do not fit on one line.
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ),
        if (trailing != null)
          DefaultTextStyle.merge(
            style: TextStyle(color: context.tokens.onSurfaceMuted, fontSize: 15),
            child: trailing!,
          ),
      ],
    ),
  );
}

/// "1,248.50 credits", big number with a muted unit.
class CreditsAmount extends StatelessWidget {
  const CreditsAmount(this.credits, {super.key, this.size = 30});
  final double credits;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // The balance counts to new values; the unit stays still.
    return TweenAnimationBuilder<double>(
      tween: Tween(end: credits),
      duration: Motion.of(context, const Duration(milliseconds: 700)),
      curve: Motion.enter,
      // One line always: at large text sizes it scales down rather than
      // breaking inside the number.
      builder: (context, v, _) => OneLine(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: formatCredits(v),
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w800,
                  color: t.onSurface,
                  letterSpacing: -0.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              TextSpan(
                text: ' credits',
                style: TextStyle(fontSize: size * 0.55, fontWeight: FontWeight.w500, color: t.onSurfaceMuted),
              ),
            ],
          ),
          semanticsLabel: '${formatCredits(credits)} credits',
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }
}

/// Small pill, for "~3 days left". Uses the tone's container pair, which
/// reaches 4.5:1 in both themes.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, required this.tone});
  final String text;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AnimatedContainer(
      duration: Motion.of(context, Motion.medium),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: t.container(tone), borderRadius: BorderRadius.circular(10)),
      child: Text(
        text,
        style: TextStyle(color: t.onContainer(tone), fontWeight: FontWeight.w800, fontSize: 15),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.highlight = false, this.size = 36});
  final String name;
  final bool highlight;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final initial = name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: highlight ? t.primary : t.outline, shape: BoxShape.circle),
        child: Text(
          initial,
          style: TextStyle(
            color: highlight ? t.onPrimary : t.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }
}

/// Dashed-border help note.
class InfoNote extends StatelessWidget {
  const InfoNote(this.text, {super.key, this.icon = AppIcons.info});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: t.onSurfaceMuted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: t.onSurfaceMuted, height: 1.4, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class WarningBanner extends StatelessWidget {
  const WarningBanner(this.text, {super.key, this.tone = Tone.warning, this.action});
  final String text;
  final Tone tone;

  /// Optional button at the end, e.g. "Retry".
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = t.onContainer(tone);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: t.container(tone), borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(switch (tone) {
            Tone.success => AppIcons.success,
            Tone.warning => AppIcons.warning,
            Tone.error => AppIcons.error,
          }, color: c),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: c, fontWeight: FontWeight.w600, height: 1.35),
            ),
          ),
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
      ),
    );
  }
}

/// A readable version of an error. Raw exceptions and codes never reach
/// the main text; they go in [details].
@immutable
class ErrorInfo {
  const ErrorInfo({required this.title, required this.body, this.details, this.kind = ErrorKind.other});
  final String title;
  final String body;
  final String? details;
  final ErrorKind kind;
}

enum ErrorKind { network, revoked, forbidden, notFound, server, other }

ErrorInfo describeError(Object e) {
  if (e is ExarotonException) {
    final code = e.statusCode;
    final details = code == null ? e.message : 'HTTP $code: ${e.message}';
    if (code == 401) {
      return ErrorInfo(
        title: 'Sign-in expired',
        body: "This account's API token no longer works. Sign in again with a new token.",
        details: details,
        kind: ErrorKind.revoked,
      );
    }
    if (code == 403) {
      return ErrorInfo(
        title: 'No permission',
        body: "This account isn't allowed to see this. Ask the server owner for access.",
        details: details,
        kind: ErrorKind.forbidden,
      );
    }
    if (code == 404) {
      return ErrorInfo(
        title: 'Not found',
        body: 'It may have been deleted on exaroton.',
        details: details,
        kind: ErrorKind.notFound,
      );
    }
    if (code != null && code >= 500) {
      return ErrorInfo(
        title: 'exaroton is having trouble',
        body: 'Try again in a moment.',
        details: details,
        kind: ErrorKind.server,
      );
    }
    if (code == null) {
      return ErrorInfo(
        title: "Can't reach exaroton",
        body: 'Check your connection. ExaTon keeps trying.',
        details: e.message,
        kind: ErrorKind.network,
      );
    }
    return ErrorInfo(title: 'Something went wrong', body: e.message, details: details);
  }
  if (e is ModrinthException) {
    return ErrorInfo(title: "Couldn't load from Modrinth", body: e.message, details: '$e');
  }
  return ErrorInfo(title: 'Something went wrong', body: 'Try again.', details: '$e');
}

/// Error state: what happened, what to do, and the raw details small.
class ErrorPanel extends StatelessWidget {
  const ErrorPanel(this.error, {super.key, this.onRetry, this.actions = const []});
  final Object error;
  final VoidCallback? onRetry;

  /// Extra buttons, e.g. "Sign in again".
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final info = describeError(error);
    return EmptyState(
      icon: switch (info.kind) {
        ErrorKind.network => AppIcons.offline,
        ErrorKind.revoked => AppIcons.revoked,
        ErrorKind.forbidden => AppIcons.locked,
        _ => AppIcons.error,
      },
      iconColor: info.kind == ErrorKind.network ? t.onSurfaceMuted : t.error,
      title: info.title,
      body: info.body,
      details: info.details,
      actions: [
        ...actions,
        if (onRetry != null) OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}

/// Empty, error and offline states share one layout.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.details,
    this.actions = const [],
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? details;
  final List<Widget> actions;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: FadeSlideIn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: iconColor ?? t.onSurfaceMuted),
                const SizedBox(height: 14),
                Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                if (body != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    body!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.onSurfaceMuted, height: 1.4),
                  ),
                ],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: actions),
                ],
                if (details != null) ...[
                  const SizedBox(height: 14),
                  SelectableText(
                    'Details: $details',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.onSurfaceMuted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder shaped like the content it stands in for, so the layout does
/// not jump when data arrives. Gently pulses unless motion is reduced.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, required this.height, this.radius = 8});
  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final base = Color.alphaBlend(t.onSurface.withValues(alpha: 0.06), t.surface);
    final hi = Color.alphaBlend(t.onSurface.withValues(alpha: 0.11), t.surface);
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(base, hi, Curves.easeInOut.transform(_c.value)),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

/// Scales a single line down rather than wrapping it, for figures such as
/// balances that must never break inside the number.
class OneLine extends StatelessWidget {
  const OneLine({super.key, required this.child, this.alignment = Alignment.centerLeft});
  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => FittedBox(fit: BoxFit.scaleDown, alignment: alignment, child: child);
}

class Loading extends StatelessWidget {
  const Loading({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

/// Icon button that always has a screen reader label and a tooltip.
class LabeledIconButton extends StatelessWidget {
  const LabeledIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: true,
        toggled: selected ? true : null,
        excludeSemantics: true,
        child: SizedBox(
          width: 48,
          height: 48,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 48),
              backgroundColor: selected ? t.selectedFill : t.surface,
              foregroundColor: selected ? t.onSelectedFill : t.onSurface,
              side: BorderSide(color: selected ? t.primary : t.outlineStrong),
            ),
            child: Icon(icon, size: 22),
          ),
        ),
      ),
    );
  }
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  String action = 'Confirm',
  bool destructive = false,
}) async {
  final t = context.tokens;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: t.error, foregroundColor: t.onError) : null,
          onPressed: () => Navigator.pop(c, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok == true;
}
