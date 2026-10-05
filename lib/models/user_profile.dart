class UserMember {
  final String id;
  String name;
  String avatarEmoji;

  UserMember({
    required this.id,
    required this.name,
    this.avatarEmoji = '😊',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarEmoji': avatarEmoji,
      };

  factory UserMember.fromJson(Map<String, dynamic> json) => UserMember(
        id: json['id'],
        name: json['name'],
        avatarEmoji: json['avatarEmoji'] ?? '😊',
      );
}

class UserProfile {
  String name;
  String avatarEmoji;
  bool isLargeText;
  bool notificationsEnabled;
  bool hasCompletedOnboarding;
  List<UserMember> members;

  UserProfile({
    this.name = 'Ee',
    this.avatarEmoji = '😊',
    this.isLargeText = false,
    this.notificationsEnabled = true,
    this.hasCompletedOnboarding = false,
    List<UserMember>? members,
  }) : members = members ?? [UserMember(id: '1', name: 'Ee', avatarEmoji: '😊')];

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatarEmoji': avatarEmoji,
        'isLargeText': isLargeText,
        'notificationsEnabled': notificationsEnabled,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'members': members.map((m) => m.toJson()).toList(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? 'Ee',
        avatarEmoji: json['avatarEmoji'] ?? '😊',
        isLargeText: json['isLargeText'] ?? false,
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
        members: json['members'] != null
            ? (json['members'] as List).map((m) => UserMember.fromJson(m)).toList()
            : [UserMember(id: '1', name: json['name'] ?? 'Ee', avatarEmoji: json['avatarEmoji'] ?? '😊')],
      );
}
