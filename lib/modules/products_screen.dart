import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_sales_manager/modules/add_product_screen.dart';
import 'package:inventory_sales_manager/shared/compenents/compenents.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_cubit.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_states.dart';
import 'package:inventory_sales_manager/shared/styles/colors.dart';

import '../shared/constants.dart';
import '../shared/cubits/productsCubit/products_cubit.dart';
import '../shared/cubits/refresh.dart';
import '../shared/localization/app_localizations.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';
  String selectedFilter = 'All';

  List<Map<String, dynamic>> get products => context.read<ProductsCubit>().products;

  final List<String> categories = ['All', ... productCategories];

  final List<String> filters = [
    'All',
    'In Stock',
    'Low Stock',
    'Out of Stock',
  ];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final search = searchController.text.toLowerCase();

      final matchesSearch =
          product['name'].toString().toLowerCase().contains(search) ||
              product['sku'].toString().toLowerCase().contains(search);

      final matchesCategory =
          selectedCategory == 'All' ||
              product['category'] == selectedCategory;

      final int quantity = product['quantity'];

      final matchesFilter = switch (selectedFilter) {
        'In Stock' => quantity > 5,
        'Low Stock' => quantity > 0 && quantity <= 5,
        'Out of Stock' => quantity == 0,
        _ => true,
      };

      return matchesSearch && matchesCategory && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ProductsCubit>();
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        AppCubit appCubit = AppCubit.get(context);
        bool isDark = appCubit.isDark;

        Color cardBackground = isDark ? lightDarkColor : Colors.white;
        Color primaryTextColor = isDark ? Colors.white : Colors.black;
        Color secondaryTextColor = isDark ? Colors.white60 : Colors.grey;
        Color subCardBackground = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBF5);

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, 'Manage your inventory'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  tr(context, 'Products'),
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: ()=>move(context, AddProductScreen()),
            backgroundColor: mainColor,
            elevation: 5,
            icon: const Icon(
              Icons.add_rounded,
              color: Colors.white,
            ),
            label: Text(
              tr(context, 'Add Product'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(
              vertical: 5.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 15.w,),
                  padding: EdgeInsetsDirectional.all(17.r),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(isDark ? 0.0 : 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: buildSummaryItem(
                          title: tr(context, 'Total Products'),
                          value: '${products.length}',
                          icon: Icons.inventory_2_outlined,
                          color: mainColor,
                          background: isDark
                              ? mainColor.withOpacity(0.15)
                              : const Color(0xFFF0E9FF),
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 48.h,
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                      Expanded(
                        child: buildSummaryItem(
                          title: tr(context, 'Low Stock'),
                          value:
                          '${products.where((p) => p['quantity'] > 0 && p['quantity'] <= 5).length}',
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFFEA580C),
                          background: isDark
                              ? const Color(0xFFEA580C).withOpacity(0.15)
                              : const Color(0xFFFFEDD5),
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 48.h,
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                      Expanded(
                        child: buildSummaryItem(
                          title: tr(context, 'Out of Stock'),
                          value:
                          '${products.where((p) => p['quantity'] == 0).length}',
                          icon: Icons.remove_shopping_cart_outlined,
                          color: const Color(0xFFEF4444),
                          background: isDark
                              ? const Color(0xFFEF4444).withOpacity(0.15)
                              : const Color(0xFFFEE2E2),
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(context, 'Find Products'),
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      defaultTextFormField(
                          text: tr(context, 'Search'),
                          prefixIcon: 'assets/icons/search.svg',
                          errorMes: '',
                          controller: searchController,
                          type: TextInputType.text,
                          cubit: appCubit,
                        onChanged: (p0) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr(context, 'Categories'),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                        ),
                      ),
                      Text(
                        trp(context, '{n} Items', {'n': '${filteredProducts.length}'}),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 40.h,
                  child: ListView.separated(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w,),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? mainColor
                                : cardBackground,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? mainColor
                                  :Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              tr(context, category),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr(context, 'All Products'),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                        ),
                      ),
                      Theme(
                        data: ThemeData(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          fontFamily: 'Tajawal'
                        ),
                        child: PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          color: cardBackground,
                          onSelected: (value) {
                            setState(() {
                              selectedFilter = value;
                            });
                          },
                          itemBuilder: (context) {
                            return filters.map((filter) {
                              return PopupMenuItem<String>(
                                value: filter,
                                child: Text(
                                  tr(context, filter),
                                  style: TextStyle(
                                    color: primaryTextColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          child: Container(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 11.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: cardBackground,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_list_rounded,
                                  color: mainColor,
                                  size: 17.r,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  tr(context, selectedFilter),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: secondaryTextColor,
                                  size: 16.r,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                if (filteredProducts.isEmpty)
                  Container(
                    margin: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
                    width: double.infinity,
                    padding: EdgeInsetsDirectional.all(30.r),
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 45.r,
                          color: secondaryTextColor,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          tr(context, 'No Products Found'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          tr(context, 'Try changing your search or filters'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredProducts.map((product) {
                    return Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 11.h,start: 15.w,end: 15.w),
                      child: buildProductCard(
                        product: product,
                        isDark: isDark,
                        cardBackground: cardBackground,
                        subCardBackground: subCardBackground,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    );
                  }),
                SizedBox(height: 75.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSummaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color background,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      children: [
        Container(
          width: 35.r,
          height: 35.r,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18.r,
          ),
        ),
        SizedBox(height: 9.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8.5.sp,
            color: secondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildProductCard({
    required Map<String, dynamic> product,
    required bool isDark,
    required Color cardBackground,
    required Color subCardBackground,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final int quantity = product['quantity'];

    final Color statusColor = quantity == 0
        ? const Color(0xFFEF4444)
        : quantity <= 5
        ? const Color(0xFFEA580C)
        : const Color(0xFF059669);

    final String statusKey = quantity == 0
        ? 'Out of Stock'
        : quantity <= 5
        ? 'Low Stock'
        : 'In Stock';

    return Container(
      padding: EdgeInsetsDirectional.all(13.r),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(21.r),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(isDark ? 0.0 : 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 65.r,
                height: 65.r,
                decoration: BoxDecoration(
                  color: product['color'].withOpacity(isDark ? 0.15 : 0.10),
                  borderRadius: BorderRadius.circular(17.r),
                ),
                child: (product['imagePath'] != null &&
                    File(product['imagePath']).existsSync())
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(17.r),
                  child: Image.file(File(product['imagePath']), fit: BoxFit.cover),
                )
                    : Icon(
                  product['icon'],
                  color: product['color'],
                  size: 29.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      tr(context, product['category'].toString()),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      trp(context, 'SKU: {sku}', {'sku': product['sku'].toString()}),
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: secondaryTextColor,
                  size: 20.r,
                ),
                color: cardBackground,
                onSelected: (value) async {
                  if (value == 'edit') {
                    move(context, AddProductScreen(product: product));
                  } else if (value == 'delete') {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (d) => AlertDialog(
                        title: Text(tr(d, 'Delete Product')),
                        content: Text(product['name'].toString()),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(d, false),
                              child: Text(tr(d, 'Cancel'))),
                          TextButton(
                              onPressed: () => Navigator.pop(d, true),
                              child: Text(tr(d, 'Delete'),
                                  style: const TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (ok == true && mounted) {
                      await context.read<ProductsCubit>().deleteProduct(product);
                      if (mounted) await refreshAll(context);
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      tr(context, 'Edit Product'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      tr(context, 'Delete Product'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 13.h),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : const Color(0xFFF1EFF6),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(context, 'Selling Price'),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '\$${(product['price'] as double).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tr(context, 'Available Quantity'),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    trp(context, '{n} Units', {'n': '$quantity'}),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 9.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Text(
                  tr(context, statusKey),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}