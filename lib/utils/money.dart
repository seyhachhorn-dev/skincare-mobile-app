/// Customer-facing prices in this app are stored as whole US dollars.
class Money {
  const Money._();

  static String usd(num dollars) => '\$${dollars.toStringAsFixed(2)}';

  static String usdCents(int cents) => usd(cents / 100);
}
