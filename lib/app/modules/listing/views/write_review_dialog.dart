import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/data/models/review_model.dart';
import 'package:photo_bug/app/services/review_service/review_service.dart';

class WriteReviewDialog extends StatefulWidget {
  final String creatorId;
  final String creatorName;
  final String? creatorImage;

  const WriteReviewDialog({
    Key? key,
    required this.creatorId,
    required this.creatorName,
    this.creatorImage,
  }) : super(key: key);

  @override
  State<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog>
    with SingleTickerProviderStateMixin {
  final ReviewService _reviewService = ReviewService.instance;
  final TextEditingController _messageController = TextEditingController();
  final RxInt selectedRating = 0.obs;
  final RxBool isSubmitting = false.obs;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (selectedRating.value == 0) {
      Get.snackbar(
        'Rating Required',
        'Please select a rating before submitting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.star_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      Get.snackbar(
        'Message Required',
        'Please write a review message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final request = CreateReviewRequest(
        reviewForId: widget.creatorId,
        ratings: selectedRating.value,
        comment: _messageController.text.trim(),
      );

      final response = await _reviewService.createReview(request);

      if (response.success) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Review submitted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          margin: const EdgeInsets.all(16),
        );
      } else {
        print('Error submitting review: ${response.error}');
      }
    } catch (e) {
      print('Error submitting review: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 500,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (fixed)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _buildHeader(),
          ),
          const SizedBox(height: 16),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCreatorInfo(),
                  const SizedBox(height: 20),
                  _buildRatingSection(),
                  const SizedBox(height: 20),
                  _buildMessageSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Action buttons (fixed at bottom)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kSecondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.rate_review,
            color: kSecondaryColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: 'Write a Review',
                size: 20,
                weight: FontWeight.w700,
                color: kTertiaryColor,
              ),
              const SizedBox(height: 4),
              MyText(
                text: 'Share your experience',
                size: 13,
                color: kQuaternaryColor,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
          color: kQuaternaryColor,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildCreatorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSecondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kSecondaryColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: kSecondaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child:
                widget.creatorImage != null && widget.creatorImage!.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        widget.creatorImage!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.person,
                              color: kSecondaryColor,
                              size: 28,
                            ),
                      ),
                    )
                    : const Icon(
                      Icons.person,
                      color: kSecondaryColor,
                      size: 28,
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: 'Reviewing',
                  size: 11,
                  color: kQuaternaryColor,
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 2),
                MyText(
                  text: widget.creatorName,
                  size: 15,
                  weight: FontWeight.w600,
                  color: kTertiaryColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: 'Rating',
          size: 14,
          weight: FontWeight.w600,
          color: kTertiaryColor,
          paddingBottom: 12,
        ),
        Obx(() {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    selectedRating.value > 0
                        ? kSecondaryColor.withOpacity(0.3)
                        : kInputBorderColor,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Wrap stars for responsiveness
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(10, (index) {
                    final rating = index + 1;
                    final isSelected = selectedRating.value >= rating;

                    return GestureDetector(
                      onTap: () {
                        selectedRating.value = rating;
                        HapticFeedback.selectionClick();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          color:
                              isSelected ? kSecondaryColor : Colors.grey[300],
                          size: 28,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (selectedRating.value > 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kSecondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: MyText(
                        text:
                            '${selectedRating.value}/10 - ${_getRatingText(selectedRating.value)}',
                        size: 12,
                        weight: FontWeight.w600,
                        color: kSecondaryColor,
                      ),
                    );
                  }
                  return MyText(
                    text: 'Tap stars to rate (1-10)',
                    size: 11,
                    color: kQuaternaryColor,
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: 'Your Review',
          size: 14,
          weight: FontWeight.w600,
          color: kTertiaryColor,
          paddingBottom: 12,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kInputBorderColor, width: 1.5),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 4,
            maxLength: 300,
            style: const TextStyle(fontSize: 13, color: kTertiaryColor),
            decoration: InputDecoration(
              hintText: 'Share your thoughts about this creator...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              counterStyle: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSubmitting.value ? null : () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: kInputBorderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: MyText(
                text: 'Cancel',
                size: 14,
                weight: FontWeight.w600,
                color: kQuaternaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isSubmitting.value ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSubmitting.value
                        ? kSecondaryColor.withOpacity(0.6)
                        : kSecondaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  isSubmitting.value
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          MyText(
                            text: 'Submitting...',
                            size: 14,
                            weight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ],
                      )
                      : MyText(
                        text: 'Submit Review',
                        size: 14,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
            ),
          ),
        ],
      );
    });
  }

  String _getRatingText(int rating) {
    if (rating <= 2) return 'Poor';
    if (rating <= 4) return 'Below Average';
    if (rating <= 5) return 'Average';
    if (rating <= 6) return 'Good';
    if (rating <= 8) return 'Very Good';
    return 'Excellent';
  }
}

// Helper extension to show the dialog
extension WriteReviewDialogExtension on GetInterface {
  Future<bool?> showWriteReviewDialog({
    required String creatorId,
    required String creatorName,
    String? creatorImage,
  }) {
    return Get.dialog<bool>(
      WriteReviewDialog(
        creatorId: creatorId,
        creatorName: creatorName,
        creatorImage: creatorImage,
      ),
      barrierDismissible: false,
    );
  }
}
