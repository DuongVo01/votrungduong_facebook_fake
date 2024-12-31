class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  final int? id;
  final String? name;
  final double? price;
  final String? image;
  final String? description;

  factory Product.fromJson(Map<String, dynamic> json){
    return Product(
      id: json["id"],
      name: json["name"],
      price: json["price"],
      image: json["image"],
      description: json["description"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "image": image,
    "description": description,
  };

}
