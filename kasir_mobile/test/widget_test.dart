import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_mobile/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const KasirApp());
    expect(find.byType(KasirApp), findsOneWidget);
  });
}
