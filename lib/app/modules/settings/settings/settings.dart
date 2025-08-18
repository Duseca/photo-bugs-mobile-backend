import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/modules/authentication/screens/login_screen.dart';
import 'package:photo_bug/app/modules/privacy_policy/views/privacy_policy.dart';
import 'package:photo_bug/app/modules/settings/notifications/notification_setting.dart';
import 'package:photo_bug/app/modules/settings/payments/payment_method.dart';
import 'package:photo_bug/app/modules/settings/payments/transaction_history.dart';
import 'package:photo_bug/app/modules/settings/portfolio/user_id.dart';
import 'package:photo_bug/app/modules/settings/profile/personal_information.dart';
import 'package:photo_bug/app/modules/settings/security_and_help/help_center.dart';
import 'package:photo_bug/app/modules/settings/security_and_help/security.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_bottom_sheet_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Settings'),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        children: [
          Center(
            child: Stack(
              children: [
                CommonImageView(
                  url: dummyImg,
                  height: 84,
                  width: 84,
                  radius: 100,
                  borderColor: kInputBorderColor,
                  borderWidth: 2,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset(Assets.imagesEditBg, height: 24),
                ),
              ],
            ),
          ),
          MyText(
            text: 'Hassan',
            size: 16,
            weight: FontWeight.w600,
            textAlign: TextAlign.center,
            paddingTop: 16,
            paddingBottom: 24,
          ),
          MyText(
            text: 'Profile',
            size: 14,
            color: kQuaternaryColor,
            paddingLeft: 10,
            paddingBottom: 12,
          ),
          _ProfileTile(
            icon: Assets.imagesUser,
            title: 'Personal Information',
            onTap: () {
              Get.to(() => PersonalInformation());
            },
          ),
          _ProfileTile(
            icon: Assets.imagesSecurity,
            title: 'Security',
            onTap: () {
              Get.to(() => Security());
            },
          ),
          MyText(
            text: 'Payment & Notifications',
            size: 14,
            color: kQuaternaryColor,
            paddingLeft: 10,
            paddingTop: 16,
            paddingBottom: 12,
          ),
          _ProfileTile(
            icon: Assets.imagesPaymentMethod,
            title: 'Payment Method',
            onTap: () {
              Get.to(() => PaymentMethod());
            },
          ),
          _ProfileTile(
            icon: Assets.imagesUser,
            title: 'User ID',
            onTap: () {
              Get.to(() => UserId());
            },
          ),
          _ProfileTile(
            icon: Assets.imagesHistory,
            title: 'Transaction History',
            onTap: () {
              Get.to(() => TransactionHistory());
            },
          ),
          _ProfileTile(
            icon: Assets.imagesBell,
            title: 'Notification',
            onTap: () {
              Get.to(() => NotificationSetting());
            },
          ),
          MyText(
            text: 'Other',
            size: 14,
            color: kQuaternaryColor,
            paddingLeft: 10,
            paddingTop: 16,
            paddingBottom: 12,
          ),
          // _ProfileTile(
          //   icon: Assets.imagesCrown,
          //   title: 'Subscriptions',
          //   onTap: () {
          //     Get.to(() => Subscription());
          //   },
          // ),
          _ProfileTile(
            icon: Assets.imagesPrivacyPolicy,
            title: 'Privacy Policy',
            onTap: () {
              Get.to(() => PrivacyPolicy());
            },
          ),
          _ProfileTile(
            icon: Assets.imagesInfo,
            title: 'Help Center',
            onTap: () {
              Get.to(() => HelpCenter());
            },
          ),
          SizedBox(height: 16),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: MyText(
          //           text: 'Mature content',
          //           size: 12,
          //           color: kQuaternaryColor,
          //           maxLines: 1,
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //       ),
          //       FlutterSwitch(
          //         height: 20,
          //         width: 36,
          //         toggleSize: 16,
          //         padding: 2,
          //         toggleColor: kWhiteColor,
          //         activeColor: kSecondaryColor,
          //         inactiveColor: kGreyColor2,
          //         value: false,
          //         onToggle: (v) {},
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: 16,
          // ),
          Container(
            height: 42,
            child: MyRippleEffect(
              onTap: () {
                Get.bottomSheet(logoutBottomSheet());
              },
              radius: 8,
              splashColor: kSecondaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Image.asset(Assets.imagesLogout, height: 20),
                    Expanded(
                      child: MyText(
                        text: 'Logout',
                        size: 14,
                        color: kRedColor,
                        weight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        paddingLeft: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget logoutBottomSheet() {
    return CustomBottomSheet(
      height: Get.height * 0.25,
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyText(
              text: 'Logout',
              size: 18,
              weight: FontWeight.w700,
              textAlign: TextAlign.center,
              paddingBottom: 10,
            ),
            MyText(
              text: 'Are you sure you want to logout?',
              textAlign: TextAlign.center,
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    borderWidth: 1,
                    bgColor: Colors.transparent,
                    textColor: kTertiaryColor,
                    borderColor: kInputBorderColor,
                    splashColor: kSecondaryColor.withOpacity(0.1),
                    buttonText: 'cancel',
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: MyButton(
                    textColor: kPrimaryColor,
                    bgColor: kRedColor,
                    buttonText: 'Logout',
                    onTap: () {
                      Get.offAll(() => Login());
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String icon, title;
  final VoidCallback onTap;
  const _ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      child: MyRippleEffect(
        onTap: onTap,
        radius: 8,
        splashColor: kSecondaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Image.asset(icon, height: 20),
              Expanded(
                child: MyText(
                  text: title,
                  size: 14,
                  weight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  paddingLeft: 16,
                ),
              ),
              Image.asset(Assets.imagesArrowRightIos, height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
