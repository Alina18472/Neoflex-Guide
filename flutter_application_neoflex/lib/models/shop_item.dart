

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imagePath;
  final String qrData; // Уникальный код для QR
  final String status; // 'pending', 'issued'

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.qrData,
    this.status = 'pending', // По умолчанию "ожидает получения"
  });

  // Преобразование в Map для SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'qr_data': qrData,
      'status': status,
    };
  }

  // Создание из Map (из данных SQLite)
  factory ShopItem.fromMap(Map<String, dynamic> map) {
    return ShopItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imagePath: map['imagePath'],
      qrData: map['qr_data'] ?? '', // Если нет в БД - пустая строка
      status: map['status'] ?? 'pending', // По умолчанию "ожидает"
    );
  }

  // Копирование с обновлением полей (полезно для обновления статуса)
  ShopItem copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? imagePath,
    String? qrData,
    String? status,
  }) {
    return ShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      qrData: qrData ?? this.qrData,
      status: status ?? this.status,
    );
  }

  // Для отладки
  @override
  String toString() {
    return 'ShopItem{id: $id, name: $name, status: $status, qrData: ${qrData.substring(0, 5)}...}';
  }

  // Сравнение объектов
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          qrData == other.qrData;

  @override
  int get hashCode => id.hashCode ^ qrData.hashCode;

  // Вспомогательные методы
  bool get isPending => status == 'pending';
  bool get isIssued => status == 'issued';
  
}