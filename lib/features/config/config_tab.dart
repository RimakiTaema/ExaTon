import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';
import '../../ui/app_icons.dart';

final configProvider = FutureProvider.autoDispose.family<List<ConfigOption>, (String, String)>(
  (ref, key) => requireClient(ref).getConfig(key.$1, key.$2),
);

const _commonConfigs = ['server.properties', 'bukkit.yml', 'spigot.yml', 'config/paper-global.yml'];

/// Renders a form from each option's type: text, number (with min, max and
/// step), switch, a picker for select and chips for multiselect.
class ConfigTab extends ConsumerStatefulWidget {
  const ConfigTab({super.key, required this.server, this.initialPath = 'server.properties', this.fixedPath = false});
  final Server server;
  final String initialPath;
  final bool fixedPath;

  @override
  ConsumerState<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends ConsumerState<ConfigTab> {
  late String _path = widget.initialPath;
  final _changes = <String, Object?>{};
  String _filter = '';
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(clientProvider)!.updateConfig(widget.server.id, _path, Map.of(_changes));
      setState(_changes.clear);
      ref.invalidate(configProvider((widget.server.id, _path)));
      if (mounted) {
        showMessage(
          context,
          widget.server.status == ServerStatus.offline ? 'Saved' : 'Saved. Restart the server to apply.',
        );
      }
    } on ExarotonException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final options = ref.watch(configProvider((widget.server.id, _path)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // File picker and filter side by side when wide, stacked on phones.
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 560;
            final filter = TextField(
              onChanged: (v) => setState(() => _filter = v.toLowerCase()),
              decoration: const InputDecoration(hintText: 'Filter options', prefixIcon: Icon(AppIcons.search)),
            );
            if (widget.fixedPath) return filter;
            final picker = DropdownMenu<String>(
              initialSelection: _path,
              width: wide ? 280 : c.maxWidth,
              label: const Text('File'),
              onSelected: (v) {
                if (v == null) return;
                setState(() {
                  _path = v;
                  _changes.clear();
                });
              },
              dropdownMenuEntries: [
                for (final p in {..._commonConfigs, _path}) DropdownMenuEntry(value: p, label: p),
              ],
            );
            return wide
                ? Row(
                    children: [
                      picker,
                      const SizedBox(width: 12),
                      Expanded(child: filter),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [picker, const SizedBox(height: 10), filter],
                  );
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: switch (options) {
            AsyncData(:final value) => () {
              final shown = value
                  .where((o) => _filter.isEmpty || o.label.toLowerCase().contains(_filter) || o.key.contains(_filter))
                  .toList();
              if (shown.isEmpty) {
                return Center(
                  child: Text('No options', style: TextStyle(color: t.onSurfaceMuted)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: shown.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final o = shown[i];
                  return _OptionField(
                    key: ValueKey('$_path/${o.key}'),
                    option: o,
                    value: _changes.containsKey(o.key) ? _changes[o.key] : o.value,
                    changed: _changes.containsKey(o.key),
                    onChanged: (v) => setState(() {
                      if (v == o.value) {
                        _changes.remove(o.key);
                      } else {
                        _changes[o.key] = v;
                      }
                    }),
                  );
                },
              );
            }(),
            AsyncError(:final error) => ErrorPanel(
              error,
              onRetry: () => ref.invalidate(configProvider((widget.server.id, _path))),
            ),
            _ => const Loading(),
          },
        ),
        if (_changes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('${_changes.length} changed', style: TextStyle(color: t.onSurfaceMuted)),
                ),
                TextButton(onPressed: () => setState(_changes.clear), child: const Text('Discard')),
                const SizedBox(width: 8),
                FilledButton(onPressed: _saving ? null : _save, child: const Text('Save')),
              ],
            ),
          ),
      ],
    );
  }
}

