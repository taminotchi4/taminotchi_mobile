class LoginRequest {
  final String phoneNumber;
  final String password;

  const LoginRequest({
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'password': password,
      };
}

class LoginUserData {
  final String id;
  final String fullName;
  final String username;
  final String phoneNumber;
  final String? photoPath;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const LoginUserData({
    required this.id,
    required this.fullName,
    required this.username,
    required this.phoneNumber,
    this.photoPath,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory LoginUserData.fromJson(Map<String, dynamic> json) {
    return LoginUserData(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String,
      photoPath: json['photoPath'] as String?,
      role: json['role'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class LoginResponse {
  final String accessToken;
  final String role;
  final LoginUserData user;
  final String username;
  final String phoneNumber;

  const LoginResponse({
    required this.accessToken,
    required this.role,
    required this.user,
    required this.username,
    required this.phoneNumber,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 Login Response JSON: $json');
    final data = json['data'];
    print('🔍 Login data field: $data');
    print('🔍 Login data type: ${data.runtimeType}');
    
    return LoginResponse(
      accessToken: data['accessToken']?.toString() ?? '',
      role: data['role']?.toString() ?? '',
      user: LoginUserData.fromJson(data['user'] as Map<String, dynamic>),
      username: data['username']?.toString() ?? '',
      phoneNumber: data['phoneNumber']?.toString() ?? '',
    );
  }
}
