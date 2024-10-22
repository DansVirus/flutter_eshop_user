import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_eshop_user/models/telescope_model.dart';
import 'package:flutter_eshop_user/providers/telescope_provider.dart';
import 'package:flutter_eshop_user/providers/user_provider.dart';
import 'package:flutter_eshop_user/utils/colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';
import '../widgets/main_drawer.dart';

class TelescopeDetailsPage extends StatefulWidget {
  static const String routeName = 'productdetails';
  final String id;

  const TelescopeDetailsPage({super.key, required this.id});

  @override
  State<TelescopeDetailsPage> createState() => _TelescopeDetailsPageState();
}

class _TelescopeDetailsPageState extends State<TelescopeDetailsPage> {
  late TelescopeModel telescope;
  late TelescopeProvider provider;
  double userRating = 0.0;

  @override
  void didChangeDependencies() {
    provider = Provider.of<TelescopeProvider>(context);
    telescope = provider.findTelescopeById(widget.id);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: Text(
          telescope.model,
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
      ),
      body: ListView(
        children: [
          CachedNetworkImage(
            width: double.infinity,
            height: 200,
            imageUrl: telescope.thumbnail.downloadUrl,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Consumer<CartProvider>(
              builder: (context, provider, child) {
                final isInCart = provider.isTelescopeInCart(telescope.id!);
                return ElevatedButton.icon(
                  onPressed: () {
                    if (isInCart) {
                      provider.removeFromCart(telescope.id!);
                    } else {
                      provider.addToCart(telescope);
                    }
                  },
                  icon: Icon(isInCart
                      ? Icons.remove_shopping_cart
                      : Icons.shopping_cart),
                  label: Text(isInCart ? 'Remove from Cart' : 'Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isInCart ? kShrineBrown900 : kShrinePink400,
                    foregroundColor: isInCart ? kShrinePink100 : kShrinePink50,
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: Text(
              'Sale Price: $currencySymbol${priceAfterDiscount(telescope.price, telescope.discount).toStringAsFixed(0)}',
            ),
            subtitle: Text('Stock: ${telescope.stock}'),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  RatingBar.builder(
                    initialRating: telescope.avgRating.toDouble(),
                    minRating: 0.0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemSize: 20,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      userRating = rating;
                    },
                  ),
                  OutlinedButton(
                    onPressed: _rateThisProduct,
                    child: const Text('RATE'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _rateThisProduct() async {
    EasyLoading.show(status: 'Please wait');
    final appUser = Provider.of<UserProvider>(context, listen: false).appUser;
    await provider.addRating(telescope.id!, appUser!, userRating);
    EasyLoading.dismiss();
    if(mounted) {
      showMsg(context, 'Thanks for your rating');
    }
    userRating = 0.0;
  }
}
