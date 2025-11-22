// controllers/user_events_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/data/models/folder_model.dart';
import 'package:photo_bug/app/modules/user_events/widgets/folderbottomsheet.dart';
import 'package:photo_bug/app/services/event_service.dart/event_service.dart';
import 'package:photo_bug/app/services/folder_service/folder_service.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/routes/app_pages.dart';

class UserEventDetailsController extends GetxController {
  late final EventService _eventService;
  late final FolderService _folderService;
  late final AuthService _authService;

  final Rx<Event?> event = Rx<Event?>(null);
  final RxList<Folder> folders = <Folder>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFoldersLoading = false.obs;
  final RxString eventId = ''.obs;
  final RxBool isMyEvent = false.obs;

  // Controller lifecycle flag
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _loadArguments();
  }

  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
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
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      eventId.value = arguments['eventId'] ?? '';
      event.value = arguments['event'];
      isMyEvent.value = arguments['isMyEvent'] ?? false;

      if (event.value != null) {
        _checkEventOwnership();
        loadFolders();
      } else if (eventId.value.isNotEmpty) {
        loadEventDetails();
      }
    }
  }

  void _checkEventOwnership() {
    if (event.value != null && _authService.currentUser != null) {
      isMyEvent.value = event.value!.creatorId == _authService.currentUser!.id;
    }
  }

  Future<void> loadEventDetails() async {
    if (eventId.value.isEmpty || _isDisposed) return;

    try {
      isLoading.value = true;
      final response = await _eventService.getEventById(eventId.value);

      if (_isDisposed) return;

      if (response.success && response.data != null) {
        event.value = response.data;
        _checkEventOwnership();
        loadFolders();
      } else {
        _showError(response.error ?? 'Failed to load event');
      }
    } catch (e) {
      print('❌ Error loading event: $e');
      if (!_isDisposed) {
        _showError('Failed to load event details');
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadFolders() async {
    if (event.value?.id == null || _isDisposed) return;

    try {
      isFoldersLoading.value = true;
      final response = await _folderService.getFoldersByEvent(event.value!.id!);

      if (_isDisposed) return;

      if (response.success && response.data != null) {
        folders.value = response.data!;
        print('✅ Loaded ${folders.length} folders');
      }
    } catch (e) {
      print('❌ Error loading folders: $e');
    } finally {
      if (!_isDisposed) {
        isFoldersLoading.value = false;
      }
    }
  }

  Future<void> refreshEventDetails() async {
    if (_isDisposed) return;
    await loadEventDetails();
  }

  void showCreateFolderDialog() {
    if (_isDisposed || event.value?.id == null) {
      if (event.value?.id == null) {
        _showError('Event not found');
      }
      return;
    }

    Get.dialog(
      _CreateFolderDialog(
        onCreateFolder: (folderName) {
          if (!_isDisposed) {
            createFolder(folderName);
          }
        },
      ),
      barrierDismissible: true,
    );
  }

  Future<void> createFolder(String folderName) async {
    if (_isDisposed || event.value?.id == null) {
      if (event.value?.id == null && !_isDisposed) {
        _showError('Event not found');
      }
      return;
    }

    try {
      isLoading.value = true;

      final request = CreateFolderRequest(
        name: folderName,
        eventId: event.value!.id,
      );

      print('🔄 Creating folder: $folderName for event: ${event.value!.id}');

      final response = await _folderService.createFolder(request);
      print(response);

      if (_isDisposed) return;

      if (response.success && response.data != null) {
        _showSuccess('Folder created successfully');
        await loadFolders();
      } else {
        _showError(response.error ?? 'Failed to create folder');
      }
    } catch (e) {
      print('❌ Error creating folder: $e');
      if (!_isDisposed) {
        _showError('Failed to create folder');
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> acceptEventInvitation() async {
    if (_isDisposed || event.value?.id == null) return;

    try {
      isLoading.value = true;
      final response = await _eventService.acceptEventInvitation(
        event.value!.id!,
      );

      if (_isDisposed) return;

      if (response.success) {
        _showSuccess('Event invitation accepted');
        await loadEventDetails();
      } else {
        _showError(response.error ?? 'Failed to accept invitation');
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError('Failed to accept invitation');
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> declineEventInvitation() async {
    if (_isDisposed || event.value?.id == null) return;

    try {
      isLoading.value = true;
      final response = await _eventService.declineEventInvitation(
        event.value!.id!,
      );

      if (_isDisposed) return;

      if (response.success) {
        _showSuccess('Event invitation declined');
        Get.back(result: true);
      } else {
        _showError(response.error ?? 'Failed to decline invitation');
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError('Failed to decline invitation');
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> deleteEvent() async {
    if (_isDisposed || event.value?.id == null) return;

    try {
      isLoading.value = true;
      final response = await _eventService.deleteEvent(event.value!.id!);

      if (_isDisposed) return;

      if (response.success) {
        _showSuccess('Event deleted successfully');
        Get.back(result: true);
      } else {
        _showError(response.error ?? 'Failed to delete event');
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError('Failed to delete event');
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  void navigateToFolderDetails(Folder folder) {
    if (_isDisposed || folder.id == null) return;
    showFolderDetailsBottomSheet(folder);
  }

  void showFolderDetailsBottomSheet(Folder folder) {
    if (_isDisposed) return;

    Get.bottomSheet(
      FolderDetailsBottomSheet(
        folder: folder,
        onRefresh: () {
          if (!_isDisposed) {
            loadFolders();
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void shareEvent() {
    if (_isDisposed) return;
    _showInfo('Share functionality coming soon!');
  }

  int get recipientCount => event.value?.recipients?.length ?? 0;

  List<String> get recipientImages {
    if (event.value?.recipients == null) return [];
    return [];
  }

  bool get hasTimings {
    return event.value?.timeStart != null || event.value?.timeEnd != null;
  }

  void _showSuccess(String message) {
    if (_isDisposed) return;

    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showError(String message) {
    if (_isDisposed) return;

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void _showInfo(String message) {
    if (_isDisposed) return;

    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }
}

// ==================== CREATE FOLDER DIALOG WIDGET ====================

class _CreateFolderDialog extends StatefulWidget {
  final Function(String) onCreateFolder;

  const _CreateFolderDialog({required this.onCreateFolder});

  @override
  State<_CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<_CreateFolderDialog> {
  late final TextEditingController _folderNameController;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _folderNameController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      final folderName = _folderNameController.text.trim();
      Navigator.of(context).pop();
      // Use a delay to ensure dialog is fully closed
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.onCreateFolder(folderName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.create_new_folder, color: Colors.blue, size: 24),
          const SizedBox(width: 8),
          const Text('Create New Folder'),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _folderNameController,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Folder Name',
                    hintText: 'Enter folder name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a folder name';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleCreate(),
                ),
                const SizedBox(height: 12),
                Text(
                  'This folder will be created for this event',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleCreate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
