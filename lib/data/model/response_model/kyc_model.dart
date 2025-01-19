class VerificationModel {
  final int id;
  final String name;
  final String slug;
  final Map<String, InputField> inputForm;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  VerificationModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.inputForm,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    return VerificationModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      inputForm: (json['input_form'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, InputField.fromJson(value)),
      ),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class InputField {
  final String fieldName;
  final String fieldLabel;
  final String type;
  final String validation;

  InputField({
    required this.fieldName,
    required this.fieldLabel,
    required this.type,
    required this.validation,
  });

  factory InputField.fromJson(Map<String, dynamic> json) {
    return InputField(
      fieldName: json['field_name'],
      fieldLabel: json['field_label'],
      type: json['type'],
      validation: json['validation'],
    );
  }
}

class KycResponse {
  final String status;
  final List<KycData> data;

  KycResponse({required this.status, required this.data});

  factory KycResponse.fromJson(Map<String, dynamic> json) {
    return KycResponse(
      status: json['status'],
      data: List<KycData>.from(json['data'].map((x) => KycData.fromJson(x))),
    );
  }
}

class KycData {
  final int id;
  final int kycId;
  final String kycType;
  final Map<String, KycInfo> kycInfo;
  final int status;
  final dynamic reason;
  final String createdAt;
  final String updatedAt;

  KycData({
    required this.id,
    required this.kycId,
    required this.kycType,
    required this.kycInfo,
    required this.status,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KycData.fromJson(Map<String, dynamic> json) {
    return KycData(
      id: json['id'],
      kycId: json['kyc_id'],
      kycType: json['kyc_type'],
      kycInfo: (json['kyc_info'] as Map<String, dynamic>).map((k, v) => MapEntry(k, KycInfo.fromJson(v))),
      status: json['status'],
      reason: json['reason'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class KycInfo {
  final String fieldName;
  final String fieldLabel;
  final String fieldValue;
  final String type;

  KycInfo({
    required this.fieldName,
    required this.fieldLabel,
    required this.fieldValue,
    required this.type,
  });

  factory KycInfo.fromJson(Map<String, dynamic> json) {
    return KycInfo(
      fieldName: json['field_name'],
      fieldLabel: json['field_label'],
      fieldValue: json['field_value'],
      type: json['type'],
    );
  }
}
