// ==================== MODELS ====================

// models/favorite_item.dart
class FavoriteItem {
  final String id;
  final String imageUrl;
  final String authorName;
  final String authorImage;
  final String size;
  final double price;
  final bool isFavorite;

  FavoriteItem({
    required this.id,
    required this.imageUrl,
    required this.authorName,
    required this.authorImage,
    required this.size,
    required this.price,
    this.isFavorite = true,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'],
      imageUrl: json['imageUrl'],
      authorName: json['authorName'],
      authorImage: json['authorImage'],
      size: json['size'],
      price: json['price'].toDouble(),
      isFavorite: json['isFavorite'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'authorName': authorName,
      'authorImage': authorImage,
      'size': size,
      'price': price,
      'isFavorite': isFavorite,
    };
  }

  FavoriteItem copyWith({
    String? id,
    String? imageUrl,
    String? authorName,
    String? authorImage,
    String? size,
    double? price,
    bool? isFavorite,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      size: size ?? this.size,
      price: price ?? this.price,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// models/sort_option.dart
enum SortType {
  priceHighToLow,
  priceLowToHigh,
  sizeHighToLow,
  sizeLowToHigh,
}

class SortOption {
  final SortType type;
  final String label;

  SortOption({
    required this.type,
    required this.label,
  });

  static List<SortOption> get defaultOptions => [
        SortOption(type: SortType.priceHighToLow, label: 'Price High To Low'),
        SortOption(type: SortType.priceLowToHigh, label: 'Price Low to High'),
        SortOption(type: SortType.sizeHighToLow, label: 'Size High to Low'),
        SortOption(type: SortType.sizeLowToHigh, label: 'Size Low to High'),
      ];
}
