// lib/models/auth_model.dart

class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final int pointsBalance;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    required this.pointsBalance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? 'user',
      pointsBalance: json['points_balance'] ?? 0,
    );
  }
}

// Used for the /register endpoint
class RegisterResponse {
  final bool status;
  final String message;
  final User? user;

  RegisterResponse({
    required this.status,
    required this.message,
    this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] ?? false,
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

  LoginResponse({
    required this.status,
    required this.message,
    this.user,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? 'Unknown error occurred',
      user: json['data'] != null && json['data']['user'] != null
          ? User.fromJson(json['data']['user'])
          : null,
      // Safely parse the token from the nested data object
      token: json['data'] != null ? json['data']['token'] : null,
    );
  }
}