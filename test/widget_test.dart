import 'package:flutter_test/flutter_test.dart';

import 'package:rosecare_ai/main.dart';

void main() {
  testWidgets('RoseCare app smoke test', (tester) async {
    await tester.pumpWidget(const RoseCareApp());

    expect(find.text('RoseCare AI'), findsOneWidget);
  });
}
