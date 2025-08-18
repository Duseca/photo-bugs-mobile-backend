import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/models/add_listings_model/add_listing_model.dart';

class AddListingController extends GetxController {
  // Observable variables
  final Rx<ListingType> currentTab = ListingType.creator.obs;
  final RxBool isLoading = false.obs;
  final RxBool canPublish = false.obs;

  // Form controllers
  final Map<String, TextEditingController> textControllers = {};
  final Map<String, FocusNode> focusNodes = {};

  // Tab list
  final List<ListingType> tabs = [ListingType.creator, ListingType.hostedEvent];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  // Initialize text controllers
  void _initializeControllers() {
    final fields = [
      // Common fields
      'name', 'eventName', 'location', 'description', 'date', 'timeStart', 'timeEnd',
      'keywords', 'email', 'phoneNumber', 'socialMediaLinks',
      // Creator specific
      'prices', 'experienceQualifications',
      // Host event specific
      'hostOrganizerName', 'expectedAttendees', 'budgetCompensation',
      'specialRequirements', 'eventTheme', 'applicationDeadline'
    ];

    for (String field in fields) {
      textControllers[field] = TextEditingController();
      focusNodes[field] = FocusNode();
      
      // Add listeners to validate form
      textControllers[field]!.addListener(_validateForm);
    }
  }

  // Dispose controllers
  void _disposeControllers() {
    for (var controller in textControllers.values) {
      controller.dispose();
    }
    for (var focusNode in focusNodes.values) {
      focusNode.dispose();
    }
  }

  // Switch tab
  void switchTab(ListingType tab) {
    currentTab.value = tab;
    _validateForm();
  }

  // Validate form
  void _validateForm() {
    if (currentTab.value == ListingType.creator) {
      canPublish.value = _validateCreatorForm();
    } else {
      canPublish.value = _validateHostEventForm();
    }
  }

  // Validate creator form
  bool _validateCreatorForm() {
    return textControllers['name']!.text.isNotEmpty &&
           textControllers['email']!.text.isNotEmpty &&
           textControllers['location']!.text.isNotEmpty;
  }

  // Validate host event form
  bool _validateHostEventForm() {
    return textControllers['eventName']!.text.isNotEmpty &&
           textControllers['email']!.text.isNotEmpty &&
           textControllers['location']!.text.isNotEmpty;
  }

  // Publish listing
  void publishListing() async {
    if (!canPublish.value) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (currentTab.value == ListingType.creator) {
        await _publishCreatorListing();
      } else {
        await _publishHostEvent();
      }

      Get.snackbar('Success', 'Listing published successfully!');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to publish listing');
    } finally {
      isLoading.value = false;
    }
  }

  // Publish creator listing
  Future<void> _publishCreatorListing() async {
    final creatorListing = CreatorListing(
      name: textControllers['name']!.text,
      location: textControllers['location']!.text,
      description: textControllers['description']!.text,
      email: textControllers['email']!.text,
      phoneNumber: textControllers['phoneNumber']!.text,
      prices: textControllers['prices']!.text,
      experienceQualifications: textControllers['experienceQualifications']!.text,
      keywords: _parseKeywords(textControllers['keywords']!.text),
      servicesOffered: [], // Will be populated from bottom sheet selections
      languagesSpoken: [], // Will be populated from dropdown
      socialMediaLinks: _parseSocialLinks(textControllers['socialMediaLinks']!.text),
      portfolioImages: [], // Will be populated from file uploads
    );

    // Here you would make actual API call
    // await listingService.createCreatorListing(creatorListing);
  }

  // Publish host event
  Future<void> _publishHostEvent() async {
    final hostEvent = HostEvent(
      eventName: textControllers['eventName']!.text,
      location: textControllers['location']!.text,
      description: textControllers['description']!.text,
      hostOrganizerName: textControllers['hostOrganizerName']!.text,
      email: textControllers['email']!.text,
      phoneNumber: textControllers['phoneNumber']!.text,
      expectedAttendees: int.tryParse(textControllers['expectedAttendees']!.text) ?? 0,
      budgetCompensation: textControllers['budgetCompensation']!.text,
      specialRequirements: textControllers['specialRequirements']!.text,
      eventTheme: textControllers['eventTheme']!.text,
      keywords: _parseKeywords(textControllers['keywords']!.text),
      eventTypes: [], // Will be populated from bottom sheet selections
      servicesNeeded: [], // Will be populated from bottom sheet selections
      socialMediaLinks: _parseSocialLinks(textControllers['socialMediaLinks']!.text),
    );

    // Here you would make actual API call
    // await listingService.createHostEvent(hostEvent);
  }

  // Parse keywords from comma-separated string
  List<String> _parseKeywords(String keywords) {
    return keywords.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
  }

  // Parse social media links
  List<String> _parseSocialLinks(String links) {
    return links.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  }

  // Get text controller
  TextEditingController getController(String field) {
    return textControllers[field] ?? TextEditingController();
  }

  // Get focus node
  FocusNode getFocusNode(String field) {
    return focusNodes[field] ?? FocusNode();
  }
}

