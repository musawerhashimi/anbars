import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/language_provider.dart';

class AppStrings {
  final bool _d; // true = Dari, false = English
  const AppStrings(this._d);

  bool get isDari => _d;

  String get appTitle          => _d ? 'انبار'            : 'Anbar';
  String get inventoryManagement => _d ? 'مدیریت گدام و فروش' : 'Inventory Management';
  String get welcomeBack       => _d ? 'خوش آمدید'         : 'Welcome Back';
  String get signInSubtitle    => _d ? 'لطفاً داخل حساب خود شوید' : 'Sign in to your account';
  String get login             => _d ? 'داخل شدن'          : 'Login';
  String get password          => _d ? 'رمز عبور'          : 'Password';
  String get logout            => _d ? 'خروج از حساب'      : 'Logout';
  String get admin             => _d ? 'مدیر'              : 'Admin';
  String get versionLabel      => _d ? 'انبار نسخه ۱.۰.۰' : 'Anbar v1.0.0';

  // ── Greetings ────────────────────────────────────────────────────────────
  String get goodMorning       => _d ? 'صبح بخیر،'         : 'Good Morning,';
  String get goodAfternoon     => _d ? 'نیمروز بخیر،'      : 'Good Afternoon,';
  String get goodEvening       => _d ? 'شام بخیر،'          : 'Good Evening,';
  String get manager           => _d ? 'مدیر'              : 'Manager';

  // ── Home ─────────────────────────────────────────────────────────────────
  String get warehouseOverview => _d ? 'خلاصه گدام'         : 'Warehouse Overview';
  String get totalProducts     => _d ? 'مجموع اجناس'        : 'Total Products';
  String get lowStockItems     => _d ? 'اجناس کم موجود'     : 'Low Stock Items';
  String get categories        => _d ? 'کتگوری‌ها'          : 'Categories';
  String get vendors           => _d ? 'فروشنده‌ها'          : 'Vendors';
  String get salesOverview     => _d ? 'خلاصه فروش'         : 'Sales Overview';
  String get todayRevenue      => _d ? 'عاید امروز'         : "Today's Revenue";
  String get thisMonth         => _d ? 'این ماه'            : 'This Month';
  String get transactions      => _d ? 'معاملات'            : 'Transactions';
  String get salesThisMonth    => _d ? 'فروش این ماه'       : 'Sales This Month';
  String get transactionsToday => _d ? 'معاملات امروز'      : 'Transactions Today';
  String get alert             => _d ? 'هشدار'              : 'Alert';
  String get good              => _d ? 'خوب'                : 'Good';

  // ── Bottom Nav ───────────────────────────────────────────────────────────
  String get navHome           => _d ? 'خانه'              : 'Home';
  String get navSales          => _d ? 'فروش'              : 'Sales';
  String get navWarehouse      => _d ? 'گدام'              : 'Warehouse';
  String get navSettings       => _d ? 'تنظیمات'           : 'Settings';

  // ── Sales Screen ─────────────────────────────────────────────────────────
  String get sales             => _d ? 'فروش'              : 'Sales';
  String get searchProducts    => _d ? 'جستجوی اجناس...'   : 'Search products...';
  String get noProductsAvailable => _d ? 'هیچ جنسی موجود نیست' : 'No products available';
  String get addProductsFirst  => _d ? 'ابتدا اجناس را در بخش گدام اضافه کنید.' : 'Add products in the Warehouse tab first.';
  String get cart              => _d ? 'سبد خرید'          : 'Cart';
  String get back              => _d ? 'برگشت'             : 'Back';
  String get completeSale      => _d ? 'تکمیل فروش'        : 'Complete Sale';
  String get saleSuccess       => _d ? 'فروش با موفقیت انجام شد!' : 'Sale completed successfully!';
  String get total             => _d ? 'مجموع'             : 'Total';
  String get viewCart          => _d ? 'مشاهده سبد'        : 'View Cart';
  String get pcs               => _d ? 'عدد'               : 'pcs';

