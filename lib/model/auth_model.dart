// lib/models/auth_model.dart

class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final int pointsBalance;
  final int? ordersCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    required this.pointsBalance,
    this.ordersCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? 'user',
      pointsBalance: json['points_balance'] ?? 0,
      // Only present on GET /auth/me, not on register/login responses.
      ordersCount: json['orders_count'],
    );
  }
}

// Used for the /register endpoint
class RegisterResponse {
  final bool status;
  final String message;
  final User? user;

  RegisterResponse({required this.status, required this.message, this.user});

  /// The backend replies with `{"message": "...", "data": {"user": {...}}}`
  /// on success — there is no "status" field in the JSON body itself.
  /// Success/failure is signaled purely by the HTTP status code, so the
  /// caller (AuthService) passes that in explicitly instead of us trying
  /// (and failing) to read a key that was never there.
  factory RegisterResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return RegisterResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      user: json['data'] != null && json['data']['user'] != null
          ? User.fromJson(json['data']['user'])
          : null,
    );
  }
}

// Used for the /login endpoint
class LoginResponse {
  final bool status;
  final String message;
  final User? user;
  final String? token; // Captures the auth token

  LoginResponse({required this.status, required this.message, this.user, this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return LoginResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      user: json['data'] != null && json['data']['user'] != null
          ? User.fromJson(json['data']['user'])
          : null,
      token: json['data'] != null ? json['data']['token'] : null,
    );
  }
}

// Used for GET /auth/me
class MeResponse {
  final bool status;
  final String message;
  final User? user;

  MeResponse({required this.status, required this.message, this.user});

  factory MeResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return MeResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      user: json['data'] != null ? User.fromJson(json['data']) : null,
    );
  }
}
