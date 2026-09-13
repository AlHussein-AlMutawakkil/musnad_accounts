import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musnad_app/main.dart';

void main() {
  testWidgets('MusnadApp smoke test with navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(const MusnadApp());
    expect(find.text('مُسند - الحسابات والديون'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('العمليات'), findsOneWidget);
    expect(find.text('الحسابات'), findsOneWidget);
    expect(find.text('التقارير'), findsOneWidget);
    expect(find.text('المزيد'), findsOneWidget);

    // Tap on More tab
    await tester.tap(find.text('المزيد'));
    await tester.pumpAndSettle();

    expect(find.text('المزيد والإعدادات'), findsOneWidget);
    expect(find.text('إدارة العملات'), findsOneWidget);
    expect(find.text('إدارة التصنيفات المالية'), findsOneWidget);

    // Tap on إدارة العملات
    await tester.tap(find.text('إدارة العملات'));
    await tester.pumpAndSettle();

    // Verify CurrenciesView
    expect(find.text('إدارة العملات'), findsWidgets);

    // Go back
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Tap on إدارة التصنيفات المالية
    await tester.tap(find.text('إدارة التصنيفات المالية'));
    await tester.pumpAndSettle();

    // Verify CategoriesView
    expect(find.text('إدارة التصنيفات المالية'), findsWidgets);
  });
}