  // ── Warehouse Screen ──────────────────────────────────────────────────────
  String get warehouse         => _d ? 'گدام'              : 'Warehouse';
  String get exportPdf         => _d ? 'خروجی PDF'         : 'Export PDF';
  String get noMatchingProducts => _d ? 'هیچ جنسی پیدا نشد' : 'No matching products';
  String get noProductsYet     => _d ? 'هنوز جنسی وجود ندارد' : 'No products yet';
  String get tryClearingFilters => _d ? 'فیلترها را پاک کنید.' : 'Try clearing filters.';
  String get tapToAddProduct   => _d ? 'برای افزودن اولین جنس + را بزنید.' : 'Tap + to add your first product.';
  String get clearFilters      => _d ? 'پاک کردن فیلترها'  : 'Clear Filters';
  String get clearAll          => _d ? 'پاک کردن همه'      : 'Clear all';
  String get category          => _d ? 'کتگوری'            : 'Category';
  String get department        => _d ? 'بخش'               : 'Department';
  String get vendor            => _d ? 'فروشنده'            : 'Vendor';
  String get all               => _d ? 'همه'               : 'All';
  String get addProduct        => _d ? 'افزودن جنس'        : 'Add Product';
  String get pdfExportFailed   => _d ? 'خروجی PDF ناموفق بود:' : 'PDF export failed:';
  String get noProductsToExport => _d ? 'هیچ جنسی برای خروجی وجود ندارد.' : 'No products to export.';

  // ── Add / Edit Product Sheet ──────────────────────────────────────────────
  String get editProduct       => _d ? 'ویرایش جنس'        : 'Edit Product';
  String get productName       => _d ? 'نام جنس'           : 'Product Name';
  String get quantity          => _d ? 'مقدار'             : 'Quantity';
  String get price             => _d ? 'قیمت'              : 'Price';
  String get unit              => _d ? 'واحد'              : 'Unit';
  String get description       => _d ? 'توضیحات (اختیاری)' : 'Description (optional)';
  String get saveChanges       => _d ? 'ذخیره تغییرات'     : 'Save Changes';
  String get nameRequired      => _d ? 'نام الزامی است'    : 'Name is required';
  String get required          => _d ? 'الزامی'            : 'Required';
  String get invalidNumber     => _d ? 'عدد نامعتبر'       : 'Invalid number';
  String get invalidPrice      => _d ? 'قیمت نامعتبر'      : 'Invalid price';
  String get newLabel          => _d ? 'جدید'              : 'New';
  String get name              => _d ? 'نام'               : 'Name';
  String get contactInfo       => _d ? 'اطلاعات تماس (اختیاری)' : 'Contact Info (optional)';
  String get cancel            => _d ? 'لغو'               : 'Cancel';
  String get add               => _d ? 'افزودن'            : 'Add';
  String get select            => _d ? 'انتخاب کنید'       : 'Select';
  String get addNew            => _d ? 'افزودن جدید'       : 'Add new';

  // ── Product Detail Sheet ──────────────────────────────────────────────────
  String get productDetails    => _d ? 'جزئیات جنس'        : 'Product Details';
  String get lowStockWarning   => _d ? 'موجودی کم — فقط'   : 'Low stock — only';
  String get remaining         => _d ? 'باقی مانده'         : 'remaining';
  String get added             => _d ? 'اضافه شده'          : 'Added';
  String get deleteProduct     => _d ? 'حذف جنس'           : 'Delete Product';
  String get deleteConfirmMsg  => _d ? 'حذف شود؟ این عمل قابل برگشت نیست.' : '? This cannot be undone.';

  // ── Settings Screen ───────────────────────────────────────────────────────
  String get settings          => _d ? 'تنظیمات'           : 'Settings';
  String get tapToEditProfile  => _d ? 'برای ویرایش پروفایل بزنید' : 'Tap to edit profile';
  String get appearance        => _d ? 'ظاهر'              : 'Appearance';
  String get darkMode          => _d ? 'حالت تاریک'        : 'Dark Mode';
  String get language          => _d ? 'زبان'              : 'Language';
  String get masterData        => _d ? 'داده‌های اصلی'      : 'Master Data';
  String get units             => _d ? 'واحدها'            : 'Units';
  String get about             => _d ? 'درباره'             : 'About';
  String get appVersion        => _d ? 'نسخه برنامه'        : 'App Version';
  String get departments       => _d ? 'بخش‌ها'             : 'Departments';

