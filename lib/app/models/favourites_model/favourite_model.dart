// Updated FavoriteItem model to store original Photo data

import 'package:photo_bug/app/data/models/photo_model.dart';

class FavoriteItem {
  final String id;
  final String imageUrl;
  final String authorName;
  final String authorImage;
  final String size;
  final double price;
  final bool isFavorite;
  final Photo? photoData; // ✅ Add this field to store original photo

  FavoriteItem({
    required this.id,
    required this.imageUrl,
    required this.authorName,
    required this.authorImage,
    required this.size,
    required this.price,
    this.isFavorite = true,
    this.photoData, // ✅ Add this parameter
  });

  FavoriteItem copyWith({
    String? id,
    String? imageUrl,
    String? authorName,
    String? authorImage,
    String? size,
    double? price,
    bool? isFavorite,
    Photo? photoData,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      size: size ?? this.size,
      price: price ?? this.price,
      isFavorite: isFavorite ?? this.isFavorite,
      photoData: photoData ?? this.photoData, // ✅ Add this
    );
  }
}

enum SortType { priceHighToLow, priceLowToHigh, sizeHighToLow, sizeLowToHigh }

class SortOption {
  final String label;
  final SortType type;

  SortOption({required this.label, required this.type});

  static List<SortOption> get defaultOptions => [
    SortOption(label: 'Price: High to Low', type: SortType.priceHighToLow),
    SortOption(label: 'Price: Low to High', type: SortType.priceLowToHigh),
    SortOption(label: 'Size: High to Low', type: SortType.sizeHighToLow),
    SortOption(label: 'Size: Low to High', type: SortType.sizeLowToHigh),
  ];
}
