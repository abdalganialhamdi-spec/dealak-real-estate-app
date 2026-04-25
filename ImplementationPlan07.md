# Implementation Plan 07 - إصلاح واجهات الأدوار (مدير / وكيل عقارات)

## تاريخ: 2026-04-25

---

## ملخص المشكلة

بعد تسجيل الدخول كـ **مدير (ADMIN)** أو **وكيل عقارات (AGENT)**، لا تظهر واجهات مخصصة حسب الدور:

- **المدير**: لوحة التحكم موجودة لكنها ناقصة — لا يوجد قسم إدارة المستخدمين بشكل كامل (CRUD)، ولا إحصائيات الفوترة والمحاسبة، والأزرار "المستخدمين" و"التقارير" فارغة (`onTap: () {}`)
- **الوكيل/التاجر**: نفس واجهة المستخدم العادي تمامًا — لا شاشة خاصة ولا خيارات إضافية في البروفايل
- **البروفايل**: لا يعرض خيارات حسب الدور — كل المستخدمين يرون نفس القائمة

---

## تحليل الوضع الحالي

### ✅ ما يعمل في الباك إند (Laravel)
| العنصر | الحالة | الملاحظات |
|--------|--------|-----------|
| Middleware `admin` | ✅ يعمل | يتحقق من `user->isAdmin()` |
| Middleware `role` | ✅ يعمل | يتحقق من `user->role in roles` |
| `/admin/dashboard` | ✅ يعمل | يرجع إحصائيات عامة |
| `/admin/users` | ✅ يعمل | ينقل قائمة المستخدمين |
| `/admin/users/{id}/status` | ✅ يعمل | تفعيل/تعطيل مستخدم |
| `/admin/properties` CRUD | ✅ يعمل | إضافة/تعديل/حذف عقار |
| `/admin/reports` | ✅ يعمل | تقارير شهرية + حسب المدينة + حسب النوع |
| `/deals` + `/deals/{id}/payments` | ✅ يعمل | الصفقات والمدفوعات |
| User roles | ✅ مُعرّفة | `ADMIN`, `AGENT`, `SELLER`, `BUYER` |

### ❌ المشاكل في Flutter

| المشكلة | الملف | التفاصيل |
|---------|------|----------|
| بروفايل موحد لجميع الأدوار | `profile_screen.dart` | لا يوجد أي تحقق من `user.role` |
| زر "المستخدمين" فارغ | `admin_dashboard_screen.dart:159` | `onTap: () {}` — لا يفعل شيئاً |
| زر "التقارير" فارغ | `admin_dashboard_screen.dart:169` | `onTap: () {}` — لا يفعل شيئاً |
| لا توجد إحصائيات فوترة | `admin_dashboard_screen.dart` | Dashboard يعرض فقط 4 أرقام بسيطة |
| لا توجد شاشة إدارة مستخدمين | غير موجودة | الباك إند جاهز لكن لا شاشة |
| لا توجد شاشة تقارير مالية | غير موجودة | الباك إند جاهز لكن لا شاشة |
| لا توجد واجهة مخصصة للوكيل | لا توجد أصلاً | AGENT يرى نفس واجهة BUYER |
| Bottom Nav ثابت | `app_bottom_nav.dart` | نفس القائمة لكل الأدوار |
| Home Screen لا يتغير | `home_screen.dart` | نفس المحتوى بغض النظر عن الدور |

---

## التغييرات المطلوبة

### المرحلة 1: إصلاح شاشة البروفايل حسب الدور

#### [MODIFY] `dealak_flutter/lib/features/profile/screens/profile_screen.dart`

إعادة بناء `ProfileScreen` ليعرض خيارات مختلفة حسب `user.role`:

**للمدير (ADMIN):**
- لوحة التحكم → `/admin`
- إدارة العقارات → `/admin/properties`
- إدارة المستخدمين → `/admin/users` **(جديد)**
- التقارير والإحصائيات → `/admin/reports` **(جديد)**
- الإعدادات

**للوكيل (AGENT):**
- عقاراتي (المُدارة) → `/my-properties`
- صفقاتي → `/deals`
- طلبات العملاء → `/requests`
- إحصائياتي → `/agent/stats` **(جديد)**
- الإشعارات
- الإعدادات

**للبائع (SELLER):**
- عقاراتي → `/my-properties`
- صفقاتي → `/deals`
- الطلبات → `/requests`
- الإشعارات
- الإعدادات

**للمشتري (BUYER):**
- صفقاتي → `/deals`
- طلباتي → `/requests`
- الإشعارات
- الإعدادات

---

### المرحلة 2: شاشة إدارة المستخدمين (Admin)