// controllers/event_type_controller.dart
class EventTypeController extends GetxController {
  // Observable variables
  final RxList<ServiceCategory> eventCategories = <ServiceCategory>[].obs;
  final RxList<String> selectedEventTypes = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString otherEventType = ''.obs;
  
  // Text controller for other field
  final TextEditingController otherController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadEventTypes();
  }

  @override
  void onClose() {
    otherController.dispose();
    super.onClose();
  }

  // Load event types from utils
  void loadEventTypes() {
    // This would come from your eventTypes utils file
    final sampleEventTypes = [
      ServiceCategory(
        title: 'Social Events',
        items: ['Wedding', 'Birthday Party', 'Anniversary', 'Baby Shower'],
      ),
      ServiceCategory(
        title: 'Corporate Events',
        items: ['Conference', 'Team Building', 'Product Launch', 'Networking'],
      ),
      ServiceCategory(
        title: 'Entertainment',
        items: ['Concert', 'Festival', 'Theater', 'Comedy Show'],
      ),
    ];
    
    eventCategories.assignAll(sampleEventTypes);
  }

  // Toggle event type selection
  void toggleEventType(String eventType) {
    if (selectedEventTypes.contains(eventType)) {
      selectedEventTypes.remove(eventType);
    } else {
      selectedEventTypes.add(eventType);
    }
  }

  // Search event types
  void searchEventTypes(String query) {
    searchQuery.value = query;
    // Implement search logic if needed
  }

  // Add other event type
  void addOtherEventType() {
    final other = otherController.text.trim();
    if (other.isNotEmpty && !selectedEventTypes.contains(other)) {
      selectedEventTypes.add(other);
      otherController.clear();
    }
  }

  // Get filtered categories based on search
  List<ServiceCategory> get filteredCategories {
    if (searchQuery.value.isEmpty) return eventCategories;
    
    return eventCategories.map((category) {
      final filteredItems = category.items.where((item) =>
          item.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
      
      return ServiceCategory(title: category.title, items: filteredItems);
    }).where((category) => category.items.isNotEmpty).toList();
  }

  // Continue with selection
  void continueWithSelection() {
    if (otherController.text.trim().isNotEmpty) {
      addOtherEventType();
    }
    Get.back(result: selectedEventTypes.toList());
  }
}

// controllers/services_controller.dart
class ServicesController extends GetxController {
  // Observable variables
  final RxList<ServiceCategory> serviceCategories = <ServiceCategory>[].obs;
  final RxList<String> selectedServices = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString serviceType = ''.obs; // 'needed' or 'offered'
  
  // Text controller for other field
  final TextEditingController otherController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    serviceType.value = arguments?['type'] ?? 'needed';
    loadServices();
  }

  @override
  void onClose() {
    otherController.dispose();
    super.onClose();
  }

  // Load services based on type
  void loadServices() {
    List<ServiceCategory> services;
    
    if (serviceType.value == 'offered') {
      services = _getServicesOffered();
    } else {
      services = _getServicesNeeded();
    }
    
    serviceCategories.assignAll(services);
  }

  // Get services offered data
  List<ServiceCategory> _getServicesOffered() {
    return [
      ServiceCategory(
        title: 'Photography',
        items: ['Wedding Photography', 'Portrait Photography', 'Event Photography', 'Product Photography'],
      ),
      ServiceCategory(
        title: 'Videography',
        items: ['Wedding Videography', 'Corporate Videos', 'Music Videos', 'Documentary'],
      ),
      ServiceCategory(
        title: 'Design',
        items: ['Graphic Design', 'Web Design', 'Logo Design', 'UI/UX Design'],
      ),
    ];
  }

  // Get services needed data
  List<ServiceCategory> _getServicesNeeded() {
    return [
      ServiceCategory(
        title: 'Creative Services',
        items: ['Photographer', 'Videographer', 'DJ', 'MC/Host'],
      ),
      ServiceCategory(
        title: 'Technical Services',
        items: ['Sound Engineer', 'Lighting Technician', 'Video Editor', 'Live Streaming'],
      ),
      ServiceCategory(
        title: 'Event Services',
        items: ['Event Coordinator', 'Decorator', 'Catering', 'Security'],
      ),
    ];
  }

  // Toggle service selection
  void toggleService(String service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
  }

  // Search services
  void searchServices(String query) {
    searchQuery.value = query;
  }

  // Add other service
  void addOtherService() {
    final other = otherController.text.trim();
    if (other.isNotEmpty && !selectedServices.contains(other)) {
      selectedServices.add(other);
      otherController.clear();
    }
  }

  // Get filtered categories
  List<ServiceCategory> get filteredCategories {
    if (searchQuery.value.isEmpty) return serviceCategories;
    
    return serviceCategories.map((category) {
      final filteredItems = category.items.where((item) =>
          item.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
      
      return ServiceCategory(title: category.title, items: filteredItems);
    }).where((category) => category.items.isNotEmpty).toList();
  }

  // Continue with selection
  void continueWithSelection() {
    if (otherController.text.trim().isNotEmpty) {
      addOtherService();
    }
    Get.back(result: selectedServices.toList());
  }
}