import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/modules/manga/reader/widgets/reader_wheel_interceptor.dart';

void main() {
  Future<PageController> pump(
    WidgetTester tester, {
    required bool Function(PointerScrollEvent event)? onWheel,
  }) async {
    final controller = PageController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ReaderWheelInterceptor(
          onWheel: onWheel,
          child: PageView(
            scrollDirection: Axis.vertical,
            controller: controller,
            children: const [Placeholder(), Placeholder()],
          ),
        ),
      ),
    );
    return controller;
  }

  Future<void> wheel(WidgetTester tester, Offset delta) async {
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(const Offset(100, 100)));
    await tester.sendEventToBinding(pointer.scroll(delta));
    await tester.pump();
  }

  testWidgets('a wheel it uses does not scroll the page view under it', (
    tester,
  ) async {
    final seen = <Offset>[];
    final controller = await pump(
      tester,
      onWheel: (event) {
        seen.add(event.scrollDelta);
        return true;
      },
    );

    await wheel(tester, const Offset(0, 40));

    expect(seen, [const Offset(0, 40)]);
    expect(controller.position.pixels, 0);
  });

  testWidgets('a wheel it does not use reaches the page view', (tester) async {
    final controller = await pump(tester, onWheel: (event) => false);

    await wheel(tester, const Offset(0, 40));

    expect(controller.position.pixels, greaterThan(0));
  });

  testWidgets('without a handler the page view scrolls as usual', (
    tester,
  ) async {
    final controller = await pump(tester, onWheel: null);

    await wheel(tester, const Offset(0, 40));

    expect(controller.position.pixels, greaterThan(0));
  });
}
