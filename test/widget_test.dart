import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:walleterium/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final auth = MockFirebaseAuth();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
  });
}
