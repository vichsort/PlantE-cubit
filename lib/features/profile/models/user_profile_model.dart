import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String? bio;
  final String? profilePictureUrl;
  final String? country;
  final String? state;
  final String subscriptionStatus;
  final DateTime? subscriptionExpiresAt;
  final int wateringStreak;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.bio,
    this.profilePictureUrl,
    this.country,
    this.state,
    required this.subscriptionStatus,
    this.subscriptionExpiresAt,
    required this.wateringStreak,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      subscriptionStatus: json['subscription_status'] as String,
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
      wateringStreak: json['watering_streak'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    bio,
    profilePictureUrl,
    country,
    state,
    subscriptionStatus,
    subscriptionExpiresAt,
    wateringStreak,
    createdAt,
  ];
}
