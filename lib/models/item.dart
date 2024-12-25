class Item {
  final int? id;
  final String name;
  final String date;
  final double price;

  Item({this.id, required this.name, required this.date, required this.price});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'price': price,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      price: map['price'],
    );
  }
}
