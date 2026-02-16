class VerifyOtpRequest {
  final String phoneNumber;
  final String code;

  const VerifyOtpRequest({
    required this.phoneNumber,
    required this.code,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'code': code,
      };
}

class VerifyOtpResponse {
  final bool verified;

  const VerifyOtpResponse({required this.verified});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      verified: json['data']['verified'] as bool,
    );
  }
}
