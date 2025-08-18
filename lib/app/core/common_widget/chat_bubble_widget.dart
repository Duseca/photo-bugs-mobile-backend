// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import 'package:photo_bug/app/shared/constants/app_fonts.dart';
// import 'package:photo_bug/app/shared/constants/app_images.dart';
// import 'package:photo_bug/app/shared/constants/app_sizes.dart';
// import 'package:photo_bug/app/shared/widget/common_image_view_widget.dart';
// import 'package:photo_bug/app/shared/widget/my_button_widget.dart';
// import 'package:photo_bug/app/shared/widget/my_text_widget.dart';

// // ignore: must_be_immutable
// class ChatBubble extends StatelessWidget {
//   ChatBubble({
//     Key? key,
//     required this.isMe,
//     required this.otherUserImg,
//     required this.msgTime,
//     required this.msg,
//     this.isphoto_bugsRequest = false,
//     this.photo_bugsTime,
//     this.photo_bugsTitle,
//     this.photo_bugsDate,
//     this.isphoto_bugsAccepted = false,
//     this.isphoto_bugsRejected = false,
//     this.photo_bugsLocation,
//     this.photo_bugsIcon,
//     this.isCoach = false,
//   }) : super(key: key);

//   final String msg, otherUserImg, msgTime;
//   final bool isMe;
//   bool? isphoto_bugsRequest;
//   final String? photo_bugsTime, photo_bugsTitle, photo_bugsDate, photo_bugsLocation, photo_bugsIcon;
//   final bool? isphoto_bugsAccepted, isphoto_bugsRejected, isCoach;

//   @override
//   Widget build(BuildContext context) {
//     return isphoto_bugsRequest!
//         ? Column(
//             children: [
//               Container(
//                 height: 27,
//                 width: 110,
//                 decoration: BoxDecoration(
//                   color: kSecondaryColor,
//                   borderRadius: BorderRadius.circular(50),
//                 ),
//                 child: Center(
//                   child: MyText(
//                     text: 'photo_bugs Invitation',
//                     size: 12,
//                     color: kPrimaryColor,
//                     weight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 12,
//               ),
//               Container(
//                 width: Get.width,
//                 padding: AppSizes.DEFAULT,
//                 decoration: BoxDecoration(
//                   color: kSecondaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: kSecondaryColor.withOpacity(0.4),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Row(
//                       children: [
//                         MyText(
//                           text: photo_bugsTime!,
//                           size: 12,
//                           weight: FontWeight.w500,
//                           paddingRight: 22,
//                         ),
//                         Image.asset(
//                           Assets.imagesLocation,
//                           height: 16,
//                           color: kSecondaryColor,
//                         ),
//                         Expanded(
//                           child: MyText(
//                             text: photo_bugsLocation!,
//                             size: 12,
//                             weight: FontWeight.w500,
//                             paddingLeft: 5,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 24,
//                     ),
//                     Row(
//                       children: [
//                         Image.asset(
//                           photo_bugsIcon!,
//                           height: 18,
//                           color: kSecondaryColor,
//                         ),
//                         SizedBox(
//                           width: 11,
//                         ),
//                         Expanded(
//                           child: RichText(
//                             text: TextSpan(
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: kTertiaryColor,
//                                 fontWeight: FontWeight.w500,
//                                 fontFamily: AppFonts.NUNITO,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text: photo_bugsTitle!,
//                                   style: TextStyle(color: kSecondaryColor),
//                                 ),
//                                 TextSpan(
//                                   text: ' on ${photo_bugsDate!}',
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 24,
//                     ),
//                     MyButton(
//                       height: 38,
//                       buttonText: 'Accept invite',
//                       weight: FontWeight.w400,
//                       onTap: () {},
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     MyBorderButton(
//                       height: 38,
//                       buttonText: 'Decline',
//                       textColor: kTertiaryColor,
//                       borderColor: kTertiaryColor.withOpacity(0.4),
//                       weight: FontWeight.w400,
//                       onTap: () {},
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           )
//         : isMe
//             ? _rightMessageBubble()
//             : _leftMessageBubble();
//   }

//   Widget _rightMessageBubble() {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: 12,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: 10,
//               vertical: 8,
//             ),
//             decoration: BoxDecoration(
//               color: kSecondaryColor,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(0),
//                 bottomLeft: Radius.circular(10),
//                 bottomRight: Radius.circular(10),
//               ),
//             ),
//             child: MyText(
//               text: msg,
//               size: 14,
//               color: kPrimaryColor,
//               paddingBottom: 2,
//             ),
//           ),
//           SizedBox(
//             height: 4,
//           ),
//           Wrap(
//             crossAxisAlignment: WrapCrossAlignment.center,
//             spacing: 4,
//             children: [
//               Text(
//                 msgTime,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: kTertiaryColor.withOpacity(0.4),
//                 ),
//               ),
//               if (isMe)
//                 Image.asset(
//                   Assets.imagesDoubleTick,
//                   height: 7,
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _leftMessageBubble() {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: 12,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CommonImageView(
//             url: otherUserImg,
//             height: 42,
//             width: 42,
//             radius: 100,
//             borderColor: isCoach! ? kCoachColor : Colors.transparent,
//             borderThickness: 2,
//           ),
//           SizedBox(
//             width: 12,
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isCoach!
//                         ? kCoachColor
//                         : kTertiaryColor.withOpacity(0.05),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(0),
//                       topRight: Radius.circular(10),
//                       bottomLeft: Radius.circular(10),
//                       bottomRight: Radius.circular(10),
//                     ),
//                   ),
//                   child: MyText(
//                     text: msg,
//                     size: 14,
//                     color: isCoach! ? kPrimaryColor : kTertiaryColor,
//                   ),
//                 ),
//                 MyText(
//                   text: msgTime,
//                   size: 10,
//                   color: kTertiaryColor.withOpacity(0.4),
//                   paddingTop: 4,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
