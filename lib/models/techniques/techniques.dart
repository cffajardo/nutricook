import 'package:freezed_annotation/freezed_annotation.dart';

part 'techniques.freezed.dart';
part 'techniques.g.dart';

@freezed
abstract class Technique with _$Technique {
  const factory Technique({
    required String id,
    required String name,
    String? description,
    @Default(<String>[]) List<String> mediaIDs,
  }) = _Technique;

  factory Technique.fromJson(Map<String, dynamic> json) =>
      _$TechniqueFromJson(json);
}