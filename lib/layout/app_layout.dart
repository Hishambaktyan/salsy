import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../shared/cubits/appCubit/app_cubit.dart';
import '../shared/cubits/appCubit/app_states.dart';
import '../shared/localization/app_localizations.dart';
import '../shared/styles/colors.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        AppCubit appCubit = AppCubit.get(context);
        bool isDark = appCubit.isDark;
        int currentIndex = appCubit.currentIndex;
        return Scaffold(
          bottomNavigationBar: Container(
            color: isDark? darkBgColor:bgColor,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 8.h),
                child: GNav(
                  rippleColor: mainColor.withOpacity(0.15),
                  hoverColor: mainColor.withOpacity(0.08),
                  gap: 5.w,
                  activeColor: const Color(0xFF14B8A6),
                  iconSize: 20.r,
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 10.h),
                  duration: const Duration(milliseconds: 200),
                  tabBackgroundColor: mainColor.withOpacity(0.15),
                  color: isDark? Colors.white.withOpacity(0.45): Colors.grey,
                  selectedIndex: appCubit.currentIndex,
                  onTabChange: (index) {
                    appCubit.changeIndex(index);
                  },
                  textStyle: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF14B8A6),
                  ),
                  tabs:  [
                    GButton(
                      icon: Icons.wallet,
                      iconColor: Colors.transparent,
                      leading: SvgPicture.asset(
                        'assets/icons/home_bold.svg',
                        color: currentIndex==0?Color(0xFF14B8A6):Colors.grey ,
                      ),
                      text: tr(context, 'Home'),
                    ),
                    GButton(
                      icon: Icons.wallet,
                      iconColor: Colors.transparent,
                      leading: SvgPicture.asset(
                        'assets/icons/products_bold.svg',
                        color: currentIndex==1?Color(0xFF14B8A6):Colors.grey ,
                      ),
                      text: tr(context, 'Products'),
                    ),
                    GButton(
                      icon: Icons.wallet,
                      iconColor: Colors.transparent,
                      leading: SvgPicture.asset(
                        'assets/icons/sales_bold.svg',
                        color: currentIndex==2?Color(0xFF14B8A6):Colors.grey ,
                      ),
                      text: tr(context, 'Sales'),
                    ),
                    GButton(
                      icon: Icons.wallet,
                      iconColor: Colors.transparent,
                      leading: SvgPicture.asset(
                        'assets/icons/chart_bold.svg',
                        color: currentIndex==3?Color(0xFF14B8A6):Colors.grey ,
                      ),
                      text: tr(context, 'Statistics'),
                    ),
                    GButton(
                      icon: Icons.wallet,
                      iconColor: Colors.transparent,
                      leading: SvgPicture.asset(
                        'assets/icons/settings_bold.svg',
                        color: currentIndex==4?Color(0xFF14B8A6):Colors.grey ,
                      ),
                      text: tr(context, 'Settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body:appCubit.screens[appCubit.currentIndex]
        );
      },
    );
  }


}