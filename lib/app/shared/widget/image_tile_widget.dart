import 'package:flutter/material.dart';
import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';
import 'package:photo_bug/app/shared/widget/common_image_view_widget.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';

class ImageTile extends StatelessWidget {
  final String image, name, size, price;
  final bool isDownloaded;
  final VoidCallback onTap;
  const ImageTile({
    super.key,
    required this.image,
    required this.name,
    required this.size,
    required this.price,
    required this.isDownloaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            CommonImageView(url: image, height: 48, width: 48, radius: 8),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyText(text: name, size: 12, paddingBottom: 4),
                  MyText(
                    text: 'Size: $size',
                    size: 12,
                    color: kQuaternaryColor,
                  ),
                ],
              ),
            ),
            isDownloaded
                ? Image.asset(Assets.imagesDownload, height: 20)
                : MyText(
                  text: price,
                  weight: FontWeight.w500,
                  paddingBottom: 4,
                ),
          ],
        ),
      ),
    );
  }
}
