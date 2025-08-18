// ==================== MODELS ====================

// models/legal_section.dart
class LegalSection {
  final String id;
  final String title;
  final String content;
  final int order;
  final LegalDocumentType documentType;

  LegalSection({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    required this.documentType,
  });

  factory LegalSection.fromJson(Map<String, dynamic> json) {
    return LegalSection(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      order: json['order'],
      documentType: LegalDocumentType.values.firstWhere(
        (type) => type.name == json['documentType'],
        orElse: () => LegalDocumentType.privacyPolicy,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'order': order,
      'documentType': documentType.name,
    };
  }
}

// models/legal_document_type.dart
enum LegalDocumentType {
  privacyPolicy,
  termsOfService,
}

extension LegalDocumentTypeExtension on LegalDocumentType {
  String get displayName {
    switch (this) {
      case LegalDocumentType.privacyPolicy:
        return 'Privacy Policy';
      case LegalDocumentType.termsOfService:
        return 'Terms of Services';
    }
  }

  String get fileName {
    switch (this) {
      case LegalDocumentType.privacyPolicy:
        return 'privacy_policy';
      case LegalDocumentType.termsOfService:
        return 'terms_of_service';
    }
  }
}