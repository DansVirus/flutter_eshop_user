import 'package:flutter/material.dart';
import 'package:flutter_eshop_user/providers/cart_provider.dart';
// import 'package:flutter_eshop_user/pages/telescope_details_page.dart';
import 'package:flutter_eshop_user/providers/telescope_provider.dart';
import 'package:flutter_eshop_user/providers/user_provider.dart';
import 'package:flutter_eshop_user/widgets/main_drawer.dart';
import 'package:flutter_eshop_user/widgets/telescope_grid_item_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


import '../auth/auth_service.dart';
import 'login_page.dart';

class ViewTelescopePage extends StatefulWidget {
  static const String routeName = '/viewtelescope';

  const ViewTelescopePage({super.key});

  @override
  State<ViewTelescopePage> createState() => _ViewTelescopePageState();
}

class _ViewTelescopePageState extends State<ViewTelescopePage> {


  @override
  void didChangeDependencies() {
    Provider.of<TelescopeProvider>(context, listen: false).getAllBrands();
    Provider.of<TelescopeProvider>(context, listen: false).getAllTelescopes();
    Provider.of<CartProvider>(context, listen: false).getAllCartItems();
    Provider.of<UserProvider>(context, listen: false).getUserInfo();
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text('Telescopes'),
      ),
      body: Consumer<TelescopeProvider>(
        builder: (context, provider, child) => GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
          ),
          itemCount: provider.telescopeList.length,
          itemBuilder: (context, index) {
            final telescope = provider.telescopeList[index];
            return TelescopeGridItemView(telescope: telescope);

          },
        ),
      ),
    );
  }
}
