import 'package:flutter_test/flutter_test.dart';
import 'package:vastranaveen/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AiVastraApp());
    expect(find.byType(AiVastraApp), findsOneWidget);
  });
}

