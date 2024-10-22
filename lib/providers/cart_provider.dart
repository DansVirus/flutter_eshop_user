import 'package:flutter/material.dart';
import 'package:flutter_eshop_user/auth/auth_service.dart';
import 'package:flutter_eshop_user/db/db_helper.dart';
import 'package:flutter_eshop_user/models/cart_model.dart';
import 'package:flutter_eshop_user/models/telescope_model.dart';
import 'package:flutter_eshop_user/utils/helper_functions.dart';

class CartProvider with ChangeNotifier {
  List<CartModel> cartList = [];

  /// A getter that helps to add/remove functionality from the CHECKOUT button in cart_page.
  int get totalItemInCart => cartList.length;

  /// Subscribes to real-time updates from the Firestore `CartItems` collection.
  ///
  /// Updates [cartList] with the latest data and notifies listeners.
  void getAllCartItems() {
    DbHelper.getAllCartItems(AuthService.currentUser!.uid).listen((snapshot) {
      cartList = List.generate(snapshot.docs.length, (index) => CartModel.fromJson(snapshot.docs[index].data()));
      notifyListeners();
    });
  }

  /// Checks if a telescope with the given [id] exists in the cart.
  ///
  /// This method iterates over the [cartList] to check if any item in the cart has a matching
  /// telescope ID. Returns `true` if the telescope is found, `false` otherwise.
  bool isTelescopeInCart(String id) {
    bool tag = false;
    for (final cartModel in cartList) {
      if (cartModel.telescopeId == id) {
        tag = true;
        break;
      }
    }
    return tag;
  }

  /// Adds a telescope to the user's cart in Firestore.
  ///
  /// Converts a [TelescopeModel] into a [CartModel] and stores it in the current user's
  /// cart collection in Firestore. The price is calculated using any available discount.
  ///
  /// Throws an error if the user is not authenticated.
  Future<void> addToCart(TelescopeModel telescope) {
    final cartModel = CartModel(
      telescopeId: telescope.id!,
      telescopeModel: telescope.model,
      price: priceAfterDiscount(telescope.price, telescope.discount),
      imageUrl: telescope.thumbnail.downloadUrl,
    );
    return DbHelper.addToCart(cartModel, AuthService.currentUser!.uid);
  }

  /// Removes a telescope from the user's cart in Firestore.
  ///
  /// Deletes the document with the given [id] from the current user's cart
  /// collection in Firestore.
  ///
  /// Throws an error if the user is not authenticated.
  Future<void> removeFromCart(String id) {
    return DbHelper.removeFromCart(id, AuthService.currentUser!.uid);
  }

  /// Increases the quantity of the specified cart item by 1.
  ///
  /// This method increments the [model]'s quantity and updates the cart in the Firestore
  /// for the currently logged-in user.
  ///
  /// The [model] parameter is the cart item to be updated.
  void increaseQuantity(CartModel model) {
    model.quantity += 1;
    DbHelper.updateCartQuantity(AuthService.currentUser!.uid, model);
  }

  /// Decreases the quantity of the specified cart item by 1, if the quantity is greater than 1.
  ///
  /// This method decrements the [model]'s quantity and updates the cart in the Firestore
  /// for the currently logged-in user. It prevents the quantity from going below 1.
  ///
  /// The [model] parameter is the cart item to be updated.
  void decreaseQuantity(CartModel model) {
    if(model.quantity > 1) {
      model.quantity -= 1;
      DbHelper.updateCartQuantity(AuthService.currentUser!.uid, model);
    }
  }

  num priceWithQuantity(CartModel model) => model.price * model.quantity;

  num getCartSubtotal() {
    num total = 0;
    for(final model in cartList) {
      total += priceWithQuantity(model);
    }
    return total;
  }

  /// Clears the current user's cart by removing all items using a batch operation.
  ///
  /// This method delegates the task to `DbHelper.clearCart`, which removes all items from
  /// the user's cart stored in Firestore. The user's unique ID and the current cart list are
  /// passed to the database helper for batch deletion.
  ///
  /// - Returns: A `Future` that completes when the cart is cleared from Firestore.
  Future<void> clearCart() => DbHelper.clearCart(AuthService.currentUser!.uid, cartList);
}