#### [NEW] `dealak_flutter/lib/features/admin/screens/admin_users_screen.dart`

شاشة كاملة لإدارة المستخدمين تتضمن:
- قائمة مستخدمين مع بحث وفلترة حسب الدور (`ADMIN`, `AGENT`, `SELLER`, `BUYER`)
- عرض: الاسم، البريد، الدور، حالة التفعيل، تاريخ الإنشاء
- إجراءات: تفعيل/تعطيل مستخدم (`PUT /admin/users/{id}/status`)
- بطاقات إحصائية أعلى الشاشة (إجمالي المستخدمين حسب كل دور)

الـ API جاهز بالكامل: `AdminController@users` و `AdminController@updateUserStatus`

---

### المرحلة 3: شاشة التقارير والإحصائيات المالية (Admin)

#### [NEW] `dealak_flutter/lib/features/admin/screens/admin_reports_screen.dart`

شاشة تقارير شاملة تعرض:

**إحصائيات الفوترة والمحاسبة:**
- إجمالي الإيرادات (من `dashboard.total_revenue`)
- عدد الصفقات المكتملة vs الجارية
- إيرادات شهرية (من `reports.monthly_deals`) — رسم بياني شريطي بسيط
- إجمالي العمولات

**إحصائيات العقارات:**
- توزيع العقارات حسب المدينة (من `reports.properties_by_city`)
- توزيع العقارات حسب النوع (من `reports.properties_by_type`)

الـ API جاهز: `AdminController@reports` + `AdminController@dashboard`

---

### المرحلة 4: تحسين لوحة تحكم المدير

#### [MODIFY] `dealak_flutter/lib/features/admin/screens/admin_dashboard_screen.dart`

- **إصلاح الأزرار الفارغة:**
  - زر "المستخدمين" → يفتح `AdminUsersScreen`
  - زر "التقارير" → يفتح `AdminReportsScreen`
- **إضافة بطاقات إحصائيات مالية:**
  - إجمالي الإيرادات (`total_revenue`)
  - الصفقات الجارية (`active_deals`)
  - العقارات المتاحة (`available_properties`)
- **إضافة قسم تحذيرات:** عقارات قيد المراجعة (pending) مع إجراء سريع للموافقة

---

### المرحلة 5: واجهة مخصصة لوكيل العقارات (AGENT)

#### [NEW] `dealak_flutter/lib/features/admin/screens/agent_dashboard_screen.dart`

شاشة رئيسية مخصصة للوكيل تعرض:
- عدد العقارات المُدارة (من `/properties/my`)
- صفقاته الأخيرة (من `/deals`)
- طلبات العملاء الجديدة (من `/requests`)
- إجراءات سريعة: إضافة عقار، عرض الصفقات، عرض الطلبات
- إشعارات غير مقروءة

#### [NEW] `dealak_flutter/lib/features/admin/screens/agent_stats_screen.dart`

شاشة إحصائيات خاصة بالوكيل:
- عدد العقارات المُباعة/المُؤجرة
- إجمالي العمولات (من الصفقات)
- ملخص الأداء الشهري

---

### المرحلة 6: تحديث نظام التنقل حسب الدور

#### [MODIFY] `dealak_flutter/lib/shared/widgets/app_bottom_nav.dart`

تحديث Bottom Navigation ليكون ديناميكيًا حسب الدور:

**المدير (ADMIN):**
| أيقونة | التسمية | المسار |
|--------|---------|--------|
| dashboard | لوحة التحكم | `/admin` |
| home_work | العقارات | `/admin/properties` |
| people | المستخدمين | `/admin/users` |
| analytics | التقارير | `/admin/reports` |
| person | حسابي | `/profile` |

**الوكيل (AGENT):**
| أيقونة | التسمية | المسار |
|--------|---------|--------|
| home | الرئيسية | `/` |
| home_work | عقاراتي | `/my-properties` |
| handshake | صفقاتي | `/deals` |
| chat | الرسائل | `/conversations` |
| person | حسابي | `/profile` |

**المشتري/البائع:**
يبقى كما هو (الرئيسية، بحث، المفضلة، الرسائل، حسابي)

#### [MODIFY] `dealak_flutter/lib/core/router/app_router.dart`

- إضافة مسارات جديدة: `/admin/users`, `/admin/reports`, `/agent/stats`
- إضافة ShellRoute مخصص للمدير (مع Bottom Nav مختلف)

#### [MODIFY] `dealak_flutter/lib/core/router/route_names.dart`

إضافة مسارات جديدة:
```dart
static const String adminUsers = '/admin/users';
static const String adminReports = '/admin/reports';
static const String agentDashboard = '/agent';
static const String agentStats = '/agent/stats';
```

