import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  /// Backend host without the "/api" suffix - used to build full URLs for
  /// static files served from /uploads/** (e.g. profile pictures, documents).
  static String get mediaBaseUrl => baseUrl.replaceFirst('/api', '');

  /// http.MultipartFile.fromBytes defaults to application/octet-stream if
  /// you don't tell it otherwise - and the backend rejects that content
  /// type outright. This guesses the real MIME type from the filename so
  /// uploads (profile pictures, documents) are correctly recognised.
  static MediaType _guessContentType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.pdf')) return MediaType('application', 'pdf');
    // Covers .jpg and .jpeg, and is a safe default for anything else
    // image_picker/file_picker hands back without a recognised extension.
    return MediaType('image', 'jpeg');
  }

  /// Pulls a human-readable message out of the backend's JSON error body
  /// (see GlobalExceptionHandler on the backend), falling back to the raw
  /// body if it isn't JSON for some reason.
  static String _extractError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {
      // Not JSON - fall through to raw body
    }
    return response.body;
  }

  static Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
      };

  // ============ AUTH ============

  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  // Verify OTP (supports both email and phone)
  static Future<bool> verifyOTP(String identifier, String otpCode,
      {String method = 'email'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        method == 'email' ? 'email' : 'phoneNumber': identifier,
        'otpCode': otpCode,
        'method': method,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) == true;
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> sendEmailOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/otp/send-email?email=$email'),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  // ============ PROFILE ============

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  /// Upload a profile picture. Works on web, mobile, and desktop because it
  /// uploads raw bytes rather than a dart:io File (File paths don't exist
  /// in a browser). Returns the new profilePictureUrl.
  static Future<String> uploadProfilePicture(
    String token,
    Uint8List bytes,
    String filename,
  ) async {
    final uri = Uri.parse('$baseUrl/profile/picture');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: _guessContentType(filename),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['profilePictureUrl'] ?? '';
    } else {
      throw Exception(_extractError(response));
    }
  }

  // ============ DOCUMENTS ============

  /// Upload a KYC document (ID, proof of address, proof of income, bank
  /// confirmation letter). documentType must match the backend's
  /// DocumentType enum: ID_DOCUMENT, PROOF_OF_ADDRESS, PROOF_OF_INCOME,
  /// BANK_CONFIRMATION_LETTER, OTHER.
  static Future<Map<String, dynamic>> uploadDocument(
    String token,
    Uint8List bytes,
    String filename,
    String documentType,
  ) async {
    final uri = Uri.parse('$baseUrl/documents/upload?documentType=$documentType');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: _guessContentType(filename),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<List<dynamic>> getMyDocuments(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/documents'),
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  // ============ POLICY / COVER ============

  static Future<Map<String, dynamic>> selectCover(
      String token, Map<String, dynamic> coverData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/policy/select'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(coverData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  // ============ CLAIMS ============

  /// Submits a claim as multipart/form-data: a "claim" JSON part plus zero
  /// or more "documents" file parts - matching ClaimController.submitClaim's
  /// @RequestPart signature on the backend.
  static Future<Map<String, dynamic>> submitClaim(
    String token,
    String claimType,
    String description,
    List<PlatformFile> files,
  ) async {
    final uri = Uri.parse('$baseUrl/claims/submit');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromString(
        'claim',
        jsonEncode({'claimType': claimType, 'description': description}),
        contentType: MediaType('application', 'json'),
      ),
    );

    for (final file in files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      request.files.add(
        http.MultipartFile.fromBytes(
          'documents',
          bytes,
          filename: file.name,
          contentType: _guessContentType(file.name),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<List<dynamic>> getClaims(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/claims'),
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<Map<String, dynamic>> getClaimDetail(String token, String claimReference) async {
    final response = await http.get(
      Uri.parse('$baseUrl/claims/$claimReference'),
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  // ============ ADMIN (ADMIN + SUPER_ADMIN) ============

  static Future<List<dynamic>> getAdminUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<Map<String, dynamic>> getAdminUserDetail(
      String token, int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/$userId'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> activateUser(String token, int userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/activate'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> suspendUser(String token, int userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/suspend'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> reactivateUser(String token, int userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/reactivate'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  static Future<List<dynamic>> getAdminClaims(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/claims'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<List<dynamic>> getPendingPolicies(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/policies/pending'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> approveCover(String token, int policyId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/policies/$policyId/approve'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  // ============ CHAT (CUSTOMER) ============

  static Future<List<dynamic>> getMyChatMessages(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/messages'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> sendChatMessage(String token, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'message': message}),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  // ============ CHAT (ADMIN / SUPER ADMIN) ============

  static Future<List<dynamic>> getAdminConversations(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/chat/conversations'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<List<dynamic>> getAdminConversation(String token, int customerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/chat/conversations/$customerId'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> sendAdminChatReply(String token, int customerId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/chat/conversations/$customerId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'message': message}),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  // ============ SUPER ADMIN ONLY ============

  static Future<List<dynamic>> getAdmins(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/super-admin/admins'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> promoteToAdmin(String token, int userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/super-admin/users/$userId/promote-to-admin'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> demoteToCustomer(String token, int userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/super-admin/users/$userId/demote-to-customer'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> suspendAdmin(String token, int userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/super-admin/admins/$userId/suspend'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> reactivateAdmin(String token, int userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/super-admin/admins/$userId/reactivate'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> verifyClaim(
    String token,
    int claimId, {
    required bool approve,
    String? declineReason,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/super-admin/claims/$claimId/verify'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'approve': approve,
        if (declineReason != null) 'declineReason': declineReason,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  static Future<void> markClaimAsPaid(
    String token,
    int claimId, {
    required String payoutAmount,
    required String payoutReference,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/super-admin/claims/$claimId/mark-paid'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'payoutAmount': payoutAmount,
        'payoutReference': payoutReference,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }
}
