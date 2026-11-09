import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/modules/manga/reader/widgets/reader_overlays.dart';
import 'package:mangayomi/providers/reader_state_provider.dart';

class _NoTapZones extends UsePageTapZonesState {
  @override
  bool build() => false;
}

class _Layout extends ReaderNavigationLayoutState {
  @override
  int build() => 0;
}

class _Inversion extends TappingInversionState {
  @override
  int build() => 0;
}

void main() {
  Widget overlays({required bool isFlashing, required Color color}) {
    return ProviderScope(
      overrides: [
        usePageTapZonesStateProvider.overrideWith(_NoTapZones.new),
        readerNavigationLayoutStateProvider.overrideWith(_Layout.new),
        tappingInversionStateProvider.overrideWith(_Inversion.new),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ReaderOverlays(
            isReverseHorizontal: false,
            hasCurrentPageImageError: false,
            isContinuousMode: false,
            onToggleUI: () {},
            onPreviousPage: () {},
            onNextPage: () {},
            isFlashing: isFlashing,
            flashOverlayColor: color,
            showNavigationOverlay: false,
            onCloseNavigationOverlay: () {},
          ),
        ),
      ),
    );
  }

  double flashOpacity(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.byType(FadeTransition),
        ),
      )
      .opacity
      .value;

  testWidgets('a flash is on at once, so a short white half is seen', (
    tester,
  ) async {
    await tester.pumpWidget(overlays(isFlashing: false, color: Colors.white));
    expect(flashOpacity(tester), 0);

    await tester.pumpWidget(overlays(isFlashing: true, color: Colors.white));
    await tester.pump();
    expect(flashOpacity(tester), 1);
  });

  testWidgets('a flash fades out rather than cutting off', (tester) async {
    await tester.pumpWidget(overlays(isFlashing: true, color: Colors.black));
    await tester.pump();
    await tester.pumpWidget(overlays(isFlashing: false, color: Colors.black));
    await tester.pump(const Duration(milliseconds: 20));
    expect(flashOpacity(tester), allOf(greaterThan(0), lessThan(1)));
    await tester.pumpAndSettle();
    expect(flashOpacity(tester), 0);
  });
}
