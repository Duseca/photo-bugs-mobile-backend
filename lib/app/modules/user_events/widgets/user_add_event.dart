import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/data/models/location_model.dart';
import 'package:photo_bug/app/modules/user_events/controllers/user_events_controller.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/share_event.dart';
import 'package:photo_bug/app/core/common_widget/custom_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class UserAddEvent extends GetView<UserEventsController> {
  const UserAddEvent({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final dateController = TextEditingController();
    final timeStartController = TextEditingController();
    final timeEndController = TextEditingController();

    final selectedType = Rx<String?>(null);
    final selectedRole = Rx<String?>(null);
    final selectedDate = Rx<DateTime?>(null);
    final selectedTimeStart = Rx<TimeOfDay?>(null);
    final selectedTimeEnd = Rx<TimeOfDay?>(null);
    final selectedImage = Rx<String?>(null);
    final selectedLocation = Rx<Location?>(null);

    final eventTypes = [
      'Wedding',
      'Birthday',
      'Corporate',
      'Sports',
      'Concert',
      'Other',
    ];
    final eventRoles = ['Photographer', 'Videographer', 'Guest', 'Organizer'];

    return Scaffold(
      appBar: simpleAppBar(title: 'Add New Event'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                // Image Upload
                Obx(
                  () => GestureDetector(
                    onTap: () {
                      // TODO: Implement image picker
                      Get.snackbar(
                        'Info',
                        'Image picker will be implemented',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: kInputBorderColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            image:
                                selectedImage.value != null
                                    ? DecorationImage(
                                      image: NetworkImage(selectedImage.value!),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              selectedImage.value == null
                                  ? Image.asset(
                                    Assets.imagesUploadImage,
                                    height: 80,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MyText(
                                text: 'Browse File',
                                size: 12,
                                color: kSecondaryColor,
                                weight: FontWeight.w500,
                                paddingBottom: 8,
                              ),
                              MyText(
                                text: 'Select photos to upload',
                                size: 12,
                                color: kQuaternaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name Field
                MyTextField(
                  label: 'Name',
                  controller: nameController,
                  hint: 'Enter event name',
                ),

                // Location Field
                MyTextField(
                  label: 'Location',
                  controller: locationController,
                  hint: 'Enter location',
                  readOnly: true,
                  onTap: () async {
                    // TODO: Implement location picker
                    Get.snackbar(
                      'Info',
                      'Location picker will be implemented',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  suffix: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset(Assets.imagesLocation, height: 18)],
                  ),
                ),

                // Date Field
                MyTextField(
                  label: 'Date',
                  controller: dateController,
                  hint: 'Select date',
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      selectedDate.value = date;
                      dateController.text =
                          '${date.day}/${date.month}/${date.year}';
                    }
                  },
                  suffix: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset(Assets.imagesCalendar, height: 18)],
                  ),
                ),

                // Time Start Field
                MyTextField(
                  label: 'Time Start',
                  controller: timeStartController,
                  hint: 'Select start time',
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      selectedTimeStart.value = time;
                      timeStartController.text = time.format(context);
                    }
                  },
                  suffix: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset(Assets.imagesClock, height: 18)],
                  ),
                ),

                // Time End Field
                MyTextField(
                  label: 'Time End',
                  controller: timeEndController,
                  hint: 'Select end time',
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTimeStart.value ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      selectedTimeEnd.value = time;
                      timeEndController.text = time.format(context);
                    }
                  },
                  suffix: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset(Assets.imagesClock, height: 18)],
                  ),
                ),

                // Event Type Dropdown
                Obx(
                  () => CustomDropDown(
                    hint: 'Type of Event',
                    selectedValue: selectedType.value,
                    items: eventTypes,
                    onChanged: (value) => selectedType.value = value,
                  ),
                ),

                // Role Dropdown
                Obx(
                  () => CustomDropDown(
                    hint: 'Role',
                    selectedValue: selectedRole.value,
                    items: eventRoles,
                    onChanged: (value) => selectedRole.value = value,
                  ),
                ),
              ],
            ),
          ),

          // Add Event Button
          Padding(
            padding: AppSizes.DEFAULT,
            child: Obx(
              () => MyButton(
                buttonText: 'Add Event',
                isLoading: controller.isLoading.value,
                onTap:
                    () => _handleAddEvent(
                      context,
                      nameController,
                      selectedDate,
                      selectedTimeStart,
                      selectedTimeEnd,
                      selectedType,
                      selectedRole,
                      selectedImage,
                      selectedLocation,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddEvent(
    BuildContext context,
    TextEditingController nameController,
    Rx<DateTime?> selectedDate,
    Rx<TimeOfDay?> selectedTimeStart,
    Rx<TimeOfDay?> selectedTimeEnd,
    Rx<String?> selectedType,
    Rx<String?> selectedRole,
    Rx<String?> selectedImage,
    Rx<Location?> selectedLocation,
  ) async {
    // Validation
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter event name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedDate.value == null) {
      Get.snackbar(
        'Error',
        'Please select event date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Convert TimeOfDay to HHMM format
    int? timeStart;
    int? timeEnd;

    if (selectedTimeStart.value != null) {
      final start = selectedTimeStart.value!;
      timeStart = start.hour * 100 + start.minute;
    }

    if (selectedTimeEnd.value != null) {
      final end = selectedTimeEnd.value!;
      timeEnd = end.hour * 100 + end.minute;
    }

    // Get current user ID for photographer field
    final currentUserId = controller.getCurrentUserId();

    if (currentUserId == null) {
      Get.snackbar(
        'Error',
        'User not authenticated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Create event request
    final request = CreateEventRequest(
      name: nameController.text.trim(),
      photographerId: currentUserId, // Required field
      date: selectedDate.value,
      timeStart: timeStart,
      timeEnd: timeEnd,
      type: selectedType.value,
      role: selectedRole.value,
      image: "https://randomuser.me/api/portraits/women/44.jpg",
      location: selectedLocation.value,
      matureContent: false,
    );

    // Call controller method
    final response = await controller.createEvent(request);

    if (response.success) {
      Get.back(); // Close add event screen
      _showSuccessDialog(context, response.data);
    } else {
      Get.snackbar(
        'Error',
        response.error ?? 'Failed to create event',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showSuccessDialog(BuildContext context, Event? event) {
    Get.dialog(
      CustomDialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset(Assets.imagesCongrats, height: 120)),
              MyText(
                text: 'Event Added Successfully',
                size: 22,
                weight: FontWeight.w700,
                textAlign: TextAlign.center,
                paddingTop: 16,
                paddingBottom: 8,
              ),
              MyText(
                text:
                    'Your event has been created. You can now share it with others or continue.',
                size: 13,
                color: kQuaternaryColor,
                textAlign: TextAlign.center,
                lineHeight: 1.6,
                paddingBottom: 16,
              ),
              MyButton(
                bgColor: Colors.transparent,
                splashColor: kSecondaryColor.withOpacity(0.1),
                textColor: kSecondaryColor,
                borderWidth: 1,
                buttonText: 'Share',
                onTap: () {
                  Get.back();
                  Get.to(() => ShareEvent());
                },
              ),
              const SizedBox(height: 12),
              MyButton(
                buttonText: 'Continue',
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
