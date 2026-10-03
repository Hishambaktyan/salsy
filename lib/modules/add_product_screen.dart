import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:inventory_sales_manager/shared/cubits/appCubit/app_cubit.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_states.dart';
import 'package:inventory_sales_manager/shared/styles/colors.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../shared/constants.dart';
import '../shared/cubits/productsCubit/products_cubit.dart';
import '../shared/cubits/refresh.dart';
import '../shared/localization/app_localizations.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final priceController = TextEditingController();
  final costController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  XFile? selectedImage;
  String selectedCategory = 'Electronics';

  bool get isEdit => widget.product != null;

  late final List<String> categories = productCategories;

  Future<String> saveImageLocally(String source) async {
    final dir = await getApplicationDocumentsDirectory();
    if (p.dirname(source) == dir.path) return source;
    final name = '${DateTime.now().millisecondsSinceEpoch}${p.extension(source)}';
    return (await File(source).copy(p.join(dir.path, name))).path;
  }

  Future<void> pickProductImage() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  void removeProductImage() {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;

    final imagePath =
    selectedImage == null ? null : await saveImageLocally(selectedImage!.path);

    final data = <String, dynamic>{
      'name': nameController.text.trim(),
      'sku': skuController.text.trim(),
      'category': selectedCategory,
      'price': double.tryParse(priceController.text.trim()) ?? 0,
      'cost': double.tryParse(costController.text.trim()) ?? 0,
      'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
      'description': descriptionController.text.trim(),
      'imagePath': imagePath,
    };

    final error = await context
        .read<ProductsCubit>()
        .saveProduct(context,data, id: widget.product?['id']);
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(error == 'sku_exists'
            ? tr(context, 'This SKU already exists')
            : error),
      ));
      return;
    }
    await refreshAll(context);
    if (mounted) Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    final pr = widget.product;
    if (pr != null) {
      nameController.text = pr['name'];
      skuController.text = pr['sku'];
      priceController.text = (pr['price'] as num).toString();
      costController.text = (pr['cost'] as num).toString();
      quantityController.text = pr['quantity'].toString();
      descriptionController.text = pr['description'] ?? '';
      selectedCategory =
      productCategories.contains(pr['category']) ? pr['category'] : 'Other';
      if (pr['imagePath'] != null && File(pr['imagePath']).existsSync()) {
        selectedImage = XFile(pr['imagePath']);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    priceController.dispose();
    costController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
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
        Color fieldBackground = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F7FC);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isEdit ? tr(context, 'Edit Product') : tr(context, 'Add New Product'),
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
                  Text(
                    tr(context, 'Product Image'),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: pickProductImage,
                    child: Container(
                      width: double.infinity,
                      height: 190.h,
                      decoration: BoxDecoration(
                        color: cardBackground,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: selectedImage == null
                              ? mainColor.withOpacity(0.35)
                              : mainColor,
                          width: 1.3,
                        ),
                      ),
                      child: selectedImage == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 55.r,
                            height: 55.r,
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(17.r),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: mainColor,
                              size: 27.r,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            tr(context, 'Upload Product Image'),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            tr(context, 'Tap to choose an image from your device'),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: secondaryTextColor,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            tr(context, 'PNG, JPG or JPEG'),
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(21.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                            PositionedDirectional(
                              top: 10.h,
                              end: 10.w,
                              child: GestureDetector(
                                onTap: removeProductImage,
                                child: Container(
                                  width: 34.r,
                                  height: 34.r,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius:
                                    BorderRadius.circular(11.r),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 19.r,
                                  ),
                                ),
                              ),
                            ),
                            PositionedDirectional(
                              bottom: 10.h,
                              start: 10.w,
                              child: Container(
                                padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: 12.w,
                                  vertical: 7.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius:
                                  BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  tr(context, 'Change Image'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.h),
                  buildSectionTitle(
                    title: tr(context, 'Basic Information'),
                    primaryTextColor: primaryTextColor,
                  ),
                  SizedBox(height: 15.h),
                  buildLabel(tr(context, 'Product Name'), primaryTextColor),
                  SizedBox(height: 8.h),
                  buildTextField(
                    controller: nameController,
                    hint: tr(context, 'Enter product name'),
                    icon: Icons.inventory_2_outlined,
                    background: fieldBackground,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return tr(context, 'Product name is required');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  buildLabel(tr(context, 'SKU / Product Code'), primaryTextColor),
                  SizedBox(height: 8.h),
                  buildTextField(
                    controller: skuController,
                    hint: tr(context, 'e.g. PRD-001'),
                    icon: Icons.qr_code_2_rounded,
                    background: fieldBackground,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return tr(context, 'Product code is required');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  buildLabel(tr(context, 'Category'), primaryTextColor),
                  SizedBox(height: 8.h),
                  Container(
                    height: 55.h,
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: fieldBackground,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        borderRadius: BorderRadius.circular(30.r),
                        value: selectedCategory,
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
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(tr(context, category)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 25.h),
                  buildSectionTitle(
                    title: tr(context, 'Pricing & Inventory'),
                    primaryTextColor: primaryTextColor,
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel(tr(context, 'Selling Price'), primaryTextColor),
                            SizedBox(height: 8.h),
                            buildTextField(
                              controller: priceController,
                              hint: '0.00',
                              icon: Icons.attach_money_rounded,
                              background: fieldBackground,
                              primaryTextColor: primaryTextColor,
                              secondaryTextColor: secondaryTextColor,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) {
                                final price = double.tryParse(value ?? '');
                                if (price == null || price <= 0) {
                                  return tr(context, 'Enter valid price');
                                }
                                return null;
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
                            buildLabel(tr(context, 'Cost Price'), primaryTextColor),
                            SizedBox(height: 8.h),
                            buildTextField(
                              controller: costController,
                              hint: '0.00',
                              icon: Icons.price_check_rounded,
                              background: fieldBackground,
                              primaryTextColor: primaryTextColor,
                              secondaryTextColor: secondaryTextColor,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) {
                                final cost = double.tryParse(value ?? '');
                                if (cost == null || cost < 0) {
                                  return tr(context, 'Enter valid cost');
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  buildLabel(tr(context, 'Initial Quantity'), primaryTextColor),
                  SizedBox(height: 8.h),
                  buildTextField(
                    controller: quantityController,
                    hint: tr(context, 'Enter available quantity'),
                    icon: Icons.numbers_rounded,
                    background: fieldBackground,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final quantity = int.tryParse(value ?? '');
                      if (quantity == null || quantity < 0) {
                        return tr(context, 'Enter a valid quantity');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 25.h),
                  buildSectionTitle(
                    title: tr(context, 'Additional Details'),
                    primaryTextColor: primaryTextColor,
                  ),
                  SizedBox(height: 15.h),
                  buildLabel(tr(context, 'Description'), primaryTextColor),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: primaryTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: tr(context, 'Write product details...'),
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
                        borderSide: BorderSide(
                          color: mainColor,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        tr(context, 'Save Product'),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
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
          borderSide: BorderSide(
            color: mainColor,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}