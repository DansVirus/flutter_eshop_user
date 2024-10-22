import 'package:flutter/material.dart';
import 'package:flutter_eshop_user/db/db_helper.dart';
import 'package:flutter_eshop_user/models/app_user_model.dart';
import 'package:flutter_eshop_user/models/rating_model.dart';
import 'package:flutter_eshop_user/models/telescope_model.dart';

import '../models/brand_model.dart';


/// Provider class that manages a list of brands and interacts with Firestore.
///
/// Uses [ChangeNotifier] to notify listeners of updates to the brand list.
class TelescopeProvider extends ChangeNotifier {

  /// A list of [BrandModel] objects representing all the brands.
  List<BrandModel> brandList = [];

  // As above so below
  List<TelescopeModel> telescopeList = [];


  /// Subscribes to real-time updates from the Firestore `Brands` collection.
  ///
  /// Updates [brandList] with the latest data and notifies listeners.
  void getAllBrands() {
    DbHelper.getAllBrands().listen((snapshot) {
      brandList = List.generate(snapshot.docs.length, (index) => BrandModel.fromJson(snapshot.docs[index].data()));
      notifyListeners();
    });
  }

  // As above so below
  void getAllTelescopes() {
    DbHelper.getAllTelescopes().listen((snapshot) {
      telescopeList = List.generate(snapshot.docs.length, (index) => TelescopeModel.fromJson(snapshot.docs[index].data()));
      notifyListeners();
    });
  }

  /// Finds and returns a [TelescopeModel] from the list by its [id].
  ///
  /// Throws a [StateError] if no telescope with the given [id] is found.
  TelescopeModel findTelescopeById(String id) =>
      telescopeList.firstWhere((element) => element.id == id);

  /// Adds a user rating for a specific telescope and updates the average rating.
  ///
  /// This method adds a new rating for a telescope by creating a `RatingModel` instance
  /// from the user's rating and saving it to Firestore. After the new rating is added,
  /// it fetches all existing ratings for the telescope, calculates the updated average
  /// rating, and then updates the telescope's `avgRating` field.
  ///
  /// - Parameters:
  ///   - `id`: The unique identifier of the telescope being rated.
  ///   - `appUser`: The user providing the rating, represented by an `AppUserModel`.
  ///   - `rating`: The numeric rating provided by the user.
  ///
  /// - Returns: A `Future<void>` that completes when the rating is added and the average
  ///   rating for the telescope has been updated in Firestore.
  ///
  /// ### Steps:
  /// 1. A `RatingModel` is created using the `appUser` and `rating`.
  /// 2. The rating is saved in Firestore under the telescope's rating collection.
  /// 3. The method retrieves all ratings for the telescope.
  /// 4. The average rating is calculated by summing all ratings and dividing by the total number of ratings.
  /// 5. The telescope's document is updated with the new `avgRating`.
  Future<void> addRating(String id, AppUserModel appUser, num rating) async  {
    final ratingModel = RatingModel(appUser: appUser, rating: rating);
    await DbHelper.addRating(id, ratingModel);
    final snapshot = await DbHelper.getAllRatings(id);
    final List<RatingModel> ratingList = List.generate(snapshot.docs.length, (index) => RatingModel.fromJson(snapshot.docs[index].data()));
    num total = 0;
    for(final rating in ratingList) {
      total += rating.rating;
    }
    final avgRating = total / ratingList.length;
    return DbHelper.updateTelescopeField(id, {'avgRating' : avgRating});
  }

}
