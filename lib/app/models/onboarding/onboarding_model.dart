// ==================== MODELS ====================

class OnboardingItem {
  final String image;
  final String title;
  final String subTitle;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.subTitle,
  });

  factory OnboardingItem.fromJson(Map<String, dynamic> json) {
    return OnboardingItem(
      image: json['image'],
      title: json['title'],
      subTitle: json['subTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'subTitle': subTitle,
    };
  }
}