import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_eshop_user/pages/cart_page.dart';
import 'package:flutter_eshop_user/pages/check_out_page.dart';
import 'package:flutter_eshop_user/pages/login_page.dart';
import 'package:flutter_eshop_user/pages/telescope_details_page.dart';
import 'package:flutter_eshop_user/pages/view_telescope_page.dart';
import 'package:flutter_eshop_user/providers/cart_provider.dart';
import 'package:flutter_eshop_user/providers/order_provider.dart';
import 'package:flutter_eshop_user/providers/telescope_provider.dart';
import 'package:flutter_eshop_user/providers/user_provider.dart';
import 'package:flutter_eshop_user/utils/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserProvider()),
    ChangeNotifierProvider(create: (context) => TelescopeProvider()),
    ChangeNotifierProvider(create: (context) => CartProvider()),
    ChangeNotifierProvider(create: (context) => OrderProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  ThemeData _buildShrineTheme() {
    final ThemeData base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: kShrinePink400,
          onPrimary: kShrineBrown900,
          secondary: kShrineBrown900,
          error: kShrineErrorRed,
        ),
        textTheme: _buildShrineTextTheme(GoogleFonts.robotoTextTheme()),
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: kShrinePink100,
        ));
  }

  TextTheme _buildShrineTextTheme(TextTheme base) {
    return base
        .copyWith(
          headlineSmall: base.headlineSmall!.copyWith(
            fontWeight: FontWeight.w500,
          ),
          titleLarge: base.titleLarge!.copyWith(
            fontSize: 18.0,
          ),
          bodySmall: base.bodySmall!.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
          bodyLarge: base.bodyLarge!.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
        )
        .apply(
          displayColor: kShrineBrown900,
          bodyColor: kShrineBrown900,
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      builder: EasyLoading.init(),
      title: 'Flutter Demo',
      theme: _buildShrineTheme(),
    );
  }

  final _router = GoRouter(
      initialLocation: ViewTelescopePage.routeName,
      redirect: (context, state) {
        if (AuthService.currentUser == null) {
          return LoginPage.routeName;
        }
        return null;
      },
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          name: LoginPage.routeName,
          path: LoginPage.routeName,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          name: ViewTelescopePage.routeName,
          path: ViewTelescopePage.routeName,
          builder: (context, state) => const ViewTelescopePage(),
          routes: [
            GoRoute(
              name: TelescopeDetailsPage.routeName,
              path: TelescopeDetailsPage.routeName,
              builder: (context, state) => TelescopeDetailsPage(id: state.extra! as String),
            ),
            GoRoute(
              name: CartPage.routeName,
              path: CartPage.routeName,
              builder: (context, state) => const CartPage(),
              routes: [
                GoRoute(
                  name: CheckOutPage.routeName,
                  path: CheckOutPage.routeName,
                  builder: (context, state) => const CheckOutPage(),
                ),
              ]
            ),
          ]
        ),
      ]);
}
