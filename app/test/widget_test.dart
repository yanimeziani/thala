import 'package:flutter_test/flutter_test.dart';

import 'package:thala/main.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(const ThalaRoot());
    await tester.pump();

    expect(find.textContaining('Supabase credentials'), findsOneWidget);
  });
}
