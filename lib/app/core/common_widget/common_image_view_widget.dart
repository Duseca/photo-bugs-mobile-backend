import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';

class CommonImageView extends StatelessWidget {
  // ignore_for_file: must_be_immutable
  String? url;
  String? imagePath;
  String? svgPath;
  File? file;
  final double? height, width, radius, borderWidth;

  final BoxFit fit;
  final String placeHolder;
  final Color? borderColor;

  final String? fallbackUrl;
  final bool showWatermark;
  final String watermarkPath;
  final double watermarkOpacity;

  CommonImageView({
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.radius = 0.0,
    this.fit = BoxFit.cover,
    this.placeHolder = 'assets/images/no_image_found.png',
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    this.fallbackUrl,
    this.showWatermark = false,
    this.watermarkPath = 'assets/images/watermark_transparent.png',
    this.watermarkOpacity = 0.38,
  });

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  String _convertGoogleDriveUrl(String url) {
    try {
      if (url.contains('drive.google.com/file/d/')) {
        final regex = RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)');
        final match = regex.firstMatch(url);
        if (match != null && match.groupCount > 0) {
          final fileId = match.group(1);
          return 'https://drive.google.com/uc?export=view&id=$fileId';
        }
      }

      if (url.contains('drive.google.com/open?id=')) {
        final regex = RegExp(r'id=([a-zA-Z0-9_-]+)');
        final match = regex.firstMatch(url);
        if (match != null && match.groupCount > 0) {
          final fileId = match.group(1);
          return 'https://drive.google.com/uc?export=view&id=$fileId';
        }
      }

      if (url.contains('drive.google.com/uc?')) {
        if (!url.contains('export=view')) {
          if (url.contains('id=')) {
            final regex = RegExp(r'id=([a-zA-Z0-9_-]+)');
            final match = regex.firstMatch(url);
            if (match != null && match.groupCount > 0) {
              final fileId = match.group(1);
              return 'https://drive.google.com/uc?export=view&id=$fileId';
            }
          }
        }
      }

      if (url.contains('docs.google.com/uc?')) {
        final regex = RegExp(r'id=([a-zA-Z0-9_-]+)');
        final match = regex.firstMatch(url);
        if (match != null && match.groupCount > 0) {
          final fileId = match.group(1);
          return 'https://drive.google.com/uc?export=view&id=$fileId';
        }
      }

      return url;
    } catch (e) {
      print('Error converting Google Drive URL: $e');
      return url;
    }
  }

  Widget _buildRepeatingWatermark(double imageWidth, double imageHeight) {
    if (!showWatermark) return SizedBox.shrink();

    // Calculate watermark size
    double watermarkSize;
    if (imageWidth < 300 || imageHeight < 300) {
      watermarkSize = 70;
    } else if (imageWidth < 500 || imageHeight < 500) {
      watermarkSize = 90;
    } else {
      watermarkSize = 110;
    }

    final spacing = watermarkSize * 0.5;

    // Calculate number of watermarks needed
    final numColumns =
        ((imageWidth + spacing) / (watermarkSize + spacing)).ceil() + 1;
    final numRows =
        ((imageHeight + spacing) / (watermarkSize + spacing)).ceil() + 1;

    return Transform.rotate(
      angle: -0.4, // Diagonal angle
      child: Opacity(
        opacity: watermarkOpacity,
        child: OverflowBox(
          maxWidth: imageWidth * 2,
          maxHeight: imageHeight * 2,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(
              numRows * numColumns,
              (index) => SizedBox(
                width: watermarkSize,
                height: watermarkSize,
                child: Image.asset(
                  watermarkPath,
                  width: watermarkSize,
                  height: watermarkSize,
                  fit: BoxFit.contain,
                  color: null, // No color filter
                  colorBlendMode: BlendMode.dstATop,
                  errorBuilder: (context, error, stackTrace) {
                    print('Watermark not found: $watermarkPath');
                    return SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageView() {
    final imageWidth = width ?? 300.0;
    final imageHeight = height ?? 300.0;

    if (svgPath != null && svgPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: SizedBox(
          height: height,
          width: width,
          child: Stack(
            children: [
              SvgPicture.asset(
                svgPath!,
                height: height,
                width: width,
                fit: fit,
              ),
              if (showWatermark)
                Positioned.fill(
                  child: _buildRepeatingWatermark(imageWidth, imageHeight),
                ),
            ],
          ),
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: SizedBox(
          height: height,
          width: width,
          child: Stack(
            children: [
              Image.file(file!, height: height, width: width, fit: fit),
              if (showWatermark)
                Positioned.fill(
                  child: _buildRepeatingWatermark(imageWidth, imageHeight),
                ),
            ],
          ),
        ),
      );
    } else if (url != null && url!.isNotEmpty) {
      final convertedUrl = _convertGoogleDriveUrl(url!);
      final convertedFallbackUrl =
          fallbackUrl != null ? _convertGoogleDriveUrl(fallbackUrl!) : null;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius!),
          border: Border.all(color: borderColor!, width: borderWidth!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: SizedBox(
            height: height,
            width: width,
            child: Stack(
              children: [
                CachedNetworkImage(
                  height: height,
                  width: width,
                  fit: fit,
                  imageUrl: convertedUrl,
                  placeholder:
                      (context, url) => Container(
                        height: 23,
                        width: 23,
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: kSecondaryColor,
                              backgroundColor: Colors.grey.shade100,
                            ),
                          ),
                        ),
                      ),
                  errorWidget: (context, url, error) {
                    if (convertedFallbackUrl != null &&
                        convertedFallbackUrl.isNotEmpty &&
                        convertedFallbackUrl != convertedUrl) {
                      return CachedNetworkImage(
                        height: height,
                        width: width,
                        fit: fit,
                        imageUrl: convertedFallbackUrl,
                        placeholder:
                            (context, url) => Container(
                              height: 23,
                              width: 23,
                              child: Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: kSecondaryColor,
                                    backgroundColor: Colors.grey.shade100,
                                  ),
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Image.asset(
                              placeHolder,
                              height: height,
                              width: width,
                              fit: fit,
                            ),
                      );
                    }

                    return Image.asset(
                      placeHolder,
                      height: height,
                      width: width,
                      fit: fit,
                    );
                  },
                ),
                if (showWatermark)
                  Positioned.fill(
                    child: _buildRepeatingWatermark(imageWidth, imageHeight),
                  ),
              ],
            ),
          ),
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius!),
          border: Border.all(color: borderColor!, width: borderWidth!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: SizedBox(
            height: height,
            width: width,
            child: Stack(
              children: [
                Image.asset(imagePath!, height: height, width: width, fit: fit),
                if (showWatermark)
                  Positioned.fill(
                    child: _buildRepeatingWatermark(imageWidth, imageHeight),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox();
  }
}
