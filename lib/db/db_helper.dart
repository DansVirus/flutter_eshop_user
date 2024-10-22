import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_eshop_user/models/app_user_model.dart';
import 'package:flutter_eshop_user/models/cart_model.dart';
import 'package:flutter_eshop_user/models/order_model.dart';
import 'package:flutter_eshop_user/models/rating_model.dart';

class DbHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String collectionUser = 'Users';
  static const String collectionTelescope = 'Telescopes';
  static const String collectionBrand = 'Brands';
  static const String collectionCart = 'CartItems';
  static const String collectionOrder = 'Orders';
  static const String collectionRating = 'Ratings';

  /// Adds a new user to the Firestore database by storing the [AppUserModel] instance.
  ///
  /// The user data is stored in the `collectionUser` collection, using the user's `uid` as the document ID.
  /// The [appUser] object is converted to JSON using the `toJson` method before being saved.
  ///
  /// This method returns a `Future` that completes once the operation is finished.
  static Future<void> addUser(AppUserModel appUser) {
    return _db.collection(collectionUser)
        .doc(appUser.uid)
        .set(appUser.toJson());
  }

  /// Adds a [CartModel] to the user's cart in Firestore.
  ///
  /// This method stores the given [cartModel] in the cart collection for the user
  /// identified by [uid]. The document ID is set to the telescope's ID for easy retrieval.
  ///
  /// The cart model is converted to a JSON format before being saved.
  static Future<void> addToCart(CartModel cartModel, String uid) {
    return _db
        .collection(collectionUser)
        .doc(uid)
        .collection(collectionCart)
        .doc(cartModel.telescopeId)
        .set(cartModel.toJson());
  }

  /// Removes a telescope from the user's cart in Firestore.
  ///
  /// This method deletes the document associated with the given [telescopeId]
  /// from the user's cart collection, identified by [uid].
  ///
  /// If the document doesn't exist, nothing happens.
  static Future<void> removeFromCart(String telescopeId, String uid) {
    return _db
        .collection(collectionUser)
        .doc(uid)
        .collection(collectionCart)
        .doc(telescopeId)
        .delete();
  }

  /// Retrieves a stream of all cart items for a given user.
  ///
  /// Returns a [Stream] of [QuerySnapshot] containing all cart items from the
  /// Firestore cart collection for the user identified by [uid].
  ///
  /// The stream automatically updates as items are added or removed from the user's cart.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCartItems(String uid) =>
      _db.collection(collectionUser).doc(uid)
      .collection(collectionCart).snapshots();

  /// Returns a stream of snapshots from the Firestore `Brands` collection.
  ///
  /// The stream emits updates whenever a change occurs in the `Brands` collection.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllBrands() =>
      _db.collection(collectionBrand).snapshots();

  /// Returns a stream of snapshots from the Firestore `Telescopes` collection.
  ///
  /// The stream emits updates whenever a change occurs in the `Telescopes` collection.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllTelescopes() =>
      _db.collection(collectionTelescope).snapshots();

  /// Retrieves all ratings for a specific telescope from the database.
  ///
  /// This method queries the Firestore database to fetch all documents in the
  /// `collectionRating` subcollection of a specific telescope document, identified by its `id`.
  /// The returned data includes all the user ratings associated with the specified telescope.
  ///
  /// - Parameters:
  ///   - `id`: The unique identifier of the telescope for which to fetch ratings.
  ///
  /// - Returns:
  ///   - A `Future` that resolves to a `QuerySnapshot` containing a list of rating documents, each represented as a `Map<String, dynamic>`.
  ///
  /// Example usage:
  /// ```
  /// final ratings = await DbHelper.getAllRatings(telescopeId);
  /// for (var doc in ratings.docs) {
  ///   print(doc.data()); // Prints the rating data for each rating document.
  /// }
  /// ```
  ///
  /// - Note: If no ratings exist for the telescope, the returned `QuerySnapshot` will be empty.
  static Future<QuerySnapshot<Map<String, dynamic>>> getAllRatings(String id) =>
      _db.collection(collectionTelescope)
      .doc(id)
      .collection(collectionRating)
      .get();

  /// Returns a stream of user information for the specified user ID.
  ///
  /// This method listens to real-time updates from Firestore, returning a [Stream] of
  /// [DocumentSnapshot] containing the user data in a `Map<String, dynamic>`.
  ///
  /// The [uid] parameter is the user ID for which the information is being fetched.
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(String uid) =>
      _db.collection(collectionUser).doc(uid).snapshots();

  /// Checks if a user with the given [uid] exists in the database.
  ///
  /// This method queries the user collection in Firestore to determine if a document
  /// with the specified [uid] exists. Returns `true` if the user exists, `false` otherwise.
  static Future<bool> doesUserExist(String uid) async {
    final snapshot = await _db.collection(collectionUser).doc(uid).get();
    return snapshot.exists;
    }

  /// Updates the quantity of a specific item in the user's cart.
  ///
  /// This method updates the cart entry for the specified [CartModel] in the Firestore
  /// cart collection for the user identified by [uid]. The entire cart model, including
  /// any changes in quantity, is saved.
  ///
  /// The [model] parameter contains the updated information for the cart item.
  static Future<void> updateCartQuantity(String uid, CartModel model) {
    return _db
        .collection(collectionUser)
        .doc(uid)
        .collection(collectionCart)
        .doc(model.telescopeId)
        .set(model.toJson());
  }

  /// Saves an order to Firestore and updates the stock of the ordered items.
  ///
  /// This method performs a batch operation to:
  /// 1. Save the order details to the `collectionOrder`.
  /// 2. Update the stock of each ordered item in the `collectionTelescope` based on the quantity purchased.
  /// 3. Update the user's information in the `collectionUser`.
  ///
  /// The method utilizes Firestore's batch functionality to ensure all writes succeed or fail together.
  ///
  /// - Parameters:
  ///   - order: The `OrderModel` object containing the order and user information.
  ///
  /// - Returns: A `Future` that completes when the order and updates are saved to Firestore.
  ///
  /// - Note: The `.batch()` method allows grouping multiple Firestore operations (set, update, delete)
  ///   into a single transaction, which only commits when all operations succeed.
  ///   The `.commit()` method executes the batch, writing all operations to Firestore in a single call.
  ///   This ensures atomicity, meaning either all updates succeed or none of them are applied.
  static Future<void> saveOrder(OrderModel order) async {
    final wb = _db.batch();
    final orderDoc = _db.collection(collectionOrder).doc(order.orderId);
    wb.set(orderDoc, order.toJson());
    for(final cartModel in order.itemDetails) {
      final telSnap = await _db.collection(collectionTelescope)
          .doc(cartModel.telescopeId)
          .get();
      final prevStock = telSnap.data()!['stock'];
      final telDoc = _db.collection(collectionTelescope).doc(cartModel.telescopeId);
      wb.update(telDoc, {'stock' : prevStock - cartModel.quantity});
    }
    final userDoc = _db.collection(collectionUser).doc(order.appUser.uid);
    wb.set(userDoc, order.appUser.toJson());
    return wb.commit();
  }

  /// Clears the user's cart by deleting all items in the cart from Firestore using a batch operation.
  ///
  /// This method creates a Firestore batch using `_db.batch()`. A batch allows for multiple
  /// read and write operations to be performed atomically. All deletions are grouped together
  /// and executed at once.
  ///
  /// - [uid]: The user's unique ID.
  /// - [cartList]: A list of cart items to be removed from the user's cart.
  ///
  /// ### Firestore Batch:
  /// - `.batch()`: Initiates a Firestore batch. A batch groups multiple Firestore operations
  ///   (such as write, update, and delete) to be executed together atomically. None of the
  ///   operations are applied until the batch is committed.
  /// - `.delete(doc)`: Schedules a deletion of a document (here, based on the cart item ID).
  ///
  /// ### Committing the Batch:
  /// - `.commit()`: Applies all the batched operations in a single transaction. If any of the
  ///   operations fail, none of the changes are committed, ensuring atomicity.
  static Future<void> clearCart(String uid, List<CartModel> cartList) {
    final wb = _db.batch();
    for(final model in cartList) {
      final doc = _db
          .collection(collectionUser)
          .doc(uid)
          .collection(collectionCart)
          .doc(model.telescopeId);
      wb.delete(doc);
    }
    return wb.commit();
  }

  /// Updates specific fields of a telescope document in Firestore.
  ///
  /// - Parameters:
  ///   - `id`: The unique ID of the telescope document.
  ///   - `map`: A map of field names and their updated values.
  ///
  /// - Returns: A `Future` that completes when the update is successful.
  static Future<void> updateTelescopeField(String id, Map<String, dynamic> map) {
    return _db.collection(collectionTelescope).doc(id).update(map);
  }

  /// Adds a user's rating for a specific telescope in Firestore.
  ///
  /// This method saves a user's rating for a given telescope by creating a document
  /// under the telescope's rating collection in Firestore. The document is identified
  /// by the user's unique ID and stores the rating data as provided in the `RatingModel`.
  ///
  /// - Parameters:
  ///   - `id`: The unique identifier of the telescope being rated.
  ///   - `ratingModel`: An instance of `RatingModel` containing the rating details (user info and rating).
  ///
  /// - Returns: A `Future<void>` that completes when the rating is saved to Firestore.
  ///
  /// ### Process:
  /// 1. A new document is created under the specified telescope's rating collection.
  /// 2. The document ID is set as the user's UID from the `RatingModel`.
  /// 3. The rating data is serialized to JSON format and saved in the document.
  static Future<void> addRating(String id, RatingModel ratingModel) {
    return _db.collection(collectionTelescope)
        .doc(id)
        .collection(collectionRating)
        .doc(ratingModel.appUser.uid)
        .set(ratingModel.toJson());
  }
}