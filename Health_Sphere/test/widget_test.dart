import 'package:flutter_test/flutter_test.dart';
import 'package:health_sphere/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HealthSphereApp());

    // Verify that the app builds by checking if the Splash screen text is present initially
    expect(find.text('Health Sphere'), findsAtLeast(1));

    // Wait for splash transition to complete
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}
