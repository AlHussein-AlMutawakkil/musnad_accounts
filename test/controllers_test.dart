import 'package:flutter_test/flutter_test.dart';
import 'package:musnad_app/controllers/controllers.dart';
import 'package:musnad_app/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Controllers Initial State & Logic Tests', () {
    test('CurrencyController initial state is clean and lookup methods work', () {
      final controller = CurrencyController();
      expect(controller.currencies, isEmpty);
      expect(controller.selectedCurrency, isNull);
      expect(controller.defaultCurrency, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.getCurrencyById('non-existent'), isNull);
      expect(controller.getCurrencyByCode('USD'), isNull);
    });

    test('CategoryController initial state is clean and lookup methods work', () {
      final controller = CategoryController();
      expect(controller.categories, isEmpty);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.getCategoryById('non-existent'), isNull);
    });

    test('AccountController search and category filtering logic', () {
      final controller = AccountController();
      expect(controller.accounts, isEmpty);
      expect(controller.filteredAccounts, isEmpty);

      controller.setSearchQuery('علي');
      expect(controller.searchQuery, 'علي');

      controller.setCategoryFilter('cat-123');
      expect(controller.selectedCategoryId, 'cat-123');
    });

    test('TransactionController initial state and StatementEntry structure', () {
      final controller = TransactionController();
      expect(controller.statementEntries, isEmpty);
      expect(controller.statementTotalCredit, 0.0);
      expect(controller.statementTotalDebit, 0.0);
      expect(controller.statementNetBalance, 0.0);

      final now = DateTime.now();
      final tx = TransactionModel(
        id: 'tx-1',
        accountId: 'acc-1',
        currencyId: 'cur-1',
        type: TransactionType.credit,
        amount: 1000.0,
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      final entry = StatementEntry(
        transaction: tx,
        runningBalance: 1000.0,
      );

      expect(entry.runningBalance, 1000.0);
      expect(entry.transaction.id, 'tx-1');
    });

    test('TransferController initial state is clean', () {
      final controller = TransferController();
      expect(controller.transfers, isEmpty);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
    });
  });
}
