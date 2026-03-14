class RequestOtpRequest {
  final String phoneNumber;

  const RequestOtpRequest({required this.phoneNumber});

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
      };
}

class RequestOtpResponse {
  final String otpCode;

  const RequestOtpResponse({required this.otpCode});

  factory RequestOtpResponse.fromJson(Map<String, dynamic> json) {
    return RequestOtpResponse(
      otpCode: json['data']['otpCode'] as String,
    );
  }
}
