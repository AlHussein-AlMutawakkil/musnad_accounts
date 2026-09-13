# معمارية التطبيق وقواعد الكود (Architecture Guidelines)

## 1. النمط المعماري
- **MVC (Model-View-Controller)** خفيف ومباشر بدون طبقات وسيطة معقدة.
- **إدارة الحالة:** `ChangeNotifier` للـ Controllers، واستخدام حزمة `Provider` لإيصال البيانات للواجهات وإدارة دورة الحياة.
- **قاعدة البيانات:** حزمة `sqflite` المباشرة عبر كلاس `DatabaseHelper`.

## 2. هيكل المجلدات المعتمد (Folder Structure)
```text
lib/
├── core/
│   ├── constants/       # الألوان، الخطوط، الأبعاد، والأيقونات
│   ├── database/        # DatabaseHelper وجداول SQLite
│   ├── utils/           # الدوال المساعدة وتنسيق التواريخ والأرقام
│   └── widgets/         # مكتبة المكونات المشتركة الموحدة
├── models/              # كلاسات البيانات الخالصة (Models)
├── controllers/         # وحدات التحكم (ChangeNotifier)
├── views/               # الشاشات والواجهات
│   ├── dashboard/       # الشاشة الرئيسية
│   ├── accounts/        # إدارة الحسابات وكشف الحساب
│   ├── transactions/    # شاشات تسجيل حركة جديدة
│   └── transfers/       # شاشة التحويل والمصارفة
└── main.dart