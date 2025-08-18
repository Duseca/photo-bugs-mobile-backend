import 'package:flutter/material.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/app/core/common_widget/switch_tile_widget.dart';

class NotificationSetting extends StatelessWidget {
  const NotificationSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Notifications'),
      body: Padding(
        padding: AppSizes.DEFAULT,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchTile(
              title: 'General Notifications',
              value: true,
              onToggle: (v) {},
            ),
            SwitchTile(title: 'Sound', value: true, onToggle: (v) {}),
            SwitchTile(title: 'Vibrate', value: false, onToggle: (v) {}),
            SwitchTile(title: 'App Updates', value: false, onToggle: (v) {}),
          ],
        ),
      ),
    );
  }
}
