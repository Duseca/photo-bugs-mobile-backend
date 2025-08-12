import 'package:flutter/material.dart';
import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_sizes.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';
import 'package:photo_bug/app/shared/widget/simple_app_bar_widget.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Privacy Policy'),
      body: ListView(
        padding: AppSizes.DEFAULT,
        children: [
          _buildSection(
            '1. Introduction',
            'Welcome to Photobugs! We value your privacy and are committed to protecting your personal information. This Privacy Policy outlines how we collect, use, and safeguard your data when you use our app.',
          ),
          _buildSection(
            '2. Information We Collect',
            '- Personal Information: When you sign up, we collect your name, email address, and other contact details.\n- Photos and Content: We collect the photos and other content you upload, share, and sell on Photobugs.\n- Usage Data: We collect information about how you use the app, including your interactions, preferences, and device information.',
          ),
          _buildSection(
            '3. How We Use Your Information',
            '- To Provide Services: We use your information to operate and improve Photobugs, including facilitating photo uploads, sharing, and sales.\n- To Communicate: We may use your contact information to send you updates, notifications, and promotional materials.\n- To Enhance Security: We use your data to detect and prevent fraud, abuse, and other harmful activities.',
          ),
          _buildSection(
            '4. Sharing Your Information',
            '- With Third Parties: We may share your information with trusted third-party service providers to help us operate and improve Photobugs.\n- Legal Requirements: We may disclose your information if required by law or to protect our rights and users’ safety.',
          ),
          _buildSection(
            '5. Your Rights',
            '- Access and Control: You can access, update, or delete your personal information through your account settings.\n- Opt-Out: You can opt-out of receiving promotional communications by following the instructions in those messages.',
          ),
          _buildSection(
            '6. Data Security',
            'We implement industry-standard security measures to protect your data, including encryption, firewalls, and secure server environments. However, no method of transmission over the internet or electronic storage is 100% secure.',
          ),
          _buildSection(
            '7. Consent',
            'By using Photobugs, you consent to the collection, use, and sharing of your information as described in this Privacy Policy. You may withdraw your consent at any time by deleting your account.',
          ),
          _buildSection(
            '8. Data Retention',
            'We retain your personal information for as long as necessary to provide our services. If you delete your account, we will delete your personal information, except where legally required to retain it.',
          ),
          _buildSection(
            '9. Model Releases and Consent',
            '- Model Releases: If you upload photos featuring identifiable individuals, you must obtain and retain a signed model release.\n- User Consent: By using Photobugs, you confirm that you have obtained necessary consents from individuals featured in your photos.',
          ),
          _buildSection(
            '10. Use at Your Own Risk',
            'By using Photobugs, you acknowledge and agree that you do so at your own risk. We are not liable for any issues, damages, or losses arising from your use of the app.',
          ),
          _buildSection(
            '11. Changes to This Policy',
            'We reserve the right to update this Privacy Policy at any time. We will notify you of any changes by posting the new policy on this page.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            text: title,
            size: 16,
            weight: FontWeight.w700,
            paddingBottom: 4,
          ),
          MyText(text: content, size: 13, color: kQuaternaryColor),
        ],
      ),
    );
  }
}
