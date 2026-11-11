import 'package:exaton/ui/theme.dart';
import 'package:exaton/ui/toast.dart';
import 'package:exaton/ui/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BuildContext ctx;

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(AppTokens.dark, Brightness.dark),
      home: Builder(
        builder: (c) {
          ctx = c;
          return const Scaffold(body: SizedBox());
        },
      ),
    ),
  );

  testWidgets('shows, then hides after its duration', (tester) async {
    await pump(tester);
    showToast(ctx, 'Backup saved', tone: Tone.success, duration: const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Backup saved'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Backup saved'), findsNothing);
  });

  testWidgets('a new toast replaces the current one', (tester) async {
    await pump(tester);
    showToast(ctx, 'First');
    await tester.pumpAndSettle();
    showToast(ctx, 'Second');
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    Toaster.of(ctx)!.hide();
    await tester.pumpAndSettle();
  });

  testWidgets('action runs and closes the toast', (tester) async {
    await pump(tester);
    var ran = false;
    showToast(ctx, 'Update available', actionLabel: 'Download', onAction: () => ran = true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Download'));
    await tester.pumpAndSettle();
    expect(ran, isTrue);
    expect(find.text('Update available'), findsNothing);
  });

  testWidgets('dismiss button closes it', (tester) async {
    await pump(tester);
    showToast(ctx, 'Address copied');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text('Address copied'), findsNothing);
  });
}
