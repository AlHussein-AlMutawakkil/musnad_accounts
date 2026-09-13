# خريطة طريق التنفيذ (Execution Checklist)

- [x] **المرحلة 1: التأسيس وقاعدة البيانات**
    - [x] إنشاء ملفات الثوابت: `AppColors`, `AppDimensions`, `AppTextStyles`.
    - [x] بناء كلاس `DatabaseHelper` وإنشاء الجداول الأربعة بمفاتيح UUID وحقول المزامنة.
    - [x] بناء كلاسات المودلز: `CurrencyModel`, `CategoryModel`, `AccountModel`, `TransactionModel`.

- [x] **المرحلة 2: المكونات المشتركة (`core/widgets/`)**
    - [x] بناء حاويات العرض: `AppCard`, `AppKpiCard`, `AppDivider`.
    - [x] بناء عناصر النماذج: `AppTextField`, `AppAmountField`, `AppTypeToggle`, `AppDropdownField`.
    - [x] بناء الأزرار والقوائم: `AppPrimaryButton`, `AppFormattedAmount`, `AppTransactionTile`.

- [x] **المرحلة 3: وحدات التحكم وإدارة الحالة (`Controllers`)**
    - [x] `AccountController`: إضافة حساب، جلب الحسابات، وحساب الأرصدة ديناميكياً.
    - [x] `TransactionController`: تسجيل قيد (له/عليه)، كشف الحساب، والفلترة.
    - [x] `TransferController`: تنفيذ عمليات التحويل المزدوج والمصارفة داخل Transaction.

- [x] **المرحلة 4: الواجهات وتجربة المستخدم (`Views`)**
    - [x] الشاشة الرئيسية ومؤشرات KPIs وشريط العملات.
    - [x] شاشة كشف حساب الطرف وفلاتر العملات والتاريخ.
    - [x] شاشة إضافة حركة سريعة (له / عليه).
    - [x] شاشة التحويل والمصارفة بين العملات.