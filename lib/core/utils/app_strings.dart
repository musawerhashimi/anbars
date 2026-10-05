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
  String get quickActions      => _d ? 'دسترسی سریع'       : 'Quick Actions';
  String get newSale           => _d ? 'فروش جدید'         : 'New Sale';
  String get last7Days         => _d ? 'هفت روز گذشته'      : 'Last 7 days';
  String get vsYesterday       => _d ? 'نسبت به دیروز'      : 'vs yesterday';
  String lowStockBanner(String n) => _d ? '$n جنس موجودی کم دارد' : '$n products are running low';
  String get tapToReview       => _d ? 'برای بررسی بزنید'   : 'Tap to review';

  // ── Sale History ─────────────────────────────────────────────────────────
  String get saleHistory       => _d ? 'تاریخچه فروش'      : 'Sale History';
  String get recentSales       => _d ? 'فروش‌های اخیر'      : 'Recent Sales';
  String get seeAll            => _d ? 'مشاهده همه'        : 'See all';
  String get saleDetails       => _d ? 'جزئیات فروش'       : 'Sale Details';
  String saleNumber(String id) => _d ? 'فروش #$id'         : 'Sale #$id';
  String itemsCount(String n)  => _d ? '$n قلم'            : '$n items';
  String salesCount(String n)  => _d ? '$n فروش'           : '$n sales';
  String get today             => _d ? 'امروز'             : 'Today';
  String get yesterday         => _d ? 'دیروز'             : 'Yesterday';
  String get thisWeek          => _d ? 'این هفته'          : 'This Week';
  String get noSalesYet        => _d ? 'هنوز فروشی ثبت نشده' : 'No sales yet';
  String get noSalesHint       => _d ? 'فروش‌های تکمیل‌شده اینجا نمایش داده می‌شوند.' : 'Completed sales will appear here.';
  String get noSalesInPeriod   => _d ? 'در این مدت فروشی نیست' : 'No sales in this period';
  String get items             => _d ? 'اقلام'             : 'Items';

  // ── Sold Products Report ─────────────────────────────────────────────────
  String get soldProductsReport => _d ? 'گزارش اجناس فروخته‌شده' : 'Sold Products Report';
  String get soldProductsReportHint => _d ? 'فهرست تمام اجناس فروخته‌شده با مجموع کل' : 'All sold products with the grand total';
  String get printReport       => _d ? 'چاپ گزارش'         : 'Print Report';
  String period(String label)  => _d ? 'دوره: $label'      : 'Period: $label';
  String get qtySold           => _d ? 'تعداد فروخته‌شده'   : 'Qty Sold';
  String get unitPrice         => _d ? 'قیمت واحد'         : 'Unit Price';
  String get grandTotal        => _d ? 'مجموع کل'          : 'Grand Total';
  String get noSalesToReport   => _d ? 'برای این دوره فروشی برای گزارش وجود ندارد.' : 'No sales to report for this period.';

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
  String get warehouseReport   => _d ? 'گزارش گدام'        : 'Warehouse Report';
  String get noMatchingProducts => _d ? 'هیچ جنسی پیدا نشد' : 'No matching products';
  String get noProductsYet     => _d ? 'هنوز جنسی وجود ندارد' : 'No products yet';
  String get tryClearingFilters => _d ? 'فیلترها را پاک کنید.' : 'Try clearing filters.';
  String get tapToAddProduct   => _d ? 'برای افزودن اولین جنس + را بزنید.' : 'Tap + to add your first product.';
  String get clearFilters      => _d ? 'پاک کردن فیلترها'  : 'Clear Filters';
  String get clearAll          => _d ? 'پاک کردن همه'      : 'Clear all';
  String get category          => _d ? 'کتگوری'            : 'Category';
  String get department        => _d ? 'بخش / گدام'        : 'Department / Warehouse';
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
  String get departments       => _d ? 'بخش‌ها / گدام‌ها'    : 'Departments / Warehouses';
  String get account           => _d ? 'حساب کاربری'        : 'Account';
  String get theme             => _d ? 'پوسته'              : 'Theme';
  String get themeLight        => _d ? 'روشن'               : 'Light';
  String get themeDark         => _d ? 'تاریک'              : 'Dark';
  String get themeSystem       => _d ? 'سیستم'              : 'System';
  String get reports           => _d ? 'گزارش‌ها'            : 'Reports';
  String get productsShort     => _d ? 'اجناس'              : 'Products';
  String get salesShort        => _d ? 'فروش‌ها'             : 'Sales';
  String recordsCount(String n) => _d ? '$n مورد'          : '$n items';
  String get usernameAndPassword => _d ? 'نام کاربری، ایمیل و رمز عبور' : 'Username, email and password';
  String get saleHistoryHint   => _d ? 'تمام فروش‌ها و گزارش اجناس فروخته‌شده' : 'All sales and the sold products report';
  String get logoutConfirm     => _d ? 'آیا مطمئن هستید که می‌خواهید از حساب خارج شوید؟' : 'Are you sure you want to log out?';

  // Backup & restore
  String get backupRestore     => _d ? 'پشتیبان‌گیری و بازیابی' : 'Backup & Restore';
  String get emailBackupTitle  => _d ? 'پشتیبان از طریق ایمیل' : 'Email backup';
  String get emailBackupHint   => _d ? 'فایل پشتیبان به ایمیل مشتری فرستاده می‌شود' : 'The backup file is sent to the customer\'s email';
  String get backupEmail       => _d ? 'ایمیل مشتری'       : 'Customer email';
  String get invalidEmail      => _d ? 'یک ایمیل درست وارد کنید' : 'Enter a valid email address';
  String get sendBackup        => _d ? 'ارسال پشتیبان'     : 'Email backup';
  String get restoreFromFile   => _d ? 'بازیابی از فایل'   : 'Restore from file';
  String lastBackup(String t)  => _d ? 'آخرین پشتیبان: $t' : 'Last backup: $t';
  String get neverBackedUp     => _d ? 'هنوز پشتیبانی گرفته نشده است' : 'No backup yet';
  String get preparingBackup   => _d ? 'در حال آماده‌سازی...' : 'Preparing...';
  String get restoring         => _d ? 'در حال بازیابی...'  : 'Restoring...';
  String get backupFailed      => _d ? 'پشتیبان‌گیری ناموفق بود' : 'Backup failed';
  String get restore           => _d ? 'بازیابی'           : 'Restore';
  String get restoreConfirm    => _d ? 'تمام داده‌های فعلی با این پشتیبان جایگزین می‌شوند. ادامه می‌دهید؟' : 'All current data will be replaced by this backup. Continue?';
  String get restoreSuccess    => _d ? 'داده‌ها با موفقیت بازیابی شدند' : 'Data restored successfully';
  String get restoreFailed     => _d ? 'بازیابی ناموفق بود' : 'Restore failed';
  String get invalidBackup     => _d ? 'این فایل پشتیبان معتبر انبار نیست' : 'This file is not a valid Anbar backup';
  String backupEmailSubject(String date) => _d ? 'پشتیبان انبار - $date' : 'Anbar backup - $date';
  String get backupEmailBody   => _d
      ? 'فایل پشتیبان اپلیکیشن انبار ضمیمه شده است.\nبرای بازیابی، فایل را دانلود کنید و در تنظیمات گزینه «بازیابی از فایل» را بزنید.'
      : 'Your Anbar app backup is attached.\nTo restore, download the file and tap "Restore from file" in Settings.';
  String get autoBackup        => _d ? 'پشتیبان‌گیری خودکار' : 'Automatic backup';
  String get autoBackupHint    => _d ? 'وقتی زمان پشتیبان برسد، اپ فایل را آماده کرده و ایمیل را برای ارسال باز می‌کند.' : 'When a backup is due, the app prepares the file and opens your email to send it.';
  String get frequencyOff      => _d ? 'خاموش'             : 'Off';
  String get frequencyDaily    => _d ? 'روزانه'            : 'Daily';
  String get frequencyWeekly   => _d ? 'هفتگی'             : 'Weekly';
  String get frequencyMonthly  => _d ? 'ماهانه'            : 'Monthly';
  String nextBackup(String t)  => _d ? 'پشتیبان بعدی: $t'  : 'Next backup: $t';
  String get backupDueNow      => _d ? 'پشتیبان بعدی: همین حالا' : 'Next backup: now';
  String get backupDueTitle    => _d ? 'وقت پشتیبان‌گیری است' : 'Time to back up';
  String backupDueMessage(String freq) => _d
      ? 'پشتیبان $freq شما آماده است و به این ایمیل فرستاده می‌شود:'
      : 'Your ${freq.toLowerCase()} backup is ready to be sent to:';
  String backupDueNoEmail(String freq) => _d
      ? 'زمان پشتیبان $freq شما رسیده است. برای ارسال، ایمیل مشتری را در تنظیمات وارد کنید.'
      : 'Your ${freq.toLowerCase()} backup is due. Add the customer email in Settings to send it.';
  String get sendNow           => _d ? 'ارسال حالا'        : 'Send now';
  String get later             => _d ? 'بعداً'             : 'Later';
  String get openSettings      => _d ? 'رفتن به تنظیمات'   : 'Open Settings';
  String get restoreHowTo      => _d ? 'برای بازیابی، فایل ضمیمه را از ایمیل دانلود کنید و «بازیابی از فایل» را بزنید.' : 'To restore, download the attached file from the email and tap "Restore from file".';

  // ── Master Data Screen ────────────────────────────────────────────────────
  String get noUnitsYet        => _d ? 'هنوز واحدی وجود ندارد'      : 'No units yet';
  String get noCategoriesYet   => _d ? 'هنوز کتگوری‌ای وجود ندارد' : 'No categories yet';
  String get noDepartmentsYet  => _d ? 'هنوز بخش یا گدامی وجود ندارد' : 'No departments or warehouses yet';
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
