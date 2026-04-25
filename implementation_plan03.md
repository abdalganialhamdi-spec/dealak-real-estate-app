# 🔧 خطة إصلاح باك إند Dealak - تدقيق شامل

## 📊 ملخص التدقيق

تم فحص **جميع** ملفات الباك إند بالكامل: Models (19)، Controllers (12)، Services (8)، Policies (4)، Migrations (21)، Seeders (5)، Middleware (3)، Form Requests (10)، Resources (16)، Events (2).

---

## 📋 الإجابة على أسئلتك

### 1️⃣ الـ Seeders والأدوار

| Seeder | الوظيفة | المشاكل |
|--------|---------|---------|
| `DatabaseSeeder` | ينشئ Admin + SystemSettings + يستدعي Seeders أخرى | ⚠️ **تعارض** مع UserSeeder |
| `UserSeeder` | ينشئ Admin + 10 Agents + 20 Sellers + 30 Buyers | ⚠️ **يُكرر** إنشاء Admin |
| `GovernorateSeeder` | 14 محافظة سورية | ✅ سليم |
| `PropertySeeder` | عقارات وهمية مرتبطة بالبائعين والوكلاء | ⚠️ مشكلة في `agent_id` |
| `SystemSettingSeeder` | إعدادات النظام | ⚠️ **لا يُستدعى أبداً** + تعارض أعمدة |

**الأدوار المُعرّفة في الـ Migration:**
```
ADMIN, AGENT, BUYER, SELLER, TENANT, LANDLORD
```

**الأدوار المُستخدمة فعلياً:**
- `DatabaseSeeder` ← ADMIN فقط
- `UserSeeder` ← ADMIN, AGENT, SELLER, BUYER
- `RegisterRequest` ← BUYER, SELLER, TENANT, LANDLORD, AGENT
- ❌ **TENANT و LANDLORD** معرّفان لكن بدون أي منطق أو routes خاصة بهما

### 2️⃣ كيف تختبر التطبيق؟

```bash
# 1. تأكد من وجود MySQL وقاعدة بيانات dealak
mysql -u root -e "CREATE DATABASE IF NOT EXISTS dealak"

# 2. ادخل مجلد الباك إند
cd dealak-backend

# 3. ثبت التبعيات
composer install

# 4. شغّل الـ migrations
php artisan migrate:fresh --seed

# 5. شغّل السيرفر (على LAN للوصول من الهاتف)
php artisan serve --host=0.0.0.0 --port=8000

# 6. اختبر عبر المتصفح أو Postman
# Health Check: GET http://<your-ip>:8000/api/v1/health
# Login:        POST http://<your-ip>:8000/api/v1/auth/login
```

### 3️⃣ حساب الأدمن - أين ومتى يُنشأ؟

> [!WARNING]
> **يوجد تعارض خطير!** حساب الأدمن يُنشأ **مرتين** بكلمتي مرور **مختلفتين**:

| المصدر | البريد | كلمة المرور | المشكلة |
|--------|--------|-------------|---------|
| `DatabaseSeeder.php` | `admin@dealak.com` | `Admin123` (bcrypt يدوي) | يُنشأ أولاً |
| `UserSeeder.php` | `admin@dealak.com` | `Password123` (hashed cast) | يُتجاهل بسبب `firstOrCreate` |

**✅ بيانات الأدمن الفعلية:**
- **البريد:** `admin@dealak.com`
- **كلمة المرور:** `Admin123`
- **الدخول عبر:** `POST /api/v1/auth/login`
- **لوحة الأدمن:** جميع routes تحت `/api/v1/admin/*` (API فقط، لا يوجد لوحة ويب)

### 4️⃣ هل الباك إند API كامل لكل الأدوار؟

> [!IMPORTANT]
> **الباك إند يعمل كـ REST API فقط** (لا يوجد واجهة ويب). لكن التغطية **غير متساوية** بين الأدوار:

