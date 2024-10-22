import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_eshop_user/model_converters/timestamp_converter.dart';
import 'package:flutter_eshop_user/models/user_address_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'app_user_model.freezed.dart';
part 'app_user_model.g.dart';

/// Represents a user in the application, storing essential information such as user ID, email,
/// and optional details like username, phone number, and address.
///
/// This model is designed to work with Firebase and Firestore. The `uid` and `email` are required
/// fields, as they are critical for Firebase Authentication. Optional fields include the user's
/// address ([userAddress]), name ([userName]), surname ([userSurname]), and phone number ([phone]).
///
/// ### Special Handling of `UserAddressModel` and `Timestamp`
///
/// - **UserAddressModel**: This is a custom-defined model. To handle its conversion to and from
///   JSON, the `explicitToJson` flag is set to true, ensuring that its `toJson` method is explicitly
///   called when serializing this field.
///
/// - **Timestamp**: Unlike `UserAddressModel`, `Timestamp` comes from Firebase's Firestore API and
///   doesn't have built-in `toJson` or `fromJson` methods. To address this, the custom
///   [TimestampConverter] is used.We say to Freezed library with the implementation of timestamp_converter
///   to allow Firestore's `Timestamp` to be directly stored and retrieved, as Firebase recognizes
///   `Timestamp` natively without needing manual conversion.
///
/// The [userCreationTime] field stores the time when the user was created, useful for tracking
/// account creation and last login times. This field utilizes the custom converter for seamless
/// integration with Firestore.
///
/// The model is annotated with `freezed` and `JsonSerializable` for immutability and easy JSON
/// serialization, supporting nested objects like [UserAddressModel].
@unfreezed
class AppUserModel with _$AppUserModel {
  @JsonSerializable(explicitToJson: true)
  factory AppUserModel({
    required String uid,
    required String email,
    UserAddressModel? userAddress,
    String? userName,
    String? userSurname,
    String? phone,
    @TimestampConverter() Timestamp? userCreationTime,
}) = _AppUserModel;

  factory AppUserModel.fromJson(Map<String, dynamic> json) =>
      _$AppUserModelFromJson(json);
}