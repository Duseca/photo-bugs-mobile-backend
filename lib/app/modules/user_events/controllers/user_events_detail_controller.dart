// modules/user_events/controllers/user_event_details_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/data/models/folder_model.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_event_details.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_image_folder_details.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/services/event_service.dart/event_service.dart';
import 'package:photo_bug/app/services/folder_service/folder_service.dart';

class UserEventDetailsController extends GetxController {
  // Services
  late final EventService _eventService;
  late final FolderService _folderService;
  late final AuthService _authService;

  // Observable variables
  final Rx<Event?> event = Rx<Event?>(null);
  final RxList<Folder> folders = <Folder>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFoldersLoading = false.obs;
  final RxString eventId = ''.obs;
  final RxBool isMyEvent = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _loadArguments();
    _setupFolderListener();
  }

  void _initializeServices() {
    try {
      _eventService = EventService.instance;
      _folderService = FolderService.instance;
      _authService = AuthService.instance;
    } catch (e) {
      print('❌ Error initializing services: $e');
    }
  }

  void _loadArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      eventId.value = arguments['eventId'] ?? '';
      isMyEvent.value = arguments['isMyEvent'] ?? false;

      // If event object is passed, use it
      if (arguments['event'] != null) {
        if (arguments['event'] is Event) {
          event.value = arguments['event'] as Event;
        }
      }
    }

    // If no event details, load from API
    if (event.value == null && eventId.value.isNotEmpty) {
      loadEventDetails();
    } else if (event.value != null) {
      // Load folders for this event
      loadFoldersForEvent();
    }
  }

  /// Setup folder listener for real-time updates
  void _setupFolderListener() {
    _folderService.userFoldersStream.listen((allFolders) {
      if (eventId.value.isNotEmpty) {
        // Filter folders for this event
        folders.value =
            allFolders
                .where((folder) => folder.eventId == eventId.value)
                .toList();
      }
    });
  }

  /// Load event details from API
  Future<void> loadEventDetails() async {
    if (eventId.value.isEmpty) {
      _showError('Invalid event ID');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _eventService.getEventById(eventId.value);

      if (response.success && response.data != null) {
        event.value = response.data;

        // Determine if this is my event
        isMyEvent.value = _isCurrentUserCreator();

        // Load folders
        await loadFoldersForEvent();

        print('✅ Event details loaded: ${response.data!.name}');
      } else {
        _showError(response.error ?? 'Failed to load event details');
      }
    } catch (e) {
      print('❌ Error loading event details: $e');
      _showError('Failed to load event details');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load folders for this event
  Future<void> loadFoldersForEvent() async {
    if (eventId.value.isEmpty) return;

    try {
      isFoldersLoading.value = true;

      final response = await _folderService.getFoldersByEvent(eventId.value);

      if (response.success && response.data != null) {
        folders.value = response.data!;
        print('✅ Loaded ${response.data!.length} folders for event');
      } else {
        print('❌ Failed to load folders: ${response.error}');
      }
    } catch (e) {
      print('❌ Error loading folders: $e');
    } finally {
      isFoldersLoading.value = false;
    }
  }

  /// Create new folder for this event
  Future<void> createFolder(String folderName) async {
    if (folderName.trim().isEmpty) {
      _showError('Folder name cannot be empty');
      return;
    }

    if (eventId.value.isEmpty) {
      _showError('Invalid event');
      return;
    }

    try {
      isLoading.value = true;

      final request = CreateFolderRequest(
        name: folderName,
        eventId: eventId.value,
      );

      final response = await _folderService.createFolder(request);

      if (response.success && response.data != null) {
        _showSuccess('Folder created successfully');

        // Refresh folders
        await loadFoldersForEvent();

        print('✅ Folder created: ${response.data!.name}');
      } else {
        _showError(response.error ?? 'Failed to create folder');
      }
    } catch (e) {
      print('❌ Error creating folder: $e');
      _showError('Failed to create folder');
    } finally {
      isLoading.value = false;
    }
  }

  /// Show create folder dialog
  void showCreateFolderDialog() {
    if (!isMyEvent.value) {
      _showError('Only event creator can create folders');
      return;
    }

    _showCreateFolderDialogUI(Get.context!, eventId.value, createFolder);
  }

  /// Show create folder dialog UI
  void _showCreateFolderDialogUI(
    BuildContext context,
    String eventId,
    Function(String) onCreateFolder,
  ) {
    final folderNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.create_new_folder, color: kSecondaryColor, size: 24),
            const SizedBox(width: 8),
            const Text('Create New Folder'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: folderNameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'Enter folder name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a folder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'This folder will be created for this event',
                style: TextStyle(fontSize: 11, color: kQuaternaryColor),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              folderNameController.dispose();
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final folderName = folderNameController.text.trim();
                folderNameController.dispose();
                Get.back();
                onCreateFolder(folderName);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kSecondaryColor,
              foregroundColor: kTertiaryColor,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// Navigate to folder details
  void navigateToFolderDetails(Folder folder) {
    Get.to(
      () => const UserImageFolderDetails(),
      arguments: {
        'folderId': folder.id,
        'folder': folder,
        'eventId': eventId.value,
      },
    );
  }

  /// Accept event invitation
  Future<void> acceptEventInvitation() async {
    if (eventId.value.isEmpty) return;

    try {
      isLoading.value = true;

      final response = await _eventService.acceptEventInvitation(eventId.value);

      if (response.success) {
        _showSuccess('Event invitation accepted');

        // Refresh event details
        await loadEventDetails();

        // Navigate back
        Get.back();
      } else {
        _showError(response.error ?? 'Failed to accept invitation');
      }
    } catch (e) {
      print('❌ Error accepting invitation: $e');
      _showError('Failed to accept invitation');
    } finally {
      isLoading.value = false;
    }
  }

  /// Decline event invitation
  Future<void> declineEventInvitation() async {
    if (eventId.value.isEmpty) return;

    try {
      isLoading.value = true;

      final response = await _eventService.declineEventInvitation(
        eventId.value,
      );

      if (response.success) {
        _showSuccess('Event invitation declined');

        // Navigate back
        Get.back();
      } else {
        _showError(response.error ?? 'Failed to decline invitation');
      }
    } catch (e) {
      print('❌ Error declining invitation: $e');
      _showError('Failed to decline invitation');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete event
  Future<void> deleteEvent() async {
    if (eventId.value.isEmpty) return;

    if (!isMyEvent.value) {
      _showError('Only event creator can delete this event');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _eventService.deleteEvent(eventId.value);

      if (response.success) {
        _showSuccess('Event deleted successfully');

        // Navigate back
        Get.back();
      } else {
        _showError(response.error ?? 'Failed to delete event');
      }
    } catch (e) {
      print('❌ Error deleting event: $e');
      _showError('Failed to delete event');
    } finally {
      isLoading.value = false;
    }
  }

  /// Share event
  void shareEvent() {
    _showInfo('Sharing: ${event.value?.name ?? "Event"}');
    // TODO: Implement actual sharing functionality
  }

  /// Refresh event details
  Future<void> refreshEventDetails() async {
    await Future.wait([loadEventDetails(), loadFoldersForEvent()]);
  }

  // ==================== GETTERS ====================

  /// Check if current user is event creator
  bool _isCurrentUserCreator() {
    if (event.value == null) return false;
    final currentUserId = _authService.currentUser?.id;
    return event.value!.creatorId == currentUserId;
  }

  /// Get recipient images
  List<String> get recipientImages {
    if (event.value?.recipients == null) return [];

    // For now, return placeholder images
    // In real app, you'd fetch user profile pictures
    return List.generate(
      event.value!.recipients!.length.clamp(0, 5),
      (index) => 'https://via.placeholder.com/100',
    );
  }

  /// Get recipient count
  int get recipientCount => event.value?.recipients?.length ?? 0;

  /// Check if event has timings
  bool get hasTimings {
    if (event.value == null) return false;
    return event.value!.formattedStartTime != null ||
        event.value!.formattedEndTime != null;
  }

  // ==================== NOTIFICATIONS ====================

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
