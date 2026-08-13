import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _hasCover = false;
  String _fullName = '';
  String _surname = '';
  String _idNumber = '';
  String _phoneNumber = '';
  String _altPhone = '';
  String _email = '';
  String _street = '';
  String _city = '';
  String _province = '';
  String _postalCode = '';
  String _selectedProduct = '';
  String _selectedTier = '';
  String _paymentMethod = '';
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode
  List<Claim> _claims = [];
  
  // Bank details
  String _bankName = '';
  String _accountHolder = '';
  String _accountNumber = '';
  String _branchCode = '';
  String _accountType = '';
  
  bool get isLoggedIn => _isLoggedIn;
  bool get hasCover => _hasCover;
  String get fullName => _fullName;
  String get surname => _surname;
  String get idNumber => _idNumber;
  String get phoneNumber => _phoneNumber;
  String get altPhone => _altPhone;
  String get email => _email;
  String get street => _street;
  String get city => _city;
  String get province => _province;
  String get postalCode => _postalCode;
  String get selectedProduct => _selectedProduct;
  String get selectedTier => _selectedTier;
  String get paymentMethod => _paymentMethod;
  ThemeMode get themeMode => _themeMode;
  List<Claim> get claims => _claims;
  String get bankName => _bankName;
  String get accountHolder => _accountHolder;
  String get accountNumber => _accountNumber;
  String get branchCode => _branchCode;
  String get accountType => _accountType;
  
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
    _hasCover = false;
    _fullName = '';
    _surname = '';
    _idNumber = '';
    _phoneNumber = '';
    _altPhone = '';
    _email = '';
    _street = '';
    _city = '';
    _province = '';
    _postalCode = '';
    _bankName = '';
    _accountHolder = '';
    _accountNumber = '';
    _branchCode = '';
    _accountType = '';
    _selectedProduct = '';
    _selectedTier = '';
    _paymentMethod = '';
    _claims = [];
    notifyListeners();
  }
  
  void setCover(String product, String tier, String paymentMethod) {
    _hasCover = true;
    _selectedProduct = product;
    _selectedTier = tier;
    _paymentMethod = paymentMethod;
    notifyListeners();
  }
  
  void updateProfile({
    String? fullName,
    String? surname,
    String? phoneNumber,
    String? altPhone,
    String? email,
    String? street,
    String? city,
    String? province,
    String? postalCode,
    String? bankName,
    String? accountHolder,
    String? accountNumber,
    String? branchCode,
    String? accountType,
  }) {
    if (fullName != null) _fullName = fullName;
    if (surname != null) _surname = surname;
    if (phoneNumber != null) _phoneNumber = phoneNumber;
    if (altPhone != null) _altPhone = altPhone;
    if (email != null) _email = email;
    if (street != null) _street = street;
    if (city != null) _city = city;
    if (province != null) _province = province;
    if (postalCode != null) _postalCode = postalCode;
    if (bankName != null) _bankName = bankName;
    if (accountHolder != null) _accountHolder = accountHolder;
    if (accountNumber != null) _accountNumber = accountNumber;
    if (branchCode != null) _branchCode = branchCode;
    if (accountType != null) _accountType = accountType;
    notifyListeners();
  }
  
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
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