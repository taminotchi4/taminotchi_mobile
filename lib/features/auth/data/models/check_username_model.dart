class CheckUsernameResponse {
  final bool exists;

  const CheckUsernameResponse({required this.exists});

  factory CheckUsernameResponse.fromJson(Map<String, dynamic> json) {
    return CheckUsernameResponse(
      exists: json['data']['exists'] as bool,
    );
  }
}
