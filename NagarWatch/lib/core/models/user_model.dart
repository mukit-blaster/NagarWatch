class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 'citizen' | 'authority' | 'admin'
  final String? wardId;
  final String? wardName;
  final String? token;
  final String? approvalStatus; // 'pending_approval' | 'approved' | null

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'citizen',
    this.wardId,
    this.wardName,
    this.token,
    this.approvalStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString(),
    role: json['role']?.toString() ?? 'citizen',
    wardId: json['wardId']?.toString(),
    wardName: json['wardName']?.toString(),
    token: json['token']?.toString(),
    approvalStatus: json['approvalStatus']?.toString() ?? json['status']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'wardId': wardId,
    'wardName': wardName,
    'approvalStatus': approvalStatus,
  };

  UserModel copyWith({String? wardId, String? wardName, String? token, String? approvalStatus}) => UserModel(
    id: id, name: name, email: email, phone: phone, role: role,
    wardId: wardId ?? this.wardId,
    wardName: wardName ?? this.wardName,
    token: token ?? this.token,
    approvalStatus: approvalStatus ?? this.approvalStatus,
  );
}