class _OptionField extends StatelessWidget {
  const _OptionField({
    super.key,
    required this.option,
    required this.value,
    required this.changed,
    required this.onChanged,
  });
  final ConfigOption option;
  final Object? value;
  final bool changed;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final o = option;
    final title = Row(
      children: [
        Expanded(
          child: Text(o.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        if (changed)
          Text(
            'Changed',
            style: TextStyle(color: t.primary, fontSize: 13, fontWeight: FontWeight.w700),
          ),
      ],
    );
    final keyText = Text(o.key, style: TextStyle(color: t.onSurfaceMuted, fontSize: 13));

    Widget field;
    switch (o.type) {
      case ConfigOptionType.boolean:
        return AppCard(
          padding: const EdgeInsets.fromLTRB(18, 8, 10, 8),
          child: MergeSemantics(
            child: Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, keyText]),
                ),
                Switch(value: value == true || value == 'true', onChanged: onChanged),
              ],
            ),
          ),
        );
      case ConfigOptionType.select:
        field = DropdownButtonFormField<String>(
          initialValue: o.options.contains('$value') ? '$value' : null,
          isExpanded: true,
          items: [for (final v in o.options) DropdownMenuItem(value: v, child: Text(v))],
          onChanged: onChanged,
        );
      case ConfigOptionType.multiselect:
        final v0 = value;
        final selected = v0 is List ? v0.map((e) => '$e').toSet() : <String>{};
        field = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in o.options)
              FilterChip(
                label: Text(v),
                selected: selected.contains(v),
                selectedColor: t.selectedFill,
                labelStyle: TextStyle(color: t.onSurface),
                showCheckmark: true,
                checkmarkColor: t.primary,
                onSelected: (on) {
                  final next = <String>{...selected};
                  on ? next.add(v) : next.remove(v);
                  onChanged(o.options.where(next.contains).toList());
                },
              ),
          ],
        );
      case ConfigOptionType.integer || ConfigOptionType.float:
        field = _NumberField(option: o, value: value, onChanged: onChanged);
      default:
        field = TextFormField(initialValue: value?.toString() ?? '', onChanged: onChanged);
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [title, keyText, const SizedBox(height: 10), field],
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({required this.option, required this.value, required this.onChanged});
  final ConfigOption option;
  final Object? value;
  final ValueChanged<Object?> onChanged;
  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final _c = TextEditingController(text: widget.value?.toString() ?? '');
  String? _error;

  bool get _isInt => widget.option.type == ConfigOptionType.integer;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _parse(String s) {
    final o = widget.option;
    final num? n = _isInt ? int.tryParse(s) : double.tryParse(s);
    String? err;
    if (n == null) {
      err = _isInt ? 'Enter a whole number' : 'Enter a number';
    } else if (o.min != null && n < o.min!) {
      err = 'At least ${o.min}';
    } else if (o.max != null && n > o.max!) {
      err = 'At most ${o.max}';
    }
    setState(() => _error = err);
    if (err == null) widget.onChanged(n);
  }

  void _step(int dir) {
    final o = widget.option;
    final cur = num.tryParse(_c.text) ?? o.min ?? 0;
    var next = cur + dir * (o.step ?? 1);
    if (o.min != null && next < o.min!) next = o.min!;
    if (o.max != null && next > o.max!) next = o.max!;
    // Trim float noise such as 0.30000000000000004.
    _c.text = _isInt ? next.round().toString() : double.parse(next.toStringAsFixed(6)).toString();
    _parse(_c.text);
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.option;
    final range = [if (o.min != null) 'min ${o.min}', if (o.max != null) 'max ${o.max}'].join(', ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _c,
            keyboardType: TextInputType.numberWithOptions(decimal: !_isInt, signed: (o.min ?? -1) < 0),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(_isInt ? r'[-0-9]' : r'[-0-9.]'))],
            onChanged: _parse,
            decoration: InputDecoration(errorText: _error, helperText: range.isEmpty ? null : range),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(tooltip: 'Decrease ${o.label}', icon: const Icon(AppIcons.decrease), onPressed: () => _step(-1)),
        IconButton(tooltip: 'Increase ${o.label}', icon: const Icon(AppIcons.add), onPressed: () => _step(1)),
      ],
    );
  }
}
