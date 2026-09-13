import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musnad_app/core/widgets/widgets.dart';
import 'package:musnad_app/models/models.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('AppCard renders child and responds to tap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      createTestWidget(
        AppCard(
          onTap: () => tapped = true,
          child: const Text('Test Card'),
        ),
      ),
    );

    expect(find.text('Test Card'), findsOneWidget);
    await tester.tap(find.text('Test Card'));
    expect(tapped, isTrue);
  });

  testWidgets('AppKpiCard renders title, amount, and symbol', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        const AppKpiCard(
          title: 'إجمالي له',
          amount: 150000.0,
          currencySymbol: 'ر.ي',
          type: KpiType.credit,
        ),
      ),
    );

    expect(find.text('إجمالي له'), findsOneWidget);
    expect(find.text('150,000'), findsOneWidget);
    expect(find.text('ر.ي'), findsOneWidget);
  });

  testWidgets('AppTypeToggle renders both options and switches type', (WidgetTester tester) async {
    TransactionType currentType = TransactionType.credit;

    await tester.pumpWidget(
      createTestWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return AppTypeToggle(
              selectedType: currentType,
              onTypeChanged: (type) {
                setState(() {
                  currentType = type;
                });
              },
            );
          },
        ),
      ),
    );

    expect(find.text('له (دائن)'), findsOneWidget);
    expect(find.text('عليه (مدين)'), findsOneWidget);

    await tester.tap(find.text('عليه (مدين)'));
    await tester.pumpAndSettle();

    expect(currentType, TransactionType.debit);
  });

  testWidgets('AppPrimaryButton renders text and triggers onPressed', (WidgetTester tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      createTestWidget(
        AppPrimaryButton(
          text: 'حفظ القيد',
          onPressed: () => pressed = true,
        ),
      ),
    );

    expect(find.text('حفظ القيد'), findsOneWidget);
    await tester.tap(find.text('حفظ القيد'));
    expect(pressed, isTrue);
  });

  testWidgets('AppTransactionTile renders entry correctly', (WidgetTester tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      createTestWidget(
        AppTransactionTile(
          type: TransactionType.credit,
          amount: 5000.0,
          currencySymbol: 'ر.ي',
          details: 'دفعة نقدية',
          date: now,
        ),
      ),
    );

    expect(find.text('دفعة نقدية'), findsOneWidget);
    expect(find.text('+5,000'), findsOneWidget);
    expect(find.text('له'), findsOneWidget);
  });

  testWidgets('AppKpiCard handles large amounts in narrow widths without overflow', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        const SizedBox(
          width: 90.0,
          child: AppKpiCard(
            title: 'إجمالي له',
            amount: 954000000.0,
            currencySymbol: 'ر.ي',
            type: KpiType.credit,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
      ),
    );

    expect(find.text('إجمالي له'), findsOneWidget);
    expect(find.text('954,000,000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
