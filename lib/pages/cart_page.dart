import 'package:flutter/material.dart';
import 'package:flutter_eshop_user/main.dart';
import 'package:flutter_eshop_user/pages/check_out_page.dart';
import 'package:flutter_eshop_user/providers/cart_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_eshop_user/widgets/cart_item_view.dart';

import '../utils/constants.dart';

class CartPage extends StatefulWidget {
  static const String routeName = 'cartpage';

  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) =>
            Column(
              children: [Expanded(
                child: ListView.builder(
                    itemCount: provider.cartList.length,
                    itemBuilder: (context, index) {
                      final model = provider.cartList[index];
                      return CartItemView(cartModel: model, provider: provider);
                    },
                ),
              ),
                Card(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                                'SUBTOTAL: ${provider.getCartSubtotal()}$currencySymbol',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                          ),
                          OutlinedButton(onPressed: provider.totalItemInCart == 0 ? null :  () {
                                 context.goNamed(CheckOutPage.routeName);
                          },
                              child: const Text('CHECKOUT'))
                        ],
                      ),
                  ),
                )
              ],
            ),
      ),
    );
  }
}
