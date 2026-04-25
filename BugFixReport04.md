# BugFixReport04 — تقرير إصلاح الأخطاء

> **التاريخ:** 2026-04-25
> **المشروع:** Dealak Real Estate App (Flutter + Laravel 12)

---

## ملخص التنفيذ

تم فحص جميع الملفات المذكورة في خطة الإصلاح. تبين أن معظم الإصلاحات كانت مطبقة مسبقاً في الكود الحالي. تم تنفيذ الإصلاحات المتبقية فقط.

---

## الإصلاحات المطبقة فعلياً

### 1. UserSeeder — تغيير كلمة مرور الأدمن
- **الملف:** `dealak-backend/database/seeders/UserSeeder.php`
- **المشكلة:** كلمة المرور `Admin123` لا تتبع سياسة كلمات المرور القوية
- **الإصلاح:** تغيير من `'Admin123'` إلى `'Admin@123'`
- **الملاحظة:** النموذج يستخدم `hashed` cast في `User.php:27` مما يمنع التشفير المزدوج

### 2. AuthService — إضافة فحص is_verified
- **الملف:** `dealak-backend/app/Services/AuthService.php:38-40`
- **المشكلة (M1):** لا يوجد فحص `is_verified` عند تسجيل الدخول
- **الإصلاح:** إضافة فحص `is_verified` مع استثناء ADMIN (لأن الأدمن لا يحتاج تأكيد بريد)

### 3. RoleMiddleware — إنشاء جديد
- **الملف:** `dealak-backend/app/Http/Middleware/RoleMiddleware.php` (جديد)
- **المشكلة (M2):** لا يوجد Role-Based Authorization
- **الإصلاح:** إنشاء middleware يفحص `user()->role` مقابل قائمة أدوار مسموحة
- **التسجيل:** `bootstrap/app.php:26` — alias `role`

### 4. api.php — Rate Limiting + Role Authorization
- **الملف:** `dealak-backend/routes/api.php`
- **الإصلاحات:**
  - إضافة `RateLimiter::for('auth')` — 5 طلبات/دقيقة (I1)
  - إضافة `throttle:auth` على register, login, forgot-password
  - إضافة `role:SELLER,AGENT,ADMIN` على routes إنشاء/تعديل العقارات

### 5. إزالة حزم spatie غير مستخدمة (C4, C5)
- **الأمر:** `composer remove spatie/laravel-permission spatie/laravel-activitylog`
- **تنظيف:** حذف `config/permission.php`
- **التحقق:** لا توجد إشارات برمجية لهذه الحزم في مجلد `app/`

### 6. Flutter — auth_guard.dart تحسين توجيه الأدمن
- **الملف:** `dealak_flutter/lib/core/router/auth_guard.dart`
- **الإصلاح:** إضافة توجيه ADMIN تلقائي إلى `/admin` بدل `/`
- **متطلب:** إضافة `saveUserRole()` / `getUserRole()` إلى `SecureStorage`

### 7. Flutter — SecureStorage إضافة حفظ الدور
- **الملف:** `dealak_flutter/lib/core/storage/secure_storage.dart`
- **الإصلاح:** إضافة `_userRoleKey`, `saveUserRole()`, `getUserRole()`

### 8. Flutter — auth_repository.dart حفظ الدور عند الدخول/التسجيل
- **الملف:** `dealak_flutter/lib/data/repositories/auth_repository.dart`
- **الإصلاح:** حفظ `user.role` في SecureStorage بعد login, register, getMe

---

## إصلاحات كانت مطبقة مسبقاً (لا تحتاج تغيير)

| # | المشكلة | الملف | الحالة |
|---|---------|-------|--------|
| C3 | SystemSettingSeeder غير مستدعى + أعمدة غير متطابقة | DatabaseSeeder + Migration + Model | ✅ كان مصلحاً |
| C6 | DATE_TRUNC في AdminController | AdminController.php | ✅ كان يستخدم DATE_FORMAT |
| C7 | GoRouter بدون refreshListenable | auth_listenable.dart + app_router.dart | ✅ كان مطبقاً |
| C8 | register/login بدون ref.listen | register_screen.dart + login_screen.dart | ✅ كان يستخدم ref.listenManual |
| C9 | UserResource wrapper يكسر parsing | auth_repository.dart | ✅ _unwrapUser يعالج الـ wrapper |
| M3 | PropertySeeder agent_id خاطئ | PropertySeeder.php | ✅ كان يستخدم isNotEmpty() |
| M4 | تعارض Favorites Routes | api.php | ✅ apiResource except + مسار منفصل |
| M5 | ImageService لا يحذف الملف الفعلي | ImageService.php | ✅ يحذف من Storage |
| M6 | ImageService URL مكرر | ImageService.php | ✅ يستخدم Storage::url() مباشرة |
| M8 | SearchService SQL Injection عبر sort_by | SearchService.php | ✅ يستخدم whitelist |
| M9 | ConversationController markAsRead بدون تحقق | ConversationController.php | ✅ يتحقق من الملكية |
| M10 | fullText Index على SQLite | Migration | ✅ تم استبداله بـ LIKE |

---

## الملفات المتأثرة

### Backend (5 ملفات معدلة + 1 جديد + 1 محذوف)
| الملف | الإجراء |
|-------|---------|
| `database/seeders/UserSeeder.php` | MODIFY — كلمة المرور |
| `app/Services/AuthService.php` | MODIFY — is_verified check |
| `app/Http/Middleware/RoleMiddleware.php` | NEW |
| `bootstrap/app.php` | MODIFY — تسجيل RoleMiddleware |
| `routes/api.php` | MODIFY — rate limiting + role middleware |
| `config/permission.php` | DELETED |

### Flutter (3 ملفات معدلة)
| الملف | الإجراء |
|-------|---------|
| `lib/core/storage/secure_storage.dart` | MODIFY — saveUserRole/getUserRole |
| `lib/core/router/auth_guard.dart` | MODIFY — توجيه ADMIN |
| `lib/data/repositories/auth_repository.dart` | MODIFY — حفظ الدور |

---

## بيانات اختبار الأدمن المحدثة

| الحقل | القيمة |
|-------|--------|
| البريد | `admin@dealak.com` |
| كلمة المرور | `Admin@123` |
| الدخول | `POST /api/v1/auth/login` |
