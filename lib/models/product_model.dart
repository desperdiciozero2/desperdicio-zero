class Product {
  final String id;
  final String name;
  final String type; // Ex: Alimento, Bebida, Limpeza, etc.
  final double quantity;
  final String unit; // Ex: kg, g, L, ml, un
  final DateTime purchaseDate;
  final DateTime? expirationDate;
  final String? brand;
  final String? store;
  final double price;
  final bool isConsumed;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    this.expirationDate,
    this.brand,
    this.store,
    required this.price,
    this.isConsumed = false,
  });

  // Converte o produto para um Map (útil para salvar no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'quantity': quantity,
      'unit': unit,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'brand': brand,
      'store': store,
      'price': price,
      'isConsumed': isConsumed,
    };
  }

  // Cria um produto a partir de um Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      quantity: map['quantity'].toDouble(),
      unit: map['unit'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      expirationDate: map['expirationDate'] != null
          ? DateTime.parse(map['expirationDate'])
          : null,
      brand: map['brand'],
      store: map['store'],
      price: map['price'].toDouble(),
      isConsumed: map['isConsumed'] ?? false,
    );
  }

  // Cria uma cópia do produto com os campos atualizados
  Product copyWith({
    String? id,
    String? name,
    String? type,
    double? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expirationDate,
    String? brand,
    String? store,
    double? price,
    bool? isConsumed,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expirationDate: expirationDate ?? this.expirationDate,
      brand: brand ?? this.brand,
      store: store ?? this.store,
      price: price ?? this.price,
      isConsumed: isConsumed ?? this.isConsumed,
    );
  }
}