  // ── Master Data Screen ────────────────────────────────────────────────────
  String get noUnitsYet        => _d ? 'هنوز واحدی وجود ندارد'      : 'No units yet';
  String get noCategoriesYet   => _d ? 'هنوز کتگوری‌ای وجود ندارد' : 'No categories yet';
  String get noDepartmentsYet  => _d ? 'هنوز بخشی وجود ندارد'       : 'No departments yet';
  String get noVendorsYet      => _d ? 'هنوز فروشنده‌ای وجود ندارد' : 'No vendors yet';
  String get edit              => _d ? 'ویرایش'            : 'Edit';
  String get delete            => _d ? 'حذف'               : 'Delete';
  String get save              => _d ? 'ذخیره'             : 'Save';
  String get deleteConfirm     => _d ? 'اجناسی که از آن استفاده می‌کنند این مرجع را از دست می‌دهند.' : 'Items using it will lose this reference.';

  // ── Profile Sheet ─────────────────────────────────────────────────────────
  String get editProfile       => _d ? 'ویرایش پروفایل'    : 'Edit Profile';
  String get username          => _d ? 'نام کاربری'         : 'Username';
  String get changePassword    => _d ? 'تغییر رمز عبور'    : 'Change Password';
  String get currentPassword   => _d ? 'رمز عبور فعلی'     : 'Current Password';
  String get newPassword       => _d ? 'رمز عبور جدید'     : 'New Password';
  String get confirmPassword   => _d ? 'تأیید رمز عبور جدید' : 'Confirm New Password';
  String get minSixChars       => _d ? 'حداقل ۶ حرف'       : 'Min 6 characters';
  String get passwordMismatch  => _d ? 'رمزهای عبور مطابقت ندارند' : 'Passwords do not match';
  String get usernameUpdated   => _d ? 'نام کاربری به‌روز شد!' : 'Username updated!';
  String get usernameUpdateFailed => _d ? 'به‌روزرسانی نام کاربری ناموفق بود.' : 'Failed to update username.';
  String get passwordChanged   => _d ? 'رمز عبور تغییر یافت!' : 'Password changed!';
  String get wrongPassword     => _d ? 'رمز عبور فعلی اشتباه است.' : 'Current password is incorrect.';

  // ── Language Picker ───────────────────────────────────────────────────────
  String get selectLanguage    => _d ? 'انتخاب زبان'       : 'Select Language';

  // ── PDF Export ────────────────────────────────────────────────────────────
  String get warehouseProductList => _d ? 'فهرست اجناس گدام' : 'Warehouse Product List';
  String generatedAt(String date) => _d ? 'تاریخ تهیه: $date' : 'Generated: $date';
  String get qty               => _d ? 'موجودی'            : 'Qty';
  String get purchasedQty      => _d ? 'مقدار خریداری‌شده' : 'Purchased Qty';
  String get totalPrice        => _d ? 'قیمت مجموعی'       : 'Total Price';
  String pdfTotals(int count)  => _d ? 'مجموعه — $count جنس' : 'TOTALS  —  $count products';
  String get totalQty          => _d ? 'مجموع موجودی'      : 'Total Qty';
  String get anbarInventory    => _d ? 'انبار — مدیریت گدام' : 'Anbar Inventory';
  String pageOf(int page, int total) => _d ? 'صفحه $page از $total' : 'Page $page of $total';

  // ── Confirm Dialog ────────────────────────────────────────────────────────
  String get deleteLabel       => _d ? 'حذف'               : 'Delete';

  // ── Shared ────────────────────────────────────────────────────────────────
  String get error             => _d ? 'خطا'               : 'Error';
}

// ── Provider ─────────────────────────────────────────────────────────────────

final stringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(languageProvider).valueOrNull;
  return AppStrings(lang?.code != 'en');
});
