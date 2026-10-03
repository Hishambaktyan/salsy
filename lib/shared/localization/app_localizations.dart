import 'package:flutter/material.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_cubit.dart';

String tr(BuildContext context, String key) =>
    AppLocalizations.translate(key, AppCubit.get(context).language);

String trp(BuildContext context, String key, Map<String, String> params) =>
    AppLocalizations.translate(key, AppCubit.get(context).language,
        params: params);

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'preferences': 'Preferences',
      'dark_mode': 'Dark Mode',
      'dark_mode_subtitle': 'Switch between light and dark theme',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
      'notif_out_of_stock_title': 'Out of Stock',
      'notif_out_of_stock_body': 'Product "{name}" is completely out of stock!',
      'notif_low_stock_title': 'Low Stock Alert',
      'notif_low_stock_body': 'Only {n} items remaining for "{name}"',
      'notif_new_sale_title': 'New Sale Completed',
      'notif_new_sale_body': 'Invoice #{invoiceNo} with total {total}',
      'notif_status_title': 'Order Status Updated',
      'notif_status_body': 'Invoice #{id} status changed to ({status})',
      'notif_eod_title': 'Daily Operations Summary',
      'notif_eod_body': 'Total orders today: {orders} | Total revenue: {revenue}',
    },
    'ar': {
      // الإعدادات
      'settings': 'الإعدادات',
      'preferences': 'التفضيلات',
      'dark_mode': 'الوضع الداكن',
      'dark_mode_subtitle': 'التبديل بين الثيم الفاتح والداكن',
      'language': 'اللغة',
      'english': 'English',
      'arabic': 'العربية',
      // التنقل
      'Home': 'الرئيسية', 'Products': 'المنتجات', 'Sales': 'المبيعات',
      'Statistics': 'الإحصائيات', 'Settings': 'الإعدادات',
      // الرئيسية
      'Good Morning': 'صباح الخير', 'Good Afternoon': 'مساء الخير',
      'Good Evening': 'مساء الخير', 'Dashboard': 'لوحة التحكم',
      'Total Revenue': 'إجمالي الإيرادات', 'Orders': 'الطلبات',
      'Overview': 'نظرة عامة', 'This Month': 'هذا الشهر',
      'Total Products': 'إجمالي المنتجات', 'Items in stock': 'قطع في المخزون',
      'Total Sales': 'إجمالي المبيعات', 'Orders this month': 'طلبات هذا الشهر',
      'Net Profit': 'صافي الربح', 'Low Stock': 'مخزون منخفض',
      'Need restocking': 'تحتاج تعبئة', 'Quick Actions': 'إجراءات سريعة',
      'Add Product': 'إضافة منتج', 'New Sale': 'بيع جديد',
      'Scan Item': 'مسح منتج', 'Recent Sales': 'آخر المبيعات',
      'See All': 'عرض الكل', 'Low Stock Alert': 'تنبيه المخزون',
      'Low': 'منخفض', 'Out': 'نفد', 'Out of stock': 'نفد من المخزون',
      'No sales yet': 'لا توجد مبيعات بعد', 'No data yet': 'لا توجد بيانات بعد',
      'Product not found': 'المنتج غير موجود',
      // التواريخ
      'Today': 'اليوم', 'Yesterday': 'أمس',
      // المنتجات
      'All': 'الكل', 'In Stock': 'متوفر', 'Out of Stock': 'نفد',
      'Electronics': 'إلكترونيات', 'Fashion': 'أزياء',
      'Accessories': 'إكسسوارات', 'Food': 'أغذية',
      'Home & Living': 'المنزل', 'Other': 'أخرى',
      'Edit Product': 'تعديل المنتج', 'Delete Product': 'حذف المنتج',
      'Add New Product': 'إضافة منتج جديد', 'Save Product': 'حفظ المنتج',
      'Selling Price': 'سعر البيع', 'Product Name': 'اسم المنتج',
      'SKU / Product Code': 'كود المنتج', 'Category': 'التصنيف',
      'Product Image': 'صورة المنتج', 'Basic Information': 'معلومات أساسية',
      'This SKU already exists': 'هذا الكود مستخدم من قبل',
      'Cancel': 'إلغاء', 'Delete': 'حذف',
      // المبيعات
      'Sales Transactions': 'فواتير المبيعات',
      'Completed': 'مكتملة', 'Pending': 'معلّقة', 'Cancelled': 'ملغاة',
      'Cash': 'نقداً', 'Card': 'بطاقة', 'Transfer': 'تحويل',
      'Walk-in Customer': 'عميل مباشر',
      'Customer': 'العميل', 'Date': 'التاريخ', 'Payment': 'الدفع',
      'Status': 'الحالة', 'Notes': 'ملاحظات', 'Subtotal': 'المجموع الفرعي',
      'Discount': 'الخصم', 'Total': 'الإجمالي',
      'Mark as Completed': 'تحديد كمكتملة', 'Restore Sale': 'استعادة الفاتورة',
      'Cancel Sale': 'إلغاء الفاتورة', 'Delete Sale': 'حذف الفاتورة',
      // الإحصائيات
      'This Week': 'هذا الأسبوع', 'This Year': 'هذه السنة',
      'Gross Profit': 'إجمالي الربح', 'Discounts': 'الخصومات',
      'All products are well stocked': 'كل المنتجات متوفرة بكميات كافية',
      'Only {n} items remaining': 'متبقي {n} قطع فقط',
      // ── إضافة منتج
      'Upload Product Image': 'رفع صورة المنتج',
      'Tap to choose an image from your device': 'اضغط لاختيار صورة من جهازك',
      'PNG, JPG or JPEG': 'PNG أو JPG أو JPEG',
      'Change Image': 'تغيير الصورة',
      'Enter product name': 'أدخل اسم المنتج',
      'Product name is required': 'اسم المنتج مطلوب',
      'e.g. PRD-001': 'مثال: PRD-001',
      'Product code is required': 'كود المنتج مطلوب',
      'Pricing & Inventory': 'التسعير والمخزون',
      'Enter valid price': 'أدخل سعراً صحيحاً',
      'Cost Price': 'سعر التكلفة',
      'Enter valid cost': 'أدخل تكلفة صحيحة',
      'Initial Quantity': 'الكمية الابتدائية',
      'Enter available quantity': 'أدخل الكمية المتوفرة',
      'Enter a valid quantity': 'أدخل كمية صحيحة',
      'Additional Details': 'تفاصيل إضافية',
      'Description': 'الوصف',
      'Write product details...': 'اكتب تفاصيل المنتج...',

      // ── إضافة فاتورة
      'Create New Sale': 'إنشاء فاتورة جديدة',
      'Customer Details': 'بيانات العميل',
      'Customer Name': 'اسم العميل',
      'Enter customer name (optional)': 'أدخل اسم العميل (اختياري)',
      'Select Products': 'اختيار المنتجات',
      'Payment Details': 'تفاصيل الدفع',
      'Payment Method': 'طريقة الدفع',
      'Payment Status': 'حالة الدفع',
      'Discount (\$)': 'الخصم (\$)',
      'Add transaction notes or terms...': 'أضف ملاحظات أو شروط للعملية...',
      'Total Amount': 'المبلغ الإجمالي',
      'Complete Sale': 'إتمام البيع',
      'Please select at least one item to proceed.': 'اختر منتجاً واحداً على الأقل للمتابعة.',
      'In Stock: {n}': 'المتوفر: {n}',

      // ── الرئيسية
      'Live': 'مباشر',
      'Avg. Order': 'متوسط الطلب',
      'this month': 'هذا الشهر',
      'from last period': 'عن الفترة السابقة',

      // ── المنتجات
      'Manage your inventory': 'إدارة المخزون',
      'Find Products': 'البحث عن منتجات',
      'Search': 'بحث',
      'Categories': 'التصنيفات',
      'All Products': 'كل المنتجات',
      'No Products Found': 'لا توجد منتجات',
      'Try changing your search or filters': 'جرّب تغيير البحث أو الفلاتر',
      'Available Quantity': 'الكمية المتوفرة',
      '{n} Items': '{n} عنصر',
      '{n} Units': '{n} وحدة',
      'SKU: {sku}': 'الكود: {sku}',

      // ── المبيعات
      'Track & manage transactions': 'تتبع وإدارة العمليات',
      'Add Sale': 'إضافة فاتورة',
      'Search Orders': 'البحث في الطلبات',
      'Search invoice or customer': 'ابحث برقم الفاتورة أو العميل',
      'Transactions': 'العمليات',
      'No Sales Found': 'لا توجد فواتير',
      'Try changing your search or filter options': 'جرّب تغيير البحث أو الفلتر',
      'Items': 'العناصر',

      // ── الإحصائيات
      'Reports & analytics': 'التقارير والتحليلات',
      'Net Growth': 'صافي النمو',
      'Revenue Overview': 'نظرة على الإيرادات',
      'Avg. Order Value': 'متوسط قيمة الطلب',
      'Sales by Category': 'المبيعات حسب التصنيف',
      'Top Selling Products': 'الأكثر مبيعاً',
      '{n} Sold': 'تم بيع {n}',
      'notif_out_of_stock_title': 'نفد من المخزون',
      'notif_out_of_stock_body': 'المنتج "{name}" نفد بالكامل من المخزون!',
      'notif_low_stock_title': 'تنبيه مخزون منخفض',
      'notif_low_stock_body': 'متبقي {n} قطع فقط من "{name}"',
      'notif_new_sale_title': 'تم إتمام فاتورة جديدة',
      'notif_new_sale_body': 'فاتورة رقم {invoiceNo} بقيمة {total}',
      'notif_status_title': 'تحديث حالة الفاتورة',
      'notif_status_body': 'تم تغيير حالة الفاتورة رقم #{id} إلى ({status})',
      'notif_eod_title': 'الملخص اليومي للعمليات',
      'notif_eod_body': 'إجمالي الطلبات اليوم: {orders} | المبيعات: {revenue}',
    },
  };

  static String translate(String key, String langCode,
      {Map<String, String>? params}) {
    String text =
        _localizedValues[langCode]?[key] ?? _localizedValues['en']?[key] ?? key;
    if (params != null) {
      params.forEach((k, v) => text = text.replaceAll('{$k}', v));
    }
    return text;
  }
}