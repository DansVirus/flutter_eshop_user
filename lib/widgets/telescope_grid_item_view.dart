import 'package:flutter/material.dart';
import 'package:flutter_eshop_user/models/telescope_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_eshop_user/utils/constants.dart';
import 'package:flutter_eshop_user/utils/helper_functions.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../pages/telescope_details_page.dart';

class TelescopeGridItemView extends StatelessWidget {
  final TelescopeModel telescope;

  const TelescopeGridItemView({
    super.key,
    required this.telescope,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.goNamed(TelescopeDetailsPage.routeName, extra: telescope.id);
      },
      child: Card(
        child: Stack(children: [
          Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: telescope.thumbnail.downloadUrl,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              Text(
                telescope.model,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
              if (telescope.discount > 0)
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: RichText(
                    text: TextSpan(
                      text:
                          '$currencySymbol${priceAfterDiscount(telescope.price, telescope.discount)}',
                      style: const TextStyle(fontSize: 20, color: Colors.green),
                      children: [
                        TextSpan(
                          text: ' $currencySymbol${telescope.price}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (telescope.discount == 0)
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    '$currencySymbol${telescope.price}',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(telescope.avgRating.toStringAsFixed(1)),
                    const SizedBox(
                      width: 5,
                    ),
                    //RatingBar L.196
                    RatingBar.builder(
                      initialRating: telescope.avgRating.toDouble(),
                      minRating: 0.0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      ignoreGestures: true,
                      itemSize: 20,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber,),
                      onRatingUpdate: (rating) {
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
          if(telescope.discount > 0)
            Positioned(
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(4.0),
                  child: Text('${telescope.discount}% OFF',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ))
        ]),
      ),
    );
  }
}