| الدور | التغطية | التفاصيل |
|-------|---------|----------|
| **ADMIN** | 🟢 **جيد** | Dashboard, إدارة المستخدمين, إدارة العقارات, الموافقة على العقارات, التقارير |
| **BUYER** | 🟡 **متوسط** | تصفح, بحث, مفضلة, طلبات, محادثات, صفقات |
| **SELLER** | 🟡 **متوسط** | إضافة عقارات, إدارة عقاراتي, محادثات, صفقات |
| **AGENT** | 🔴 **ضعيف** | نفس صلاحيات SELLER تقريباً، بدون لوحة خاصة |
| **TENANT** | ❌ **معدوم** | الدور معرّف لكن بدون أي routes أو منطق |
| **LANDLORD** | ❌ **معدوم** | الدور معرّف لكن بدون أي routes أو منطق |

---

## 🐛 المشاكل المكتشفة (27 مشكلة)

### 🔴 مشاكل حرجة (9) — منها 3 في مسار التسجيل Flutter↔Laravel

#### C1: تعارض Seeders - حساب Admin مكرر
- **الملفات:** [DatabaseSeeder.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/seeders/DatabaseSeeder.php), [UserSeeder.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/seeders/UserSeeder.php)
- **المشكلة:** `DatabaseSeeder` يستخدم `User::create()` و `UserSeeder` يستخدم `User::firstOrCreate()`. إذا غيرت كلمة المرور في `UserSeeder` لن تتحدث لأن السجل موجود مسبقاً. والأسوأ: كلمتا المرور **مختلفتان** (`Admin123` vs `Password123`).
- **الخطورة:** ارتباك في بيانات الدخول + يفشل الـ Seeding إذا حذفت `firstOrCreate`.

