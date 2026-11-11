import 'package:flutter_test/flutter_test.dart';
import 'package:nour_and_fedaa_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows child selection on first launch', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(NourFedaaApp(prefs: prefs));
    expect(find.text('مين هتبدأ الرحلة؟'), findsOneWidget);
    expect(find.textContaining('فداء'), findsOneWidget);
    expect(find.textContaining('نور'), findsOneWidget);
  });
}
