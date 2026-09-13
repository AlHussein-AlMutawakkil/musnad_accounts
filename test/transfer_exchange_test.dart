import 'package:flutter_test/flutter_test.dart';

enum ExchangeDirection { divide, multiply }

double calculateReceivedAmount({
  required double fromAmount,
  required double rate,
  required ExchangeDirection direction,
}) {
  if (rate <= 0 || fromAmount <= 0) return 0.0;

  double result;
  if (direction == ExchangeDirection.divide) {
    result = fromAmount / rate;
  } else {
    result = fromAmount * rate;
  }

  // التقريب إلى منزلتين عشريتين
  return double.parse(result.toStringAsFixed(2));
}

void main() {
  group('Transfer & Exchange Calculation Logic Tests', () {
    test('Converts from YER to USD using division correctly', () {
      // 10,000 ريال يمني بسعر صرف 535 يجب أن ينتج 18.69 دولار وليس 5.35 مليون دولار
      final received = calculateReceivedAmount(
        fromAmount: 10000.0,
        rate: 535.0,
        direction: ExchangeDirection.divide,
      );

      expect(received, 18.69);
      expect(received, isNot(5350000.0));
    });

    test('Converts from USD to YER using multiplication correctly', () {
      // 100 دولار بسعر صرف 535 ينتج 53,500 ريال يمني
      final received = calculateReceivedAmount(
        fromAmount: 100.0,
        rate: 535.0,
        direction: ExchangeDirection.multiply,
      );

      expect(received, 53500.0);
    });

    test('Safeguards against division by zero', () {
      final received = calculateReceivedAmount(
        fromAmount: 10000.0,
        rate: 0.0,
        direction: ExchangeDirection.divide,
      );

      expect(received, 0.0);
    });

    test('Rounds results to exactly two decimal places', () {
      final received = calculateReceivedAmount(
        fromAmount: 1000.0,
        rate: 3.0,
        direction: ExchangeDirection.divide,
      );

      // 1000 / 3 = 333.3333333333... -> 333.33
      expect(received, 333.33);
    });
  });
}
