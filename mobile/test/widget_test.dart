import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/main.dart';

/// Replaces Flutter's default "counter increments" boilerplate test, which
/// referenced a MyApp class that never existed in this project (the real
/// root widget is MediVoiceApp) and tested a counter this app doesn't have.
///
/// This is a genuine smoke test: confirms the app builds and its Home
/// Screen renders without crashing - a reasonable pre-release-build check.
void main() {
  testWidgets('MediVoiceApp launches and shows the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MediVoiceApp());
    await tester.pump();

    expect(find.text('MediVoice AI'), findsWidgets);
    expect(find.text('Start Consultation'), findsOneWidget);
  });
}
