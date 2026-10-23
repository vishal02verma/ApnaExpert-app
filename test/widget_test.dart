import 'package:flutter_test/flutter_test.dart';
import 'package:fix_near/main.dart';

void main() {
  testWidgets('ApnaExpert app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ApnaExpertApp());
    expect(find.text('Best Helping\nHands For You'), findsWidgets);
    expect(find.text('Get Started'), findsWidgets);
  });
}
