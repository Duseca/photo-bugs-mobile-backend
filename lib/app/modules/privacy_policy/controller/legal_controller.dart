import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/models/legal_model/legal_model.dart';

class LegalController extends GetxController {
  // Observable variables
  final RxList<LegalSection> sections = <LegalSection>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<LegalDocumentType> documentType = LegalDocumentType.privacyPolicy.obs;
  final RxString lastUpdated = ''.obs;
  final RxDouble scrollProgress = 0.0.obs;
  
  // Scroll controller
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    // Get document type from arguments
    final arguments = Get.arguments;
    if (arguments != null && arguments['documentType'] != null) {
      documentType.value = arguments['documentType'];
    }
    loadLegalContent();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // Setup scroll listener for progress tracking
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.hasClients) {
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;
        scrollProgress.value = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
      }
    });
  }

  // Load legal content based on document type
  void loadLegalContent() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      List<LegalSection> loadedSections;
      
      if (documentType.value == LegalDocumentType.privacyPolicy) {
        loadedSections = _getPrivacyPolicySections();
      } else {
        loadedSections = _getTermsOfServiceSections();
      }
      
      sections.assignAll(loadedSections);
      lastUpdated.value = 'Last updated: ${DateTime.now().toString().split(' ')[0]}';
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to load ${documentType.value.displayName}');
    } finally {
      isLoading.value = false;
    }
  }

  // Get Privacy Policy sections
  List<LegalSection> _getPrivacyPolicySections() {
    return [
      LegalSection(
        id: 'pp_1',
        title: '1. Introduction',
        content: 'Welcome to Photobugs! We value your privacy and are committed to protecting your personal information. This Privacy Policy outlines how we collect, use, and safeguard your data when you use our app.',
        order: 1,
        documentType: LegalDocumentType.privacyPolicy,
      ),
      LegalSection(
        id: 'pp_2',
        title: '2. Information We Collect',
        content: '- Personal Information: When you sign up, we collect your name, email address, and other contact details.\n- Photos and Content: We collect the photos and other content you upload, share, and sell on Photobugs.\n- Usage Data: We collect information about how you use the app, including your interactions, preferences, and device information.',
        order: 2,
        documentType: LegalDocumentType.privacyPolicy,
      ),
      LegalSection(
        id: 'pp_3',
        title: '3. How We Use Your Information',
        content: '- To Provide Services: We use your information to operate and improve Photobugs, including facilitating photo uploads, sharing, and sales.\n- To Communicate: We may use your contact information to send you updates, notifications, and promotional materials.\n- To Enhance Security: We use your data to detect and prevent fraud, abuse, and other harmful activities.',
        order: 3,
        documentType: LegalDocumentType.privacyPolicy,
      ),
      LegalSection(
        id: 'pp_4',
        title: '4. Sharing Your Information',
        content: '- With Third Parties: We may share your information with trusted third-party service providers to help us operate and improve Photobugs.\n- Legal Requirements: We may disclose your information if required by law or to protect our rights and users\' safety.',
        order: 4,
        documentType: LegalDocumentType.privacyPolicy,
      ),
      LegalSection(
        id: 'pp_5',
        title: '5. Your Rights',
        content: '- Access and Control: You can access, update, or delete your personal information through your account settings.\n- Opt-Out: You can opt-out of receiving promotional communications by following the instructions in those messages.',
        order: 5,
        documentType: LegalDocumentType.privacyPolicy,
      ),
      LegalSection(
        id: 'pp_6',
        title: '6. Data Security',
        content: 'We implement industry-standard security measures to protect your data, including encryption, firewalls, and secure server environments. However, no method of transmission over the internet or electronic storage is 100% secure.',
        order: 6,
        documentType: LegalDocumentType.privacyPolicy,
      ),
      LegalSection(
        id: 'pp_7',
        title: '7. Consent',
        content: 'By using Photobugs, you consent to the collection, use, and sharing of your information as described in this Privacy Policy. You may withdraw your consent at any time by deleting your account.',
        order: 7,
        documentType: LegalDocumentType.privacyPolicy,
      ),
      LegalSection(
        id: 'pp_8',
        title: '8. Data Retention',
        content: 'We retain your personal information for as long as necessary to provide our services. If you delete your account, we will delete your personal information, except where legally required to retain it.',
        order: 8,
        documentType: LegalDocumentType.privacyPolicy,
      ),
      LegalSection(
        id: 'pp_9',
        title: '9. Model Releases and Consent',
        content: '- Model Releases: If you upload photos featuring identifiable individuals, you must obtain and retain a signed model release.\n- User Consent: By using Photobugs, you confirm that you have obtained necessary consents from individuals featured in your photos.',
        order: 9,
        documentType: LegalDocumentType.privacyPolicy,
      ),
      LegalSection(
        id: 'pp_10',
        title: '10. Use at Your Own Risk',
        content: 'By using Photobugs, you acknowledge and agree that you do so at your own risk. We are not liable for any issues, damages, or losses arising from your use of the app.',
        order: 10,
        documentType: LegalDocumentType.privacyPolicy,
      ),
      LegalSection(
        id: 'pp_11',
        title: '11. Changes to This Policy',
        content: 'We reserve the right to update this Privacy Policy at any time. We will notify you of any changes by posting the new policy on this page.',
        order: 11,
        documentType: LegalDocumentType.privacyPolicy,
      ),
    ];
  }

  // Get Terms of Service sections
  List<LegalSection> _getTermsOfServiceSections() {
    return [
      LegalSection(
        id: 'tos_1',
        title: '1. Consent and Ownership',
        content: 'Agreement to List Pictures: By clicking "Continue," you agree to have your pictures listed on the app. This means your pictures will be visible to other users and potentially to the public, depending on the app\'s settings.\n\n'
            'Transfer of Ownership: You forfeit all ownership rights to the app, the purchaser of the picture, and the photographer. This means:\n\n'
            'Control: You no longer have control over how your pictures are used, distributed, or modified. The app, the purchaser, and the photographer can use your pictures in any way they see fit without needing your permission.\n\n'
            'Financial Rights: You won\'t receive any financial compensation for the use of your pictures. Any profits made from your pictures will go to the app, the purchaser, or the photographer.\n\n'
            'Legal Rights: You forfeit the ability to enforce your rights if your pictures are used in a way that violates your privacy or other legal protections. The new owners of the pictures will have the legal rights to them.\n\n'
            'Right to Post: Despite forfeiting ownership, you retain the right to have your pictures posted on the app. This means you can still upload and share your pictures on the platform, but you won\'t have ownership rights over them.',
        order: 1,
        documentType: LegalDocumentType.termsOfService,
      ),
      LegalSection(
        id: 'tos_2',
        title: '2. Changes to Rules and Regulations',
        content: 'Updates and Modifications: The app\'s rules and regulations can be updated or changed at any time. This means that the terms you agree to today might be different in the future.\n\n'
            'Notification of Changes: The app may or may not notify you of these changes. It\'s your responsibility to stay informed about any updates to the rules and regulations.\n\n'
            'Impact of Changes: Changes to the rules and regulations will affect how your pictures are used, your rights, and your obligations. It\'s important to regularly review the privacy policy to understand any new terms.',
        order: 2,
        documentType: LegalDocumentType.termsOfService,
      ),
      LegalSection(
        id: 'tos_3',
        title: '3. Legal Actions and Compensation',
        content: 'No Legal Recourse: By clicking "Continue," you agree that you cannot sue or take any legal action against the app, the purchaser of the picture, or the photographer for any reason related to the use of your pictures.\n\n'
            'No Compensation: You agree that you will not ask for or receive any financial compensation or other forms of payment for the use of your pictures. This includes any profits made from your pictures by the app, the purchaser, or the photographer.\n\n'
            'Binding Agreement: This agreement is binding and enforceable, meaning you are legally obligated to adhere to these terms and cannot challenge them in court.',
        order: 3,
        documentType: LegalDocumentType.termsOfService,
      ),
      LegalSection(
        id: 'tos_4',
        title: 'Additional Details',
        content: 'Privacy Concerns: Your pictures will be shared widely, exposing you to privacy risks. This is especially important if the pictures contain personal or sensitive information.\n\n'
            'Misuse: Without ownership, you have no recourse if your pictures are used in ways you don\'t agree with or find inappropriate. This includes commercial use, alterations, or being featured in contexts you didn\'t anticipate.\n\n'
            'User Responsibility: As a user, it\'s your responsibility to understand the implications of forfeiting ownership and to stay informed about any changes to the app\'s policies.',
        order: 4,
        documentType: LegalDocumentType.termsOfService,
      ),
    ];
  }

  // Search functionality
  void searchInContent(String query) {
    if (query.isEmpty) {
      loadLegalContent();
      return;
    }

    final filteredSections = sections.where((section) =>
        section.title.toLowerCase().contains(query.toLowerCase()) ||
        section.content.toLowerCase().contains(query.toLowerCase())
    ).toList();

    sections.assignAll(filteredSections);
  }

  // Scroll to specific section
  void scrollToSection(int index) {
    if (scrollController.hasClients && index < sections.length) {
      // Calculate approximate position (each section is roughly 200 pixels)
      final position = index * 200.0;
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Export content as text
  String exportAsText() {
    final buffer = StringBuffer();
    buffer.writeln(documentType.value.displayName);
    buffer.writeln('=' * documentType.value.displayName.length);
    buffer.writeln();
    
    for (final section in sections) {
      buffer.writeln(section.title);
      buffer.writeln('-' * section.title.length);
      buffer.writeln(section.content);
      buffer.writeln();
    }
    
    buffer.writeln(lastUpdated.value);
    return buffer.toString();
  }

  // Share content
  void shareContent() {
    final content = exportAsText();
    // Implement share functionality
    // Share.share(content, subject: documentType.value.displayName);
    Get.snackbar('Share', '${documentType.value.displayName} shared successfully');
  }

  // Print content
  void printContent() {
    // Implement print functionality
    Get.snackbar('Print', '${documentType.value.displayName} sent to printer');
  }
}