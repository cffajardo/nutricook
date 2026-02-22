import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/utils/timestamp_convert.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String username,
    required String email,
    @TimestampConverter() required DateTime createdAt,
    String? mediaId,
    @Default(<String>[]) List<String> allergens,

  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
    _$AppUserFromJson(json);

  factory AppUser.fromFirestore(Map<String, dynamic> data) => AppUser.fromJson({
        'id': data['id'] ?? data['uid'],
        'username': data['username'],
        'email': data['email'],
        'createdAt': data['createdAt'] ?? data['creationDate'],
        'mediaId': data['mediaId'] ?? data['profilePictureUrl'],
        'allergens': data['allergens'] ?? [],
      });
}