import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tests_aique/utils/cart_calculator.dart';

void main() {
  group('CartCalculator Unit Tests', () {
    late CartCalculator cart;

    setUp(() {
      cart = CartCalculator();
    });

    test('Add item increases subtotal accurately', () {
      cart.addItem(10.0, quantity: 2);
      cart.addItem(5.0);

      expect(cart.subtotal, 25.0);
    });

    test('Calculate total applies tax and discount', () {
      cart.addItem(100.0);

      final total = cart.calculateTotal(taxRate: 0.08, discount: 10.0);

      expect(total, 97.20);
    });

    test('Clear cart resets subtotal to zero', () {
      cart.addItem(50.0);
      cart.clearCart();

      expect(cart.subtotal, 0.0);
    });

    test('Negative price throws ArgumentError', () {
      expect(() => cart.addItem(-10.0), throwsArgumentError);
    });
  });
}
