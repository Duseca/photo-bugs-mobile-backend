import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/users_model.dart/customer_models.dart';
import 'package:rxdart/rxdart.dart';

import '../app/app_service.dart';

class AuthService extends GetxService {
  late final AppService _appService;
  late final BehaviorSubject<CustomerModel?> _authCustomerBehaviorSubject;

  BehaviorSubject<CustomerModel?>? get authCustomerBehaviorSubject =>
      _authCustomerBehaviorSubject;

  Future<AuthService> init() async {
    await _init();
    return this;
  }

  @override
  void onReady() {
    super.onReady();
    _watchAuthState();
  }

  Future<void> _init() async {
    _appService = Get.find<AppService>();
    _authCustomerBehaviorSubject = BehaviorSubject.seeded(null);
    final authCustomerId = _appService.sharedPreferences.getString(
      'current_user',
    );
    if (authCustomerId != null) {
      _authCustomerBehaviorSubject.add(
        CustomerModel.fromJson(jsonDecode(authCustomerId)),
      );
    }
  }

  void _watchAuthState() {
    // CustomerModel customer =
    //     _authCustomerBehaviorSubject.value ?? CustomerModel();
    // _appService.sharedPreferences
    //     .setString('current_user', jsonEncode(customer.toJson()));
    // _authCustomerBehaviorSubject.add(customer);
  }

  CustomerModel? get authMerchant {
    return _authCustomerBehaviorSubject.value;
  }

  Future<void> cleanStorage() async {
    await _appService.sharedPreferences.remove('current_user');
    _authCustomerBehaviorSubject.add(null);
  }
}
