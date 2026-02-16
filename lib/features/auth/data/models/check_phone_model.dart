class CheckPhoneResponse {
  final bool exists;

  const CheckPhoneResponse({required this.exists});

  factory CheckPhoneResponse.fromJson(Map<String, dynamic> json) {
    return CheckPhoneResponse(
      exists: json['data']['exists'] as bool,
    );
  }
}
