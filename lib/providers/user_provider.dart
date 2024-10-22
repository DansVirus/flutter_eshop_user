import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eshop_user/auth/auth_service.dart';
import 'package:flutter_eshop_user/db/db_helper.dart';
import 'package:flutter_eshop_user/models/app_user_model.dart';

class UserProvider extends ChangeNotifier {
  AppUserModel? appUser;

  /// Adds a new user to the Firestore database by creating an [AppUserModel] instance
  /// from the provided [User] object and optional details like [name], [surname], and [phone].
  ///
  /// The [userCreationTime] is automatically set using the user's account creation time from Firebase.
  /// The constructed [AppUserModel] is then stored in the Firestore using the [DbHelper.addUser] method.
  ///
  /// This method returns a `Future` that completes once the user is successfully added to the database.
  Future<void> addUser(
      {required User user, String? name, String? surname, String? phone}) {
    final appUser = AppUserModel(
      uid: user.uid,
      email: user.email!,
      userName: name,
      userSurname: surname,
      phone: phone,
      userCreationTime: Timestamp.fromDate(user.metadata.creationTime!),
    );
    return DbHelper.addUser(appUser);
  }

  /// Fetches and listens to real-time user information updates for the current user.
  ///
  /// This method listens to Firestore updates for the current authenticated user and
  /// updates the [appUser] property by converting the retrieved data to an [AppUserModel].
  /// Once the user data is updated, it triggers a notification to listeners.
  ///
  /// This method assumes the current user is authenticated, and the user ID is fetched
  /// from [AuthService.currentUser].
  getUserInfo() {
    DbHelper.getUserInfo(AuthService.currentUser!.uid).listen((event) {
      if(event.exists) {
        appUser = AppUserModel.fromJson(event.data()!);
        notifyListeners();
      }
    });
  }

  /// Checks if a user with the given [uid] exists in the database by delegating to [DbHelper].
  ///
  /// This method forwards the request to [DbHelper.doesUserExist] to check if a user
  /// with the specified [uid] exists in Firestore. Returns `true` if the user exists, `false` otherwise.
  Future<bool> doesUserExist(String uid) => DbHelper.doesUserExist(uid);
}
