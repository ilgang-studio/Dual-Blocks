import 'package:flutter_test/flutter_test.dart';

import 'package:dual_blocks/main.dart';

void main() {
  testWidgets('renders app without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
