class Product {
  final String name;
  final String description;
  final int price;
  final String image; // asset path for now, URL later from API
  final String brand;
  final String size;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.brand = '',
    this.size = '',
  });
}