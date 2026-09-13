import 'package:flutter_test/flutter_test.dart';
import 'package:musnad_app/models/models.dart';

void main() {
  group('Models Serialization and Functionality Tests', () {
    test('CurrencyModel toMap and fromMap works correctly', () {
      final now = DateTime.now();
      final currency = CurrencyModel(
        id: 'c1',
        name: 'ريال يمني',
        symbol: 'ر.ي',
        code: 'YER',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
        isSynced: true,
      );

      final map = currency.toMap();
      expect(map['is_default'], 1);
      expect(map['is_synced'], 1);

      final fromMap = CurrencyModel.fromMap(map);
      expect(fromMap.id, 'c1');
      expect(fromMap.name, 'ريال يمني');
      expect(fromMap.code, 'YER');
      expect(fromMap.isDefault, isTrue);
      expect(fromMap.isSynced, isTrue);
      expect(fromMap.isDeleted, isFalse);
    });

    test('CategoryModel toMap and fromMap works correctly', () {
      final now = DateTime.now();
      final category = CategoryModel(
        id: 'cat1',
        name: 'عملاء',
        colorHex: '#1B365D',
        iconName: 'person',
        createdAt: now,
        updatedAt: now,
      );

      final map = category.toMap();
      final fromMap = CategoryModel.fromMap(map);
      expect(fromMap.id, 'cat1');
      expect(fromMap.name, 'عملاء');
      expect(fromMap.colorHex, '#1B365D');
      expect(fromMap.iconName, 'person');
    });

    test('AccountModel toMap and fromMap works correctly', () {
      final now = DateTime.now();
      final account = AccountModel(
        id: 'acc1',
        name: 'محمد عبدالله',
        phone: '777000000',
        notes: 'حساب تجاري',
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );

      final map = account.toMap();
      final fromMap = AccountModel.fromMap(map);
      expect(fromMap.id, 'acc1');
      expect(fromMap.name, 'محمد عبدالله');
      expect(fromMap.phone, '777000000');
      expect(fromMap.categoryId, 'cat1');
    });

    test('TransactionModel toMap and fromMap works correctly', () {
      final now = DateTime.now();
      final tx = TransactionModel(
        id: 'tx1',
        accountId: 'acc1',
        currencyId: 'c1',
        categoryId: 'cat1',
        type: TransactionType.credit,
        amount: 25000.0,
        details: 'تسديد دفعة',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(tx.isCredit, isTrue);
      expect(tx.isDebit, isFalse);
      expect(tx.type.label, 'له');
      expect(tx.type.accountingLabel, 'دائن');

      final map = tx.toMap();
      expect(map['type'], 'CREDIT');
      expect(map['category_id'], 'cat1');

      final fromMap = TransactionModel.fromMap(map);
      expect(fromMap.id, 'tx1');
      expect(fromMap.amount, 25000.0);
      expect(fromMap.type, TransactionType.credit);
      expect(fromMap.categoryId, 'cat1');
    });

    test('TransferModel toMap and fromMap works correctly', () {
      final now = DateTime.now();
      final transfer = TransferModel(
        id: 'tr1',
        fromAccountId: 'acc1',
        toAccountId: 'acc2',
        fromCurrencyId: 'c1',
        toCurrencyId: 'c2',
        fromAmount: 535000.0,
        toAmount: 1000.0,
        exchangeRate: 535.0,
        date: now,
        notes: 'مصارفة ريال لدولار',
        createdAt: now,
        updatedAt: now,
      );

      expect(transfer.isSameCurrency, isFalse);
      expect(transfer.isExchange, isTrue);

      final map = transfer.toMap();
      final fromMap = TransferModel.fromMap(map);
      expect(fromMap.id, 'tr1');
      expect(fromMap.fromAmount, 535000.0);
      expect(fromMap.toAmount, 1000.0);
      expect(fromMap.exchangeRate, 535.0);
    });
  });
}
