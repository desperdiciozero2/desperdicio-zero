// Product model for the Desperdício Zero app
// Represents a product in the user's inventory

class Product {
  final String id;
  final String userId;
  final String name;
  final num quantity;
  final String unit;
  final DateTime? expirationDate;
  final String? type;  // e.g., 'food', 'beverage', 'cleaning', etc.
  final String? brand;
  final String? store;
  final double? price;
  final bool isConsumed;
  final DateTime? purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.expirationDate,
    this.type,
    this.brand,
    this.store,
    this.price,
    this.isConsumed = false,
    this.purchaseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Converte o produto para um Map (para salvar no banco de dados)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiration_date': expirationDate?.toIso8601String(),
      'type': type,
      'brand': brand,
      'store': store,
      'price': price,
      'is_consumed': isConsumed,
      'purchase_date': purchaseDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Creates a Product from a Map (from database)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as num,
      unit: json['unit'] as String,
      expirationDate: json['expiration_date'] != null 
          ? DateTime.tryParse(json['expiration_date'] as String)
          : null,
      type: json['type'] as String?,
      brand: json['brand'] as String?,
      store: json['store'] as String?,
      price: json['price']?.toDouble(),
      isConsumed: json['is_consumed'] as bool? ?? false,
      purchaseDate: json['purchase_date'] != null
          ? DateTime.tryParse(json['purchase_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Creates a copy of the product with some fields updated
  Product copyWith({
    String? id,
    String? userId,
    String? name,
    num? quantity,
    String? unit,
    DateTime? expirationDate,
    String? type,
    String? brand,
    String? store,
    double? price,
    bool? isConsumed,
    DateTime? purchaseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expirationDate: expirationDate ?? this.expirationDate,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      store: store ?? this.store,
      price: price ?? this.price,
      isConsumed: isConsumed ?? this.isConsumed,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, quantity: $quantity $unit, expires: $expirationDate)';
  }

  // Converts to a format suitable for PostgREST
  Map<String, dynamic> toPostgrest() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiration_date': expirationDate?.toIso8601String(),
      'type': type,
      'brand': brand,
      'store': store,
      'price': price,
      'is_consumed': isConsumed,
      'purchase_date': purchaseDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
