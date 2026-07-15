import 'package:flutter_test/flutter_test.dart';
import 'package:foodvision_ai/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodVisionAI());

    expect(find.text('FoodVision AI'), findsNWidgets(2));
  });
}