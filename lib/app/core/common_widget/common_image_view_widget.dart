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

  // Add fallback URL parameter
  final String? fallbackUrl;

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
  });

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  /// Convert Google Drive sharing link to direct image URL
  String _convertGoogleDriveUrl(String url) {
    try {
      // Pattern 1: https://drive.google.com/file/d/FILE_ID/view?usp=sharing
      if (url.contains('drive.google.com/file/d/')) {
        final regex = RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)');
        final match = regex.firstMatch(url);
        if (match != null && match.groupCount > 0) {
          final fileId = match.group(1);
          return 'https://drive.google.com/uc?export=view&id=$fileId';
        }
      }

      // Pattern 2: https://drive.google.com/open?id=FILE_ID
      if (url.contains('drive.google.com/open?id=')) {
        final regex = RegExp(r'id=([a-zA-Z0-9_-]+)');
        final match = regex.firstMatch(url);
        if (match != null && match.groupCount > 0) {
          final fileId = match.group(1);
          return 'https://drive.google.com/uc?export=view&id=$fileId';
        }
      }

      // Pattern 3: https://drive.google.com/uc?id=FILE_ID
      // Already in correct format, just ensure export=view parameter
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

      // Pattern 4: https://docs.google.com/uc?id=FILE_ID
      if (url.contains('docs.google.com/uc?')) {
        final regex = RegExp(r'id=([a-zA-Z0-9_-]+)');
        final match = regex.firstMatch(url);
        if (match != null && match.groupCount > 0) {
          final fileId = match.group(1);
          return 'https://drive.google.com/uc?export=view&id=$fileId';
        }
      }

      // If no pattern matches, return original URL
      return url;
    } catch (e) {
      print('Error converting Google Drive URL: $e');
      return url;
    }
  }

  Widget _buildImageView() {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return Container(
        height: height,
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: SvgPicture.asset(
            svgPath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: Image.file(file!, height: height, width: width, fit: fit),
      );
    } else if (url != null && url!.isNotEmpty) {
      // Convert Google Drive URLs to direct image URLs
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
          child: CachedNetworkImage(
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
              // Try fallback URL if provided and different from main URL
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

              // If no fallback or fallback is same as main URL, show placeholder
              return Image.asset(
                placeHolder,
                height: height,
                width: width,
                fit: fit,
              );
            },
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
          child: Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    }
    return SizedBox();
  }
}
