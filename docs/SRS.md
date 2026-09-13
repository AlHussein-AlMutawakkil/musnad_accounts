# وثيقة متطلبات النظام المحاسبي (SRS)

## 1. نظرة عامة
تطبيق محاسبي للجوال مبني بإطار العمل Flutter لإدارة الحسابات والديون بنظام (له / عليه) والتحويل والمصارفة بين العملات. التطبيق يعمل بدون إنترنت بالكامل (Offline-First) مع جاهزية للمزامنة السحابية المستقبلية.

## 2. القواعد المحاسبية الجوهرية
- **الرصيد:** لا يُخزن كرقم ثابت، بل يُحسب ديناميكياً: رصيد الحساب = مجموع (له) - مجموع (عليه).
- **التحويل بنفس العملة:** يُسجل كقيدين مرتبطين بنفس الـ `transfer_id` (قيد "عليه" للمرسل، وقيد "له" للمستلم).
- **التحويل مع المصارفة (عملات مختلفة):** قيد مزدوج بـ `transfer_id` موحد، مع تسجيل سعر الصرف والمبلغ المستلم بدقة. تعديل أو حذف أي طرف يحدّث أو يحذف الطرف المقابل فوراً.
- **تعدد العملات:** الحساب الواحد يمكن أن يتعامل بعدة عملات في نفس الوقت.

## 3. معايير قاعدة البيانات (SQLite)
- الاعتماد على `UUID v4` كمفاتيح أساسية (`id`) لجميع الجداول.
- تطبيق الحذف الناعم (Soft Delete) عبر حقل `deleted_at`.
- تتبع المزامنة عبر حقول: `created_at` (UTC)، `updated_at` (UTC)، و`is_synced` (Boolean).

## 4. هيكل الجداول الأساسية
1. **`currencies`**: `id`, `name`, `code`, `symbol`, `is_default`, `created_at`, `updated_at`
2. **`categories`**: `id`, `name`, `color_hex`, `icon_name`, `created_at`, `updated_at`, `deleted_at`
3. **`accounts`**: `id`, `category_id`, `name`, `phone`, `notes`, `created_at`, `updated_at`, `is_synced`, `deleted_at`
4. **`transactions`**: `id`, `account_id`, `currency_id`, `type (DEBIT/CREDIT)`, `amount`, `date`, `description`, `transfer_id`, `exchange_rate`, `created_at`, `updated_at`, `is_synced`, `deleted_at`