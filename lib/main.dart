import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_cubit.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_states.dart';
import 'package:inventory_sales_manager/shared/cubits/bloc_observer.dart';
import 'package:inventory_sales_manager/shared/cubits/productsCubit/products_cubit.dart';
import 'package:inventory_sales_manager/shared/cubits/salesCubit/sales_cubit.dart';
import 'package:inventory_sales_manager/shared/cubits/statsCubit/stats_cubit.dart';
import 'package:inventory_sales_manager/shared/networks/local/cache_helper.dart';
import 'package:inventory_sales_manager/shared/networks/local/db_helper.dart';
import 'package:inventory_sales_manager/shared/services/notification_service.dart';
import 'package:inventory_sales_manager/shared/styles/styles.dart';
import 'layout/app_layout.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();

  DbHelper.init();

  await CacheHelper.init();

  await NotificationService().init();

  bool isDark = CacheHelper.getData(key: 'isDark') ?? false;

  runApp( MyApp(isDark: isDark,));
}

class MyApp extends StatelessWidget {
  final bool isDark;
  const MyApp({super.key, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(create: (context) => AppCubit()..changeTheme(fromShared: isDark)..getSavedLanguage(),),
        BlocProvider<ProductsCubit>(create: (context) => ProductsCubit()..getProducts(),),
        BlocProvider<SalesCubit>(create: (context) => SalesCubit()..getSales(),),
        BlocProvider<StatsCubit>(create: (context) => StatsCubit()..loadAll(context),),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child)=>BlocBuilder<AppCubit,AppStates>(builder:(context, state) {
          AppCubit appCubit = AppCubit.get(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: appCubit.currentLocale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: appCubit.isDark ? ThemeMode.dark : ThemeMode.light,
            home: AppLayout(),
          );
        }, ),
      ),
    );
  }
}
