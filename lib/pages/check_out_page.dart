import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_eshop_user/models/order_model.dart';
import 'package:flutter_eshop_user/models/user_address_model.dart';
import 'package:flutter_eshop_user/pages/view_telescope_page.dart';
import 'package:flutter_eshop_user/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class CheckOutPage extends StatefulWidget {
  static const String routeName = 'checkout';

  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  String paymentMethodGroupValue = PaymentMethod.cod;
  String? city;
  final addressController = TextEditingController();
  final postalCodeController = TextEditingController();

  @override
  void didChangeDependencies() {
    _setAddress();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                buildHeaderSection('Product Information'),
                buildProductInfoSection(),
                buildTotalAmountSection(),
                buildHeaderSection('Delivery Address'),
                buildDeliveryAddressSection(),
                buildHeaderSection('Payment Method'),
                buildPaymentMethodSection(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: _saveOrder,
              style: ElevatedButton.styleFrom(
                  backgroundColor: kShrineBrown900,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              child: const Text('PLACE ORDER'),
            ),
          )
        ],
      ),
    );
  }

  Widget buildHeaderSection(String title) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget buildProductInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Consumer<CartProvider>(
          builder: (context, provider, child) => Column(
            children: provider.cartList
                .map((cartModel) => ListTile(
                      title: Text(cartModel.telescopeModel),
                      trailing: Text(
                        '${cartModel.quantity}x$currencySymbol${cartModel.price}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget buildTotalAmountSection() {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        title: const Text('Total Amount'),
        trailing: Consumer<CartProvider>(
          builder: (context, provider, child) => Text(
            '$currencySymbol${provider.getCartSubtotal()}',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
    ));
  }

  Widget buildDeliveryAddressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                hintText: 'Street Address',
              ),
            ),
            TextField(
              controller: postalCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Zip Code',
              ),
            ),
            DropdownButton<String>(
              value: city,
              hint: const Text('Select your city'),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  city = value;
                });
              },
              items: cities
                  .map((city) => DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentMethodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Radio<String>(
              value: PaymentMethod.cod,
              groupValue: paymentMethodGroupValue,
              onChanged: (value) {
                setState(() {
                  paymentMethodGroupValue = value!;
                });
              },
            ),
            const Text(PaymentMethod.cod),
            Radio<String>(
              value: PaymentMethod.online,
              groupValue: paymentMethodGroupValue,
              onChanged: (value) {
                setState(() {
                  paymentMethodGroupValue = value!;
                });
              },
            ),
            const Text(PaymentMethod.online),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  /// Validates the user's address and postal code, generates an order, and saves it to Firestore.
  ///
  /// This method performs the following steps:
  /// 1. Validates that the user's address, postal code, and city have been provided.
  /// 2. Shows a loading indicator while processing the order.
  /// 3. Creates a `UserAddressModel` using the user's input and assigns it to the current user.
  /// 4. Constructs an `OrderModel` using the user's information, selected payment method, and the current cart items.
  /// 5. Saves the order to Firestore via the `OrderProvider`.
  /// 6. Clears the cart upon successful order placement.
  /// 7. Dismisses the loading indicator and navigates the user to the `ViewTelescopePage` after the order is placed.
  ///
  /// - Note: If the user fails to provide the necessary address details, error messages are displayed and the process is halted.
  /// - Parameters:
  ///   - None, but relies on the current user, cart, and address fields from the context.
  ///
  /// - Returns: This is an `async` method, but does not return any value. It updates the UI and performs database operations.
  ///
  /// - Exception Handling: If an error occurs during the order saving process, it catches the error and dismisses the loading screen.
  void _saveOrder() async {
    if (addressController.text.isEmpty) {
      showMsg(context, 'Please provide your address');
      return;
    }
    if (postalCodeController.text.isEmpty) {
      showMsg(context, 'Please provide your zip code');
      return;
    }
    if (city == null) {
      showMsg(context, 'Please select your city');
      return;
    }

    EasyLoading.show(status: 'Please wait..');

    final userAddress = UserAddressModel(
      streetAddress: addressController.text,
      city: city!,
      postCode: postalCodeController.text,
    );

    final appUser = Provider.of<UserProvider>(context, listen: false).appUser;
    appUser!.userAddress = userAddress;

    final order = OrderModel(
      orderId: generateOrderId,
      appUser: appUser,
      orderStatus: OrderStatus.pending,
      paymentMethod: paymentMethodGroupValue,
      totalAmount:
          Provider.of<CartProvider>(context, listen: false).getCartSubtotal(),
      orderDate: Timestamp.fromDate(DateTime.now()),
      itemDetails: Provider.of<CartProvider>(context, listen: false).cartList,
    );

    try {
      await Provider.of<OrderProvider>(context, listen: false)
          .saveOrder(order);
      await Provider.of<CartProvider>(context, listen: false)
          .clearCart();
      EasyLoading.dismiss();
      if (mounted) {
        showMsg(context, 'Order Placed');
        context.goNamed(ViewTelescopePage.routeName);
      }
    } catch(error) {
      EasyLoading.dismiss();
    }
  }

  /// Populates the address fields with the user's saved address, if available.
  ///
  /// This method checks if the current user and their associated address exist in the
  /// `UserProvider`. If so, it populates the following input fields:
  /// - `addressController`: Set to the user's saved street address.
  /// - `postalCodeController`: Set to the user's saved postal code.
  /// - `city`: Set to the user's saved city.
  ///
  /// - Note: If the user or the address is `null`, the method does nothing and leaves the fields unchanged.
  ///
  /// - Parameters:
  ///   - None, but it relies on `UserProvider` for accessing the user's address details.
  ///
  /// - Returns: This method does not return anything. It updates the input fields.
  ///
  /// Example usage:
  /// ```
  /// _setAddress(); // Call this function to prefill the address fields if the user has saved address data.
  /// ```
  void _setAddress() {
    final appUser = Provider.of<UserProvider>(context, listen: false).appUser;
    if(appUser != null && appUser.userAddress != null) {
      final address = appUser.userAddress!;
      addressController.text = address.streetAddress;
      postalCodeController.text = address.postCode;
      city = address.city;
    }
  }
}
