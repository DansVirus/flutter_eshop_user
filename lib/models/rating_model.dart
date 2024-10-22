import 'package:flutter_eshop_user/models/app_user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'rating_model.freezed.dart';
part 'rating_model.g.dart';

@unfreezed
class RatingModel with _$RatingModel {
  @JsonSerializable(explicitToJson: true)
  factory RatingModel ({
    required AppUserModel appUser,
    required num rating,
}) = _RatingModel;

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);
}