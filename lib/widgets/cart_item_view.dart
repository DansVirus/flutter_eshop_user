import 'package:flutter/material.dart';
import 'package:flutter_eshop_user/models/cart_model.dart';
import 'package:flutter_eshop_user/providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_eshop_user/utils/constants.dart';

class CartItemView extends StatelessWidget {
  final CartModel cartModel;
  final CartProvider provider;
  const CartItemView({
    super.key,
    required this.cartModel,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: CachedNetworkImage(
                width: 70,
                height: 70,
                imageUrl: cartModel.imageUrl,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              title: Text(cartModel.telescopeModel),
              subtitle: Text('Unit Price: $currencySymbol${cartModel.price}'),
              trailing: TextButton.icon(
                onPressed: () {
                  provider.removeFromCart(cartModel.telescopeId);
                },
                icon: const Icon(Icons.delete), label: Text('Remove\nfrom Cart'),
              ),
            ),
            Row(
              children: [
                IconButton(onPressed: () {
                  provider.decreaseQuantity(cartModel);
                }, icon: const Icon(Icons.remove_circle, size: 25,),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '${cartModel.quantity}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(onPressed: () {
                    provider.increaseQuantity(cartModel);
                }, icon: const Icon(Icons.add_circle, size: 25,),
                ),
                const Spacer(),
                Text('${provider.priceWithQuantity(cartModel)}$currencySymbol', style: Theme.of(context).textTheme.titleLarge,)
              ],
            )
          ],
        ),
      ),
    );
  }
}
