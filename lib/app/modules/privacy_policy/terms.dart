import 'package:flutter/material.dart';
import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_sizes.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';
import 'package:photo_bug/app/shared/widget/simple_app_bar_widget.dart';

class Terms extends StatelessWidget {
  const Terms({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Terms of Services'),
      body: ListView(
        padding: AppSizes.DEFAULT,
        children: [
          TermsSection(
            title: '1. Consent and Ownership',
            content:
                'Agreement to List Pictures: By clicking “Continue,” you agree to have your pictures listed on the app. This means your pictures will be visible to other users and potentially to the public, depending on the app’s settings.\n\n'
                'Transfer of Ownership: You forfeit all ownership rights to the app, the purchaser of the picture, and the photographer. This means:\n\n'
                'Control: You no longer have control over how your pictures are used, distributed, or modified. The app, the purchaser, and the photographer can use your pictures in any way they see fit without needing your permission.\n\n'
                'Financial Rights: You won’t receive any financial compensation for the use of your pictures. Any profits made from your pictures will go to the app, the purchaser, or the photographer.\n\n'
                'Legal Rights: You forfeit the ability to enforce your rights if your pictures are used in a way that violates your privacy or other legal protections. The new owners of the pictures will have the legal rights to them.\n\n'
                'Right to Post: Despite forfeiting ownership, you retain the right to have your pictures posted on the app. This means you can still upload and share your pictures on the platform, but you won’t have ownership rights over them.',
          ),
          TermsSection(
            title: '2. Changes to Rules and Regulations',
            content:
                'Updates and Modifications: The app’s rules and regulations can be updated or changed at any time. This means that the terms you agree to today might be different in the future.\n\n'
                'Notification of Changes: The app may or may not notify you of these changes. It’s your responsibility to stay informed about any updates to the rules and regulations.\n\n'
                'Impact of Changes: Changes to the rules and regulations will affect how your pictures are used, your rights, and your obligations. It’s important to regularly review the privacy policy to understand any new terms.',
          ),
          TermsSection(
            title: '3. Legal Actions and Compensation',
            content:
                'No Legal Recourse: By clicking “Continue,” you agree that you cannot sue or take any legal action against the app, the purchaser of the picture, or the photographer for any reason related to the use of your pictures.\n\n'
                'No Compensation: You agree that you will not ask for or receive any financial compensation or other forms of payment for the use of your pictures. This includes any profits made from your pictures by the app, the purchaser, or the photographer.\n\n'
                'Binding Agreement: This agreement is binding and enforceable, meaning you are legally obligated to adhere to these terms and cannot challenge them in court.',
          ),
          TermsSection(
            title: 'Additional Details',
            content:
                'Privacy Concerns: Your pictures will be shared widely, exposing you to privacy risks. This is especially important if the pictures contain personal or sensitive information.\n\n'
                'Misuse: Without ownership, you have no recourse if your pictures are used in ways you don’t agree with or find inappropriate. This includes commercial use, alterations, or being featured in contexts you didn’t anticipate.\n\n'
                'User Responsibility: As a user, it’s your responsibility to understand the implications of forfeiting ownership and to stay informed about any changes to the app’s policies.',
          ),
        ],
      ),
    );
  }
}

class TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const TermsSection({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
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