#### C2: كلمة مرور Admin بدون Hashing في UserSeeder
- **الملف:** [UserSeeder.php:18](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/seeders/UserSeeder.php#L18)
- **المشكلة:** `'password' => 'Password123'` — يعتمد على `hashed` cast في Model. هذا يعمل **فقط** إذا كان Model User يحتوي `'password' => 'hashed'` في casts. وهو موجود ✅. لكن في `DatabaseSeeder` يُستخدم `bcrypt('Admin123')` يدوياً مما يسبب **تشفير مزدوج** لأن الـ cast سيشفره مرة أخرى!

#### C3: `SystemSettingSeeder` لا يُستدعى أبداً + تعارض أعمدة
- **الملفات:** [SystemSettingSeeder.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/seeders/SystemSettingSeeder.php), [system_settings migration](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/migrations/2026_04_15_083051_create_system_settings_table.php)
- **المشكلة 1:** الـ `DatabaseSeeder` لا يستدعيه → الإعدادات المتقدمة لا تُنشأ أبداً.
- **المشكلة 2:** الـ Seeder يستخدم أعمدة `type` و `group` لكن الـ Migration تعرّف فقط `key`, `value`, `value_type`. → **خطأ SQL عند التشغيل!**
- **المشكلة 3:** `DatabaseSeeder` يُدرج إعدادات بعمود `value_type` (الصحيح) لكن `SystemSettingSeeder` يستخدم `type` (غير موجود).
- **المشكلة 4:** Model `SystemSetting` يعرّف `fillable` بأعمدة `type`, `group`, `description` لكنها **غير موجودة في المايقريشن**.

#### C4: `spatie/laravel-permission` مثبتة لكن **غير مستخدمة نهائياً**
- **الملف:** [composer.json:17](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/composer.json#L17)
- **المشكلة:** باكج `spatie/laravel-permission` مثبتة (تتطلب migration خاصة وجداول) لكن لا يوجد `HasRoles` trait على User Model، ولا يوجد أي استخدام في الكود. النظام يستخدم عمود `role` enum يدوياً بدلاً منها.
- **التأثير:** جداول permissions/roles غير موجودة مما قد يسبب أخطاء عند `migrate`. حجم vendor غير ضروري.

#### C5: `spatie/laravel-activitylog` مثبتة لكن **غير مستخدمة**
- **الملف:** [composer.json:16](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/composer.json#L16)
- **المشكلة:** نفس الوضع - مثبتة بدون أي استخدام. `AuditService` و `AuditLog` Model موجودان لكن يعملان بشكل يدوي تماماً بدون الباكج.

#### C6: `DATE_TRUNC` في AdminController Reports - غير متوافق مع MySQL
- **الملف:** [AdminController.php:219](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Http/Controllers/Api/V1/AdminController.php#L219)
- **المشكلة:** `DATE_TRUNC('month', created_at)` هي دالة **PostgreSQL**. قاعدة البيانات المُعرّفة في `.env` هي **MySQL** التي تستخدم `DATE_FORMAT()` بدلاً منها. → **خطأ SQL fatal عند طلب التقارير!**

#### C7: 🔴 التسجيل ينجح لكن لا يحدث توجيه — GoRouter لا يستجيب لتغييرات AuthState
- **الملفات:** [app_router.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/core/router/app_router.dart), [app.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/app.dart), [auth_guard.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/core/router/auth_guard.dart)
- **المشكلة الجذرية:** `GoRouter` يُنشأ بـ `redirect` يعتمد على `AuthGuard` الذي يقرأ التوكن من `SecureStorage`. **لكن لا يوجد `refreshListenable`!** هذا يعني أن الـ `redirect` يُنفّذ **فقط عند التنقل بين الصفحات** وليس عند تغيّر حالة المصادقة.
- **السيناريو:** المستخدم يسجّل → `AuthRepository.register()` يحفظ التوكن في `SecureStorage` → `AuthNotifier` يحدّث الحالة إلى `isAuthenticated: true` → **لكن GoRouter لا يعرف بذلك** → المستخدم يبقى في صفحة التسجيل!
- **الحل:** إضافة `refreshListenable` مرتبط بـ `authProvider` حتى يُعاد تقييم `redirect` تلقائياً عند تغيّر حالة المصادقة.

#### C8: 🔴 `RegisterScreen` لا يحتوي على أي توجيه يدوي بعد نجاح التسجيل
- **الملف:** [register_screen.dart:83-93](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/auth/screens/register_screen.dart#L83-L93)
- **المشكلة:** دالة `_register()` تستدعي `ref.read(authProvider.notifier).register(...)` **بدون `await`** وبدون أي `ref.listen` أو `.then()` لمعالجة النتيجة. لا يوجد `context.go(RouteNames.home)` بعد النجاح ولا `SnackBar` عند الخطأ.
- **نفس المشكلة في `LoginScreen`:** دالة `_login()` أيضاً بدون `await` ولا توجيه يدوي.

#### C9: 🔴 `AuthService::register()` في Laravel — الـ Response لا يتضمن بنية واضحة
- **الملف:** [AuthController.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Http/Controllers/Api/V1/AuthController.php)
- **المشكلة:** الـ response يُرسل `user` ملفوفاً بـ `UserResource` (الذي يضيف wrapper `data`). الـ Flutter يستخدم `_unwrapUser()` لفك الغلاف. لكن إذا تغيّر هيكل الـ response، الـ `UserModel.fromJson()` سيفشل بصمت (default values) بدون أي خطأ مرئي.

---

### 🟡 مشاكل متوسطة (10)

#### M1: لا يوجد التحقق من حالة المستخدم (is_verified) عند الاستخدام
- **المشكلة:** `AuthService::login()` يتحقق فقط من `is_active` ولا يتحقق من `is_verified`. المستخدمون غير المتحققين يمكنهم تسجيل الدخول بشكل طبيعي. الـ Factory ينشئ 30% من المستخدمين غير متحققين لكن لا فرق في السلوك.

#### M2: لا يوجد Role-Based Authorization على routes المستخدم العادي
- **المشكلة:** أي مستخدم مسجّل (BUYER/SELLER/AGENT/TENANT/LANDLORD) يمكنه الوصول لنفس الـ routes. مثال: BUYER يمكنه إنشاء عقار (`POST /properties`) رغم أنه مشتري فقط. لا يوجد middleware لفحص الدور باستثناء `admin`.

#### M3: PropertySeeder - `agent_id` قد يكون null مع null-coalescing خاطئ
- **الملف:** [PropertySeeder.php:23](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/seeders/PropertySeeder.php#L23)
- **المشكلة:** `$agents->random()->id ?? null` - إذا كانت المجموعة فارغة ستحصل على Exception. الصحيح: `$agents->isEmpty() ? null : $agents->random()->id`

#### M4: تعارض Favorites Routes
- **الملف:** [api.php:70-72](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/routes/api.php#L70-L72)
- **المشكلة:** `apiResource('favorites')` مع `except(['update', 'show'])` ينشئ `DELETE /favorites/{favorite}` (بالـ favorite ID)، لكن يوجد أيضاً `DELETE /favorites/{propertyId}` (بالـ property ID). هذا يسبب **تعارض routes** لأن كلاهما `DELETE /favorites/{param}`.

#### M5: `ImageService::deletePropertyImage()` لا يحذف الملف الفعلي
- **الملف:** [ImageService.php:36-39](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Services/ImageService.php#L36-L39)
- **المشكلة:** يحذف السجل من قاعدة البيانات فقط بدون حذف الملف الفعلي من التخزين. يسبب تراكم ملفات يتيمة.

#### M6: `ImageService::uploadPropertyImage()` - URL مكرر
- **الملف:** [ImageService.php:29-30](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Services/ImageService.php#L29-L30)
- **المشكلة:** `url(Storage::disk('public')->url($path))` — `Storage::url()` تُرجع URL كاملاً عادةً، و `url()` تلفّه بـ URL آخر. قد يُنتج: `http://host/http://host/storage/...`

#### M7: `Notification` Model مخصص يتعارض مع Laravel Notifications
- **المشكلة:** المشروع يعرّف Model `Notification` مخصص و User يستخدم `Notifiable` trait. هذا قد يسبب تعارض مع نظام Laravel الافتراضي للإشعارات.

#### M8: `SearchService` - عدم تعقيم مدخلات `sort_by`
- **الملف:** [SearchService.php:66-69](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Services/SearchService.php#L66-L69)
- **المشكلة:** `$sortBy = $filters['sort_by']` يُمرر مباشرة لـ `orderBy()` بدون Whitelist. هذا يسمح بـ **SQL Injection** عبر اسم العمود.

#### M9: `ConversationController::markAsRead` بدون التحقق من ملكية المحادثة
- **الملف:** [ConversationController.php:87-97](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Http/Controllers/Api/V1/ConversationController.php#L87-L97)
- **المشكلة:** يجد المحادثة بـ `findOrFail($id)` بدون التحقق أن المستخدم الحالي هو أحد المشاركين. أي مستخدم يمكنه تعليم رسائل أي محادثة كمقروءة.

#### M10: `fullText` Index في Properties Migration غير مدعوم على SQLite
- **الملف:** [properties migration:57](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/migrations/2026_04_15_081856_create_properties_table.php#L57)
- **المشكلة:** يوجد `database.sqlite` في مجلد `database/` مما يشير لاحتمال استخدام SQLite للتطوير. الـ `fullText` index غير مدعوم على SQLite ويسبب خطأ.

---

### 🔵 مشاكل تحسينية (8)

#### I1: لا يوجد Rate Limiting على routes حساسة
- Login, Register, Forgot Password بدون حماية من brute force.

#### I2: لا يوجد Email Verification فعلي
- الحقل `email_verified_at` موجود لكن لا يوجد آلية إرسال إيميل تحقق ولا التحقق منه.

#### I3: `AuditService` و `AuditLog` Model موجودان لكن **غير مستخدمين**
- لا يوجد أي استدعاء لـ `AuditService` في أي Controller.

#### I4: لا يوجد CORS Configuration واضح
- للعمل مع Flutter mobile يجب إعداد CORS بشكل صحيح.

#### I5: `FCMService` موجود لكن غير مكتمل
- الخدمة موجودة لكن لا يتم إرسال إشعارات فعلياً عند أي حدث.

#### I6: TENANT و LANDLORD بدون منطق
- أدوار معرّفة بدون أي routes أو business logic.

#### I7: لا يوجد API Documentation (Swagger/OpenAPI)
- 50+ endpoint بدون توثيق API.

#### I8: لا يوجد Tests
- مجلد `tests/` موجود لكن فارغ عملياً.

---

## User Review Required

> [!IMPORTANT]
> **قرارات تحتاج رأيك قبل البدء:**
> 1. هل تريد **إزالة** `spatie/laravel-permission` و `spatie/laravel-activitylog` (غير مستخدمتين)، أم تريد **تفعيلهما** فعلياً؟
> 2. هل أدوار `TENANT` و `LANDLORD` مطلوبة حالياً؟ أم نحذفها مؤقتاً ونضيفها لاحقاً عند الحاجة؟
> 3. هل تريد إضافة Role-Based Middleware (مثل: BUYER لا يستطيع إنشاء عقارات)؟

## Open Questions

> [!WARNING]
> 1. قاعدة البيانات: أنت تستخدم **MySQL** في `.env` لكن يوجد `database.sqlite`. أيهما المطلوب فعلياً؟
> 2. هل تريد لوحة تحكم ويب للأدمن أم تكتفي بـ API + Flutter؟

---

## 🔨 خطة الإصلاح المقترحة

### المرحلة 1: إصلاحات حرجة (تمنع التشغيل) ⏱️ ~30 دقيقة

---

#### [MODIFY] [DatabaseSeeder.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/seeders/DatabaseSeeder.php)
- إزالة إنشاء Admin المباشر (نقله لـ UserSeeder فقط)
- إزالة SystemSettings المباشرة (استدعاء SystemSettingSeeder بدلاً منها)
- إضافة `SystemSettingSeeder` للقائمة

#### [MODIFY] [UserSeeder.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/seeders/UserSeeder.php)
- توحيد إنشاء Admin مع كلمة مرور واضحة ومعروفة
- إزالة التشفير المزدوج

#### [MODIFY] [SystemSettingSeeder.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/seeders/SystemSettingSeeder.php)
- تصحيح أسماء الأعمدة لتتوافق مع Migration (`value_type` بدل `type`، إزالة `group`)

#### [MODIFY] [system_settings migration](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/migrations/2026_04_15_083051_create_system_settings_table.php)
- إضافة أعمدة `group` و `description` المفقودة

#### [MODIFY] [SystemSetting.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Models/SystemSetting.php)
- تصحيح `fillable` ليتوافق مع الأعمدة الفعلية

#### [MODIFY] [AdminController.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Http/Controllers/Api/V1/AdminController.php)
- تصحيح `DATE_TRUNC` → `DATE_FORMAT` لتوافق MySQL
- تصحيح `pendingProperties()` لاستخدام `PropertyCollection`

#### [MODIFY] [PropertySeeder.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/database/seeders/PropertySeeder.php)
- إصلاح `agent_id` null handling

---

### المرحلة 2: إصلاحات أمنية ومنطقية ⏱️ ~45 دقيقة

---

#### [MODIFY] [SearchService.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Services/SearchService.php)
- إضافة Whitelist لأعمدة الفرز (منع SQL Injection)

#### [MODIFY] [ConversationController.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Http/Controllers/Api/V1/ConversationController.php)
- إضافة التحقق من ملكية المحادثة في `markAsRead`

#### [MODIFY] [ImageService.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Services/ImageService.php)
- حذف الملفات الفعلية عند حذف الصور
- إصلاح URL المكرر

#### [MODIFY] [api.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/routes/api.php)
- إصلاح تعارض Favorites routes
- إضافة Rate Limiting على auth routes

#### [NEW] RoleMiddleware.php
- إنشاء middleware لفحص الأدوار على routes حساسة (SELLER/AGENT فقط يمكنهم إنشاء عقارات)

#### [MODIFY] [bootstrap/app.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/bootstrap/app.php)
- تسجيل RoleMiddleware الجديد

---

### المرحلة 3: تنظيف وتحسين ⏱️ ~30 دقيقة

---

#### [MODIFY] [composer.json](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/composer.json)
- إزالة الحزم غير المستخدمة (`spatie/laravel-permission`, `spatie/laravel-activitylog`) — بناءً على موافقتك

#### [MODIFY] [AuthService.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Services/AuthService.php)
- إضافة فحص `is_verified` اختياري

#### إنشاء Agent.md و UserReport.md
- توثيق المشروع والتغييرات

---

### المرحلة 4: إصلاح مسار التسجيل (Flutter ↔ Laravel) ⏱️ ~40 دقيقة

> [!CAUTION]
> هذه المرحلة تحل المشكلة المباشرة: "التسجيل ينجح لكن لا توجيه"

---

#### [NEW] [auth_listenable.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/core/router/auth_listenable.dart)
- إنشاء `AuthChangeNotifier` يربط `authProvider` بـ `ChangeNotifier` لاستخدامه كـ `refreshListenable` في GoRouter
```dart
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
```

#### [MODIFY] [app_router.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/core/router/app_router.dart)
- إضافة `refreshListenable: authChangeNotifier` لـ `GoRouter`
- هذا يجعل GoRouter يُعيد تقييم `redirect` تلقائياً عند تغيّر حالة المصادقة

#### [MODIFY] [app.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/app.dart)
- تحديث `routerProvider` ليمرر `AuthChangeNotifier` لـ `createRouter`

#### [MODIFY] [register_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/auth/screens/register_screen.dart)
- إضافة `ref.listen(authProvider, ...)` في `build()` لمراقبة حالة المصادقة
- عند `isAuthenticated == true` → `context.go(RouteNames.home)`
- عند وجود `error` → عرض `SnackBar` بالخطأ
- تحويل `_register()` إلى `async` مع `await`

#### [MODIFY] [login_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/auth/screens/login_screen.dart)
- نفس إصلاحات RegisterScreen: إضافة `ref.listen` + `await`
- توجيه إلى `/` بعد نجاح تسجيل الدخول

#### [MODIFY] [auth_guard.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/core/router/auth_guard.dart)
- تحسين منطق التوجيه: إضافة فحص دور المستخدم (ADMIN → `/admin`)

---

## ✅ خطة التحقق

### اختبارات أوتوماتيكية
```bash
# 1. اختبار الـ Migrations والـ Seeders
php artisan migrate:fresh --seed

# 2. اختبار Health Check
curl http://localhost:8000/api/v1/health

# 3. اختبار تسجيل الدخول بحساب الأدمن
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@dealak.com","password":"Admin123"}'

# 4. اختبار لوحة الأدمن
curl http://localhost:8000/api/v1/admin/dashboard \
  -H "Authorization: Bearer <token>"

# 5. اختبار التقارير (بعد إصلاح DATE_TRUNC)
curl http://localhost:8000/api/v1/admin/reports \
  -H "Authorization: Bearer <token>"
```

### اختبار يدوي
- تسجيل مستخدم جديد بكل دور
- محاولة الوصول لـ routes محظورة (BUYER يحاول الوصول لـ admin)
- رفع صور واختبار الحذف

### اختبار مسار التسجيل (Flutter)
```
1. فتح التطبيق → يجب أن يظهر شاشة Login
2. الضغط على "إنشاء حساب جديد" → شاشة Register
3. ملء البيانات + اختيار الدور → الضغط على "إنشاء حساب"
4. ✅ يجب التوجيه تلقائياً إلى الصفحة الرئيسية
5. إغلاق التطبيق وإعادة فتحه → يبقى مسجلاً
6. تسجيل الخروج → يعود لشاشة Login
7. تسجيل الدخول بالحساب الجديد → توجيه للرئيسية
8. تسجيل بحساب Admin → توجيه لـ /admin
```
