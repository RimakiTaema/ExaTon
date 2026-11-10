import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/exaroton/client.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';
import 'accounts.dart';
import '../../ui/app_icons.dart';

/// Add an account by API token. Not drawn in the mockups yet; follows the
/// same tokens and components.
class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key, this.popOnDone = false});
  final bool popOnDone;

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _token = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_token.text.trim().isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final a = await ref.read(accountsProvider.notifier).add(_token.text);
      if (!mounted) return;
      showMessage(context, 'Signed in as ${a.name}');
      if (widget.popOnDone) Navigator.of(context).pop();
    } on ExarotonException catch (e) {
      setState(() => _error = e.isUnauthorized ? 'That token was not accepted. Check it and try again.' : e.message);
    } on PlatformException catch (e) {
      // Secure storage refused the write (keychain, keystore, libsecret).
      setState(() => _error = 'Could not save the token in secure storage (${e.code}).');
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      appBar: widget.popOnDone ? AppBar(title: const Text('Add account')) : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(gutter),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.popOnDone) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(16)),
                        child: Text(
                          'Ex',
                          style: TextStyle(color: t.onPrimary, fontWeight: FontWeight.w800, fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Welcome to ExaTon', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'Paste an API token from your exaroton account page. It is kept in your '
                    'system\'s secure storage and only sent to api.exaroton.com.',
                    style: TextStyle(color: t.onSurfaceMuted, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _token,
                    obscureText: _obscure,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'API token',
                      errorText: _error,
                      prefixIcon: const Icon(AppIcons.token),
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'Show token' : 'Hide token',
                        icon: Icon(_obscure ? AppIcons.show : AppIcons.hide),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: t.onPrimary),
                          )
                        : const Text('Sign in'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        launchUrl(Uri.parse('https://exaroton.com/account/'), mode: LaunchMode.externalApplication),
                    child: const Text('Get a token on exaroton'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
