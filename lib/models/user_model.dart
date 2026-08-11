import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _hasCover = false;
  String _fullName = '';
  String _idNumber = '';
  String _phoneNumber = '';
  String _email = '';
  String _selectedProduct = '';
  String _selectedTier = '';
  String _paymentMethod = '';
  ThemeMode _themeMode = ThemeMode.dark;
  List<Claim> _claims = [];
  
  bool get isLoggedIn => _isLoggedIn;
  bool get hasCover => _hasCover;
  String get fullName => _fullName;
  String get idNumber => _idNumber;
  String get phoneNumber => _phoneNumber;
  String get email => _email;
  String get selectedProduct => _selectedProduct;
  String get selectedTier => _selectedTier;
  String get paymentMethod => _paymentMethod;
  ThemeMode get themeMode => _themeMode;
  List<Claim> get claims => _claims;
  
  void login(String name, String id, String phone, String email) {
    _isLoggedIn = true;
    _fullName = name;
    _idNumber = id;
    _phoneNumber = phone;
    _email = email;
    notifyListeners();
  }
  
  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
  
  void setCover(String product, String tier, String paymentMethod) {
    _hasCover = true;
    _selectedProduct = product;
    _selectedTier = tier;
    _paymentMethod = paymentMethod;
    notifyListeners();
  }
  
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
  
  void addClaim(Claim claim) {
    _claims.insert(0, claim);
    notifyListeners();
  }
  
  void updateClaimStatus(String claimId, String status) {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index != -1) {
      _claims[index].status = status;
      notifyListeners();
    }
  }
}

class Claim {
  String id;
  String type;
  String description;
  String status;
  DateTime date;
  List<String> documents;
  String? declineReason;
  
  Claim({
    required this.id,
    required this.type,
    required this.description,
    required this.status,
    required this.date,
    this.documents = const [],
    this.declineReason,
  });
}