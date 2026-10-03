import 'dart:math' as math show min;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_cubit.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_states.dart';
import 'package:inventory_sales_manager/shared/styles/colors.dart';

import '../shared/cubits/productsCubit/products_cubit.dart';
import '../shared/cubits/refresh.dart';
import '../shared/cubits/salesCubit/sales_cubit.dart';
import '../shared/localization/app_localizations.dart'; // تأكد من ضبط مسار الاستيراد الخاص بملف الترجمة لديك

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final formKey = GlobalKey<FormState>();

  final customerController = TextEditingController();
  final discountController = TextEditingController();
  final notesController = TextEditingController();

  String paymentMethod = 'Cash';
  String paymentStatus = 'Completed';

  final List<String> paymentMethods = ['Cash', 'Card', 'Transfer'];
  final List<String> paymentStatuses = ['Completed', 'Pending'];

  late List<Map<String, dynamic>> availableProducts;

  @override
  void initState() {
    super.initState();
    availableProducts = context
        .read<ProductsCubit>()
        .products
        .where((p) => (p['quantity'] as int) > 0)
        .map((p) => {
      'id': p['id'],
      'sku': p['sku'],
      'name': p['name'],
      'price': p['price'],
      'cost': p['cost'],
      'stock': p['quantity'],
      'quantity': 0,
    })
        .toList();
  }

  double get subtotal {
    double total = 0.0;
    for (var item in availableProducts) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }
    return total;
  }

  double get discountAmount {
    return double.tryParse(discountController.text) ?? 0.0;
  }

  double get grandTotal {
    double total = subtotal - discountAmount;
    return total < 0 ? 0.0 : total;
  }

  int get selectedItemsCount {
    int count = 0;
    for (var item in availableProducts) {
      if (item['quantity'] > 0) {
        count += item['quantity'] as int;
      }
    }
    return count;
  }

  void updateQuantity(int index, int delta) {
    setState(() {
      int currentQty = availableProducts[index]['quantity'];
      int maxStock = availableProducts[index]['stock'];
      int newQty = currentQty + delta;

      if (newQty >= 0 && newQty <= maxStock) {
        availableProducts[index]['quantity'] = newQty;
      }
    });
  }

  Future<void> saveSale() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedItemsCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr(context, 'Please select at least one item to proceed.')),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final items = availableProducts
        .where((p) => (p['quantity'] as int) > 0)
        .map((p) => {
      'productId': p['id'],
      'name': p['name'],
      'price': p['price'],
      'cost': p['cost'],
      'quantity': p['quantity'],
      'total': (p['price'] as double) * (p['quantity'] as int),
    })
        .toList();

    final sale = {
      'customer': customerController.text.trim().isEmpty
          ? 'Walk-in Customer'
          : customerController.text.trim(),
      'paymentMethod': paymentMethod,
      'status': paymentStatus,
      'subtotal': subtotal,
      'discount': math.min(discountAmount, subtotal),
      'total': grandTotal,
      'itemsCount': selectedItemsCount,
      'notes': notesController.text.trim(),
      'date': DateTime.now().toIso8601String(),
    };

    final error = await context.read<SalesCubit>().addSale(context,sale, items);
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
      return;
    }
    await refreshAll(context);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    customerController.dispose();
    discountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        AppCubit appCubit = AppCubit.get(context);
        bool isDark = appCubit.isDark;

        Color cardBackground = isDark ? lightDarkColor : Colors.white;
        Color primaryTextColor = isDark ? Colors.white : Colors.black;
        Color secondaryTextColor = isDark ? Colors.white60 : Colors.grey;
        Color fieldBackground =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F7FC);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              tr(context, 'Create New Sale'),
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.r,
                color: primaryTextColor,
              ),
            ),
          ),
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 10.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle(
                    title: tr(context, 'Customer Details'),
                    primaryTextColor: primaryTextColor,
                  ),
                  SizedBox(height: 12.h),
                  buildLabel(tr(context, 'Customer Name'), primaryTextColor),
                  SizedBox(height: 8.h),
                  buildTextField(
                    controller: customerController,
                    hint: tr(context, 'Enter customer name (optional)'),
                    icon: Icons.person_outline_rounded,
                    background: fieldBackground,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  SizedBox(height: 25.h),
                  buildSectionTitle(
                    title: tr(context, 'Select Products'),
                    primaryTextColor: primaryTextColor,
                  ),
                  SizedBox(height: 12.h),
                  ...List.generate(availableProducts.length, (index) {
                    final item = availableProducts[index];
                    return buildProductSelectItem(
                      item: item,
                      index: index,
                      isDark: isDark,
                      cardBackground: cardBackground,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    );
                  }),
                  SizedBox(height: 15.h),
                  buildSectionTitle(
                    title: tr(context, 'Payment Details'),
                    primaryTextColor: primaryTextColor,
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel(tr(context, 'Payment Method'), primaryTextColor),
                            SizedBox(height: 8.h),
                            buildDropdown(
                              value: paymentMethod,
                              items: paymentMethods,
                              fieldBackground: fieldBackground,
                              cardBackground: cardBackground,
                              primaryTextColor: primaryTextColor,
                              secondaryTextColor: secondaryTextColor,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => paymentMethod = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel(tr(context, 'Payment Status'), primaryTextColor),
                            SizedBox(height: 8.h),
                            buildDropdown(
                              value: paymentStatus,
                              items: paymentStatuses,
                              fieldBackground: fieldBackground,
                              cardBackground: cardBackground,
                              primaryTextColor: primaryTextColor,
                              secondaryTextColor: secondaryTextColor,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => paymentStatus = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  buildLabel(tr(context, 'Discount (\$)'), primaryTextColor),
                  SizedBox(height: 8.h),
                  buildTextField(
                    controller: discountController,
                    hint: '0.00',
                    icon: Icons.discount_outlined,
                    background: fieldBackground,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 16.h),
                  buildLabel(tr(context, 'Notes'), primaryTextColor),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: notesController,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: primaryTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: tr(context, 'Add transaction notes or terms...'),
                      hintStyle: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 11.sp,
                      ),
                      filled: true,
                      fillColor: fieldBackground,
                      contentPadding: EdgeInsetsDirectional.all(15.r),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: const BorderSide(
                          color: mainColor,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Container(
                    padding: EdgeInsetsDirectional.all(16.r),
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: mainColor.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        buildSummaryRow(tr(context, 'Subtotal'),
                            '\$${subtotal.toStringAsFixed(2)}', secondaryTextColor, primaryTextColor),
                        SizedBox(height: 8.h),
                        buildSummaryRow(tr(context, 'Discount'),
                            '-\$${discountAmount.toStringAsFixed(2)}', secondaryTextColor, const Color(0xFFEF4444)),
                        SizedBox(height: 10.h),
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr(context, 'Total Amount'),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                              ),
                            ),
                            Text(
                              '\$${grandTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25.h),
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: saveSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        tr(context, 'Complete Sale'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSectionTitle({
    required String title,
    required Color primaryTextColor,
  }) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: primaryTextColor,
      ),
    );
  }

  Widget buildLabel(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color background,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 12.sp,
        color: primaryTextColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: secondaryTextColor,
          fontSize: 11.sp,
        ),
        prefixIcon: Icon(
          icon,
          color: secondaryTextColor,
          size: 19.r,
        ),
        filled: true,
        fillColor: background,
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: 14.w,
          vertical: 15.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(
            color: mainColor,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String value,
    required List<String> items,
    required Color fieldBackground,
    required Color cardBackground,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required void Function(String?) onChanged,
  }) {
    return Container(
      height: 55.h,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: fieldBackground,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          borderRadius: BorderRadius.circular(20.r),
          value: value,
          isExpanded: true,
          dropdownColor: cardBackground,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: secondaryTextColor,
          ),
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 12.sp,
            fontFamily: 'Tajawal'
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(tr(context, item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildProductSelectItem({
    required Map<String, dynamic> item,
    required int index,
    required bool isDark,
    required Color cardBackground,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final int qty = item['quantity'];

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsetsDirectional.all(12.r),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: qty > 0 ? mainColor.withOpacity(0.5) : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(isDark ? 0.0 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      '\$${(item['price'] as double).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: mainColor,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '• ${trp(context, 'In Stock: {n}', {'n': '${item['stock']}'})}',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: qty > 0 ? () => updateQuantity(index, -1) : null,
                icon: Icon(
                  Icons.remove_circle_outline_rounded,
                  color: qty > 0 ? const Color(0xFFEF4444) : secondaryTextColor,
                  size: 22.r,
                ),
              ),
              Text(
                '$qty',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                ),
              ),
              IconButton(
                onPressed: qty < item['stock'] ? () => updateQuantity(index, 1) : null,
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: qty < item['stock'] ? const Color(0xFF059669) : secondaryTextColor,
                  size: 22.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSummaryRow(
      String label,
      String value,
      Color labelColor,
      Color valueColor,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}