class CompleteRegisterRequest {
  final String phoneNumber;
  final String fullName;
  final String username;
  final String password;
  final String language;

  const CompleteRegisterRequest({
    required this.phoneNumber,
    required this.fullName,
    required this.username,
    required this.password,
    required this.language,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'username': username,
        'password': password,
        'language': language,
      };
}

class UserData {
  final String id;
  final String fullName;
  final String username;
  final String phoneNumber;
  final String? photoPath;
  final String language;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserData({
    required this.id,
    required this.fullName,
    required this.username,
    required this.phoneNumber,
    this.photoPath,
    required this.language,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String,
      photoPath: json['photoPath'] as String?,
      language: json['language'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class CompleteRegisterResponse {
  final UserData user;
  final String? accessToken;

  const CompleteRegisterResponse({required this.user, this.accessToken});

  factory CompleteRegisterResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 Complete Register Response JSON: $json');
    final data = json['data'];
    print('🔍 Register data field: $data');
    print('🔍 Register data type: ${data.runtimeType}');

    final Map<String, dynamic> userData = data is Map ? Map<String, dynamic>.from(data) : {};

    return CompleteRegisterResponse(
      user: UserData.fromJson(userData),
      accessToken: userData['accessToken']?.toString(),
    );
  }
}
