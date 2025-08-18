import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart' show AppSizes;
import 'package:photo_bug/app/models/legal_model/legal_model.dart';
import 'package:photo_bug/app/modules/privacy_policy/controller/legal_controller.dart';


import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class Terms extends GetView<LegalController> {
  const Terms({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize with terms of service type
    Get.put(LegalController(), tag: 'terms_of_service');
    final controller = Get.find<LegalController>(tag: 'terms_of_service');
    controller.documentType.value = LegalDocumentType.termsOfService;
    controller.loadLegalContent();
    
    return Scaffold(
      appBar: _buildAppBar(controller),
      body: _buildBody(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(LegalController controller) {
    return simpleAppBar(
      title: 'Terms of Services',
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'share':
                controller.shareContent();
                break;
              case 'print':
                controller.printContent();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Text('Share'),
            ),
            const PopupMenuItem(
              value: 'print',
              child: Text('Print'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(LegalController controller) {
    return Column(
      children: [
        _buildProgressBar(controller),
        Expanded(child: _buildContent(controller)),
        _buildLastUpdated(controller),
      ],
    );
  }

  Widget _buildProgressBar(LegalController controller) {
    return Obx(() => LinearProgressIndicator(
      value: controller.scrollProgress.value,
      backgroundColor: Colors.grey[300],
      valueColor: const AlwaysStoppedAnimation<Color>(kSecondaryColor),
    ));
  }

  Widget _buildContent(LegalController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.sections.isEmpty) {
        return const Center(
          child: Text('Failed to load terms of service'),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: AppSizes.DEFAULT,
        itemCount: controller.sections.length,
        itemBuilder: (context, index) {
          final section = controller.sections[index];
          return TermsSection(
            title: section.title,
            content: section.content,
          );
        },
      );
    });
  }

  Widget _buildLastUpdated(LegalController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Obx(() => MyText(
        text: controller.lastUpdated.value,
        size: 12,
        color: Colors.grey[600]!,
        textAlign: TextAlign.center,
      )),
    );
  }
}

// widgets/terms_section.dart
class TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const TermsSection({
    super.key,
    required this.title,
    required this.content,
  });

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
          MyText(
            text: content,
            size: 13,
            color: kQuaternaryColor,
          ),
        ],
      ),
    );
  }
}