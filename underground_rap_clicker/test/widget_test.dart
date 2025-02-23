import 'package:flutter_test/flutter_test.dart';
import 'package:underground_rap_clicker/main.dart';

void main() {
  testWidgets('MyApp has a title', (WidgetTester tester) async {
    // Если конструктор MyApp объявлен как const, то можно вызывать его с const
    await tester.pumpWidget(const MyApp());
    final titleFinder = find.text('Underground Rap Clicker');
    expect(titleFinder, findsOneWidget);
  });
}