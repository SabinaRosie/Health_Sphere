import 'package:flutter_test/flutter_test.dart';
import 'package:health_sphere/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HealthSphereApp());

    // Verify that the app builds by checking if the Onboarding screen text is present
    expect(find.text('Get Started'), findsOneWidget);
  });
}
