import 'package:freezed_annotation/freezed_annotation.dart';

part 'unit.freezed.dart';
part 'unit.g.dart';

@freezed
abstract class Unit with _$Unit {
  const factory Unit({
    required String id,
    required String name,
    String? description,
    required double multiplier,
    required String type,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) =>
      _$UnitFromJson(json);
}