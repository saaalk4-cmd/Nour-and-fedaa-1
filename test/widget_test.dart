import 'package:flutter_test/flutter_test.dart';
import 'package:nour_and_fedaa_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first launch shows child selection', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(NourFedaaApp(prefs: prefs));
    await tester.pumpAndSettle();
    expect(find.text('نُور وفداء'), findsOneWidget);
    expect(find.text('مين هيبدأ الرحلة؟'), findsOneWidget);
    expect(find.textContaining('فداء'), findsOneWidget);
    expect(find.textContaining('نور'), findsOneWidget);
  });
}
