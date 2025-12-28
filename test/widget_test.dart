import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiktok_video_downloader/src/my_app.dart';
import 'package:tiktok_video_downloader/src/container_injector.dart' as di;

void main() {
  setUpAll(() {
    di.initApp();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts (finds MaterialApp or similar)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
