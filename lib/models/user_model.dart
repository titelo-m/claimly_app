import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _hasCover = false;
  String _policyStatus = '';
  String _fullName = '';
  String _idNumber = '';
  String _phoneNumber = '';
  String _email = '';
  String _role = 'CUSTOMER';
  String _status = 'PENDING_APPROVAL';
  String _selectedProduct = '';
  String _selectedTier = '';
  String _paymentMethod = '';
  ThemeMode _themeMode = ThemeMode.dark;
  List<Claim> _claims = [];

  // Real-insurer registration fields, backed by the User entity on the
  // backend (see RegisterRequest.java / User.java / UserProfileResponse.java).
  String _dateOfBirth = '';
  String _gender = '';
  String _employmentStatus = '';
  String _occupation = '';
  String _monthlyIncome = '';
  String _nextOfKinName = '';
  String _nextOfKinPhone = '';
  String _profilePictureUrl = '';

  // Extended profile fields used by the Profile screen.
  // NOTE: these are currently frontend-only - the backend User/Policy
  // entities don't have columns for address or banking details yet, so
  // updateProfile() below does not sync to the server. Add matching
  // columns + a PUT /api/profile endpoint if/when this needs to persist.
  String _altPhone = '';
  String _street = '';
  String _city = '';
  String _postalCode = '';
  String _province = '';
  String _bankName = '';
  String _accountHolder = '';
  String _accountNumber = '';
  String _branchCode = '';
  String _accountType = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get hasCover => _hasCover;
  String get policyStatus => _policyStatus;
  bool get isCoverPending => _hasCover && _policyStatus == 'PENDING';
  String get fullName => _fullName;
  String get idNumber => _idNumber;
  String get phoneNumber => _phoneNumber;
  String get email => _email;
  String get role => _role;
  String get status => _status;
  bool get isAdmin => _role == 'ADMIN' || _role == 'SUPER_ADMIN';
  bool get isSuperAdmin => _role == 'SUPER_ADMIN';
  bool get isPendingApproval => _status == 'PENDING_APPROVAL';
  bool get isSuspended => _status == 'SUSPENDED';
  String get selectedProduct => _selectedProduct;
  String get selectedTier => _selectedTier;
  String get paymentMethod => _paymentMethod;
  ThemeMode get themeMode => _themeMode;
  List<Claim> get claims => _claims;

  String get dateOfBirth => _dateOfBirth;
  String get gender => _gender;
  String get employmentStatus => _employmentStatus;
  String get occupation => _occupation;
  String get monthlyIncome => _monthlyIncome;
  String get nextOfKinName => _nextOfKinName;
  String get nextOfKinPhone => _nextOfKinPhone;
  String get profilePictureUrl => _profilePictureUrl;

  String get altPhone => _altPhone;
  String get street => _street;
  String get city => _city;
  String get postalCode => _postalCode;
  String get province => _province;
  String get bankName => _bankName;
  String get accountHolder => _accountHolder;
  String get accountNumber => _accountNumber;
  String get branchCode => _branchCode;
  String get accountType => _accountType;

  void login(String name, String id, String phone, String email,
      {String role = 'CUSTOMER', String status = 'ACTIVE'}) {
    _isLoggedIn = true;
    _fullName = name;
    _idNumber = id;
    _phoneNumber = phone;
    _email = email;
    _role = role;
    _status = status;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _hasCover = false;
    _policyStatus = '';
    _fullName = '';
    _idNumber = '';
    _phoneNumber = '';
    _email = '';
    _role = 'CUSTOMER';
    _status = 'PENDING_APPROVAL';
    _selectedProduct = '';
    _selectedTier = '';
    _paymentMethod = '';
    _claims = [];
    _dateOfBirth = '';
    _gender = '';
    _employmentStatus = '';
    _occupation = '';
    _monthlyIncome = '';
    _nextOfKinName = '';
    _nextOfKinPhone = '';
    _profilePictureUrl = '';
    _altPhone = '';
    _street = '';
    _city = '';
    _postalCode = '';
    _province = '';
    _bankName = '';
    _accountHolder = '';
    _accountNumber = '';
    _branchCode = '';
    _accountType = '';
    notifyListeners();
  }

  void setCover(String product, String tier, String paymentMethod, {String policyStatus = 'PENDING'}) {
    _hasCover = true;
    _selectedProduct = product;
    _selectedTier = tier;
    _paymentMethod = paymentMethod;
    _policyStatus = policyStatus;
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

  /// Just updates the profile picture URL after a successful upload,
  /// without needing a full profile refetch.
  void setProfilePicture(String url) {
    _profilePictureUrl = url;
    notifyListeners();
  }

  // NEW: Update from API response
  void updateFromApi(Map<String, dynamic> data) {
    _isLoggedIn = true;
    _fullName = data['fullName'] ?? _fullName;
    _idNumber = data['idNumber'] ?? _idNumber;
    _phoneNumber = data['phoneNumber'] ?? _phoneNumber;
    _email = data['email'] ?? _email;
    _role = data['role'] ?? _role;
    _status = data['status'] ?? _status;
    _hasCover = data['hasCover'] ?? false;
    _selectedProduct = data['productType'] ?? '';
    _selectedTier = data['tier'] ?? '';
    _paymentMethod = data['paymentMethod'] ?? '';
    _policyStatus = data['policyStatus'] ?? '';
    _dateOfBirth = data['dateOfBirth']?.toString() ?? _dateOfBirth;
    _gender = data['gender'] ?? _gender;
    _employmentStatus = data['employmentStatus'] ?? _employmentStatus;
    _occupation = data['occupation'] ?? _occupation;
    _monthlyIncome = data['monthlyIncome']?.toString() ?? _monthlyIncome;
    _nextOfKinName = data['nextOfKinName'] ?? _nextOfKinName;
    _nextOfKinPhone = data['nextOfKinPhone'] ?? _nextOfKinPhone;
    _profilePictureUrl = data['profilePictureUrl'] ?? _profilePictureUrl;
    notifyListeners();
  }

  /// Updates the extended profile fields (address + banking details).
  /// Frontend-only for now - see the note above the field declarations.
  void updateProfile({
    String? fullName,
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