---

### المرحلة 7: تحديث Auth Guard

#### [MODIFY] `dealak_flutter/lib/core/router/auth_guard.dart`

- المدير → يُوجه إلى `/admin` (يعمل حاليًا ✅)
- الوكيل → يُوجه إلى `/` (الرئيسية) مع واجهة مخصصة
- حماية مسارات `/admin/*` من غير المدراء
- حماية مسارات `/agent/*` من غير الوكلاء

---

## الملفات المتأثرة (ملخص)

### ملفات جديدة (4 ملفات):
| الملف | الوصف |
|-------|-------|
| `features/admin/screens/admin_users_screen.dart` | إدارة المستخدمين CRUD |
| `features/admin/screens/admin_reports_screen.dart` | تقارير وإحصائيات مالية |
| `features/admin/screens/agent_dashboard_screen.dart` | لوحة تحكم الوكيل |
| `features/admin/screens/agent_stats_screen.dart` | إحصائيات الوكيل |

### ملفات معدلة (6 ملفات):
| الملف | التعديل |
|-------|---------|
| `features/profile/screens/profile_screen.dart` | خيارات ديناميكية حسب الدور |
| `features/admin/screens/admin_dashboard_screen.dart` | إصلاح الأزرار الفارغة + إحصائيات مالية |
| `shared/widgets/app_bottom_nav.dart` | Bottom Nav ديناميكي حسب الدور |
| `core/router/app_router.dart` | مسارات جديدة + ShellRoutes |
| `core/router/route_names.dart` | أسماء المسارات الجديدة |
| `core/router/auth_guard.dart` | حماية المسارات حسب الدور |

### الباك إند (0 تعديلات):

> **لا يحتاج الباك إند لأي تعديل!** جميع الـ APIs المطلوبة جاهزة ومكتملة:
> - `GET /admin/dashboard` — إحصائيات شاملة مع `total_revenue`, `active_deals`
> - `GET /admin/users` — قائمة المستخدمين مع بحث وفلترة
> - `PUT /admin/users/{id}/status` — تفعيل/تعطيل مستخدم
> - `GET /admin/reports` — تقارير شهرية + حسب المدينة + حسب النوع
> - `GET /deals` — صفقات المستخدم الحالي
> - `GET /deals/{id}/payments` — مدفوعات صفقة محددة

---

## ترتيب التنفيذ

1. **المرحلة 1** — إصلاح البروفايل حسب الدور (أساسي + سريع)
2. **المرحلة 6** — تحديث RouteNames + Router + Auth Guard (بنية تحتية)
3. **المرحلة 2** — شاشة إدارة المستخدمين
4. **المرحلة 3** — شاشة التقارير المالية
5. **المرحلة 4** — تحسين Dashboard المدير
6. **المرحلة 5** — واجهة الوكيل المخصصة
7. **المرحلة 7** — تحديث Bottom Nav (آخر خطوة لتجنب كسر التنقل)

---

## خطة التحقق

### اختبارات يدوية
1. تسجيل دخول بمستخدم `ADMIN` → التحقق من ظهور لوحة التحكم الكاملة مع إحصائيات مالية
2. فتح "إدارة المستخدمين" → التحقق من عرض القائمة + البحث + تفعيل/تعطيل
3. فتح "التقارير" → التحقق من عرض الإحصائيات الشهرية والتوزيعات
4. تسجيل دخول بمستخدم `AGENT` → التحقق من واجهة مخصصة مع صفقات وعقارات
5. تسجيل دخول بمستخدم `BUYER` → التحقق من بقاء الواجهة العادية كما هي
6. التحقق من أن Bottom Nav يتغير حسب الدور
7. التحقق من حماية المسارات (مشتري لا يستطيع الوصول لـ `/admin`)

### تحليل الكود
```bash
cd dealak_flutter && flutter analyze
```

---

## ملاحظات مهمة

**الأدوار المعتمدة في النظام:**
- `ADMIN` — مدير النظام (صلاحيات كاملة)
- `AGENT` — وكيل/تاجر عقارات (إدارة عقارات + صفقات)
- `SELLER` — بائع عقار (إدارة عقاراته فقط)
- `BUYER` — مشتري/مستأجر (بحث + مفضلة + طلبات)

**يجب أن يبقى `user.role` محفوظًا في `SecureStorage` بعد تسجيل الدخول** — وهذا يعمل حاليًا ✅ (الكود موجود في `auth_repository.dart:24-26`)

**لا تعدّل أي ملف في الباك إند.** جميع الـ APIs جاهزة ولا تحتاج تعديل. التركيز فقط على Flutter.
