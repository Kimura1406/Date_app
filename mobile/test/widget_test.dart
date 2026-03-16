import 'package:flutter_test/flutter_test.dart';
import 'package:kimura_dating/main.dart';

void main() {
  testWidgets('app renders title', (tester) async {
    await tester.pumpWidget(const KimuraApp());
    expect(find.text('Kimura'), findsOneWidget);
  });
}
