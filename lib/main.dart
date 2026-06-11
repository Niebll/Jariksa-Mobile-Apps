import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/pages/main_page.dart';
import 'package:jariksa/core/theme/app_theme.dart';
import 'package:jariksa/features/auth/cubit/login_cubit.dart';
import 'package:jariksa/features/auth/view/login_page.dart';
import 'package:jariksa/features/home/cubit/home_cubit.dart';
import 'package:jariksa/features/order/cubit/customer_check_cubit.dart';
import 'package:jariksa/features/order/cubit/order_menu_cubit.dart';
import 'package:jariksa/features/order/cubit/order_inspect_cubit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jariksa/features/order/cubit/order_payment_cubit.dart';
import 'package:jariksa/features/order_list/cubit/order_detail_cubit.dart';
import 'package:jariksa/features/home/cubit/business_cubit.dart';
import 'package:jariksa/features/splash/view/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Mengatur status bar agar transparan
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Status bar transparan
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(create: (_) => LoginCubit()),
        BlocProvider<HomeCubit>(create: (_) => HomeCubit()..fetchDashboard()),
        BlocProvider<CustomerCheckCubit>(create: (_) => CustomerCheckCubit()),
        BlocProvider<OrderMenuCubit>(
          create: (_) => OrderMenuCubit()..fetchMenu(),
        ),
        BlocProvider<OrderInspectCubit>(create: (_) => OrderInspectCubit()),
        BlocProvider<OrderPaymentCubit>(create: (_) => OrderPaymentCubit()),
        BlocProvider<OrderDetailCubit>(create: (_) => OrderDetailCubit()),
        BlocProvider<BusinessCubit>(
          create: (_) => BusinessCubit()..fetchBusinessProfile(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        // Use builder only if you need to use library outside ScreenUtilInit context
        builder: (_, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'First Method',
            // You can use the library anywhere in the app even in theme
            theme: AppThemeData.getThemeLight(),
            home: child,
          );
        },
        child: const SplashPage(),
      ),
    );
  }
}
