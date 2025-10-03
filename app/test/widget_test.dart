import 'package:flutter_test/flutter_test.dart';

import 'package:thela/main.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(const ThelaRoot());
    await tester.pump();

    expect(find.textContaining('Supabase credentials'), findsOneWidget);
  });
}
