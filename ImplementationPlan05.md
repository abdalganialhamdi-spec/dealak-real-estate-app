# 🔍 ImplementationPlan05 — تدقيق الربط بين Flutter و Laravel (المصادقة)

**التاريخ:** 2026-04-25
**الهدف:** إصلاح جميع المشاكل في ربط Flutter ↔ Laravel خصوصاً التسجيل وتسجيل الدخول

---

## 📊 نتيجة التدقيق الشامل

### ✅ ما تم إصلاحه سابقاً (مطبّق فعلاً في الكود)

| الإصلاح | الحالة |
|---------|--------|
| `JsonResource::withoutWrapping()` في AppServiceProvider | ✅ مطبّق |
| `_unwrapUser()` في auth_repository.dart | ✅ مطبّق |
| Password validator يطابق Laravel (8 + uppercase + lowercase + digit) | ✅ مطبّق |
| UserFactory يستخدم `first_name`/`last_name` بدل `name` | ✅ مطبّق |
| UserSeeder بدون `Hash::make()` (يعتمد على hashed cast) | ✅ مطبّق |
| resetPassword بدون double hashing | ✅ مطبّق |
| DatabaseSeeder يستدعي كل الـ Seeders | ✅ مطبّق |
| `_extractError()` لعرض validation errors تفصيلية | ✅ مطبّق |
| API interceptor مع محاولة refresh قبل الطرد | ✅ مطبّق |

---

## 🚨 المشاكل المتبقية (7 مشاكل مكتشفة)

---

### 🔴 BUG #1 — UserFactory: Double Hashing (CRITICAL)

**الملف:** `dealak-backend/database/factories/UserFactory.php` — سطر 24

**المشكلة:** الـ UserFactory يستخدم `Hash::make('Password1')` لكن الـ User model فيه `'password' => 'hashed'` cast → **كلمة المرور تُشفّر مرتين** → المستخدمين المُنشأين بالـ factory لا يستطيعون تسجيل الدخول!

```php
// ❌ الحالي (سطر 24):
'password' => static::$password ??= Hash::make('Password1'),

// ✅ الصحيح:
'password' => static::$password ??= 'Password1',
```

**التأثير:** كل المستخدمين المُنشأين بالـ factory (60 مستخدم: 10 agents + 20 sellers + 30 buyers) لا يمكنهم تسجيل الدخول.

---

### 🔴 BUG #2 — Login يرفض المستخدم الجديد: `is_verified = false` (CRITICAL)

**الملف:** `dealak-backend/app/Services/AuthService.php` — سطر 38-40

**المشكلة:** عند التسجيل، `is_verified` الافتراضي = `false`. وعند تسجيل الدخول، الـ AuthService يتحقق:

```php
if (!$user->is_verified && $user->role !== 'ADMIN') {
    abort(403, 'يرجى تأكيد بريدك الإلكتروني أولاً');
}
```

**لكن:** لا يوجد نظام تأكيد بريد إلكتروني في المشروع! → **المستخدم يسجل حساب جديد → يحاول تسجيل الدخول → يُرفض بـ 403** → هذا هو "خطأ الخادم" الذي ظهر!

**الحل — خياران:**

**الخيار أ (الأسرع — موصى به للتطوير):** جعل المستخدم verified تلقائياً عند التسجيل:
```php
// AuthService.php → register()
$user = User::create([
    ...
    'is_verified' => true,  // ← إضافة هذا
]);
```

**الخيار ب (الأفضل للإنتاج):** تعطيل فحص التحقق مؤقتاً حتى بناء نظام Email Verification:
```php
// AuthService.php → login()
// إزالة أو تعليق هذا الشرط مؤقتاً:
// if (!$user->is_verified && $user->role !== 'ADMIN') { ... }
```

---

### 🔴 BUG #3 — Flutter لا يتعامل مع HTTP 401/403 من login بشكل صحيح (CRITICAL)

**الملف:** `dealak_flutter/lib/data/repositories/auth_repository.dart` — سطر 101-108

**المشكلة:** عندما يُرجع Laravel `abort(401)` أو `abort(403)` من `AuthService::login()`:
- `401` → Flutter يرمي `UnauthorizedException` → رسالة "غير مصرح، يرجى تسجيل الدخول" (مضللة!)
- `403` → Flutter يرمي `ForbiddenException` → رسالة "غير مصرح بهذا الإجراء" (لا توضح السبب!)

**لكن** Laravel يُرسل رسالة خطأ عربية واضحة في الـ response body. Flutter لا يقرأها!

```dart
// ❌ الحالي:
case 401: return UnauthorizedException();  // رسالة ثابتة عامة
case 403: return ForbiddenException();      // رسالة ثابتة عامة

// ✅ الصحيح — قراءة رسالة الخطأ من Laravel:
ApiException _handleError(DioException e) {
  final data = e.response?.data;
  final serverMessage = (data is Map) ? (data['message'] ?? data['error']) : null;
  
  switch (e.response?.statusCode) {
    case 401:
      return ApiException(
        message: serverMessage?.toString() ?? 'بيانات الدخول غير صحيحة',
        statusCode: 401,
      );
    case 403:
      return ApiException(
        message: serverMessage?.toString() ?? 'غير مصرح بهذا الإجراء',
        statusCode: 403,
      );
    case 404: return NotFoundException();
    case 422: return ValidationException(data?['errors'] ?? {});
    default:
      return ApiException(
        message: serverMessage?.toString() ?? 'خطأ في الخادم',
        statusCode: e.response?.statusCode,
      );
  }
}
```

---

### 🟠 BUG #4 — API Interceptor يطرد المستخدم عند 401 من login (HIGH)

**الملف:** `dealak_flutter/lib/core/network/api_interceptor.dart` — سطر 19-44

**المشكلة:** عند فشل تسجيل الدخول (401)، الـ interceptor يحاول refresh (يفشل) → **يمسح كل البيانات** (`clearAll()`). هذا ليس خطيراً لأن المستخدم لم يسجل دخول أصلاً، لكنه يسبب سلوك غريب.

**الحل:** استثناء مسارات auth من منطق الـ refresh:

```dart
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401 && !_isAuthRoute(err.requestOptions)) {
    // ... refresh logic فقط للمسارات المحمية
  }
  handler.next(err);
}

bool _isAuthRoute(RequestOptions options) {
  return options.path.contains('/auth/login') || 
         options.path.contains('/auth/register');
}
```

---

### 🟠 BUG #5 — `ApiEndpoints.baseUrl` ثابت ولا يتأثر بإعدادات المستخدم (HIGH)

**الملف:** `dealak_flutter/lib/core/constants/api_endpoints.dart` — سطر 2-5

**المشكلة:** `baseUrl` مُعرّف كـ `const` من environment variable. لكن `DioClient` يُنشأ مرة واحدة كـ `Provider` في `auth_provider.dart`. عندما المستخدم يغير الـ API settings في `app_with_api_config.dart`، يتم استدعاء `updateBaseUrl()` — **لكن** إذا كان الـ DioClient أُنشئ قبل ذلك، قد لا يتم تحديثه بشكل صحيح في كل الـ repositories.

**الوضع الحالي:** `app_with_api_config.dart` يستدعي `dioClient.updateBaseUrl(prefs.baseUrl)` عند التهيئة — هذا يعمل **فقط إذا** تم تشغيل التهيئة قبل أي طلب API.

**التحقق المطلوب:** التأكد أن `_initPrefs()` تنتهي قبل عرض أي شاشة تستدعي API.

> [!NOTE]
> هذا **ليس bug مباشر** لكن قد يسبب مشاكل إذا تغير ترتيب التنفيذ.

---

### 🟡 BUG #6 — register لا يُرسل `password_confirmation` (LOW)

**الملف:** `dealak_flutter/lib/features/auth/screens/register_screen.dart`

**المشكلة:** لا يوجد حقل تأكيد كلمة المرور. Laravel لا يطلبه حالياً (`RegisterRequest` لا يحتوي `confirmed` rule) — لكنه ممارسة سيئة لتجربة المستخدم.

**الحل:** إضافة حقل `confirmPassword` في شاشة التسجيل.

---

### 🟡 BUG #7 — UserResource: `whenCounted` يُرجع null دائماً في auth (LOW)

**الملف:** `dealak-backend/app/Http/Resources/UserResource.php` — سطر 24-25

**المشكلة:** `whenCounted('properties')` و `whenCounted('reviews')` تُرجع قيمة فقط مع `withCount()`. Auth endpoints لا تستخدمها → دائماً `null`.

**التأثير:** Flutter `UserModel` يتعامل مع `null` بشكل طبيعي (nullable fields). **لا يسبب crash** لكن يرسل بيانات فارغة.

---

## 📋 الملفات المطلوب تعديلها

### Laravel (2 ملفات)

| # | الملف | التعديل | الأولوية |
|---|-------|---------|----------|
| 1 | `database/factories/UserFactory.php` | إزالة `Hash::make()` | 🔴 CRITICAL |
| 2 | `app/Services/AuthService.php` | إضافة `is_verified => true` عند التسجيل | 🔴 CRITICAL |

### Flutter (2 ملفات)

| # | الملف | التعديل | الأولوية |
|---|-------|---------|----------|
| 3 | `lib/data/repositories/auth_repository.dart` | تحسين `_handleError()` لقراءة رسائل Laravel | 🔴 CRITICAL |
| 4 | `lib/core/network/api_interceptor.dart` | استثناء auth routes من refresh | 🟠 HIGH |

---

## 🚀 خطة التنفيذ

```
المرحلة 1: إصلاحات حرجة (CRITICAL) — تحل مشكلة "خطأ الخادم"
  ├── 1.1 UserFactory.php — إزالة Hash::make()
  ├── 1.2 AuthService.php — إضافة is_verified => true
  ├── 1.3 auth_repository.dart — تحسين _handleError()
  └── 1.4 api_interceptor.dart — استثناء auth routes

المرحلة 2: تشغيل php artisan migrate:fresh --seed
  └── إعادة بناء قاعدة البيانات

المرحلة 3: التحقق
  ├── 3.1 تسجيل حساب جديد بكلمة مرور Test1234
  ├── 3.2 تسجيل دخول بنفس الحساب
  ├── 3.3 تسجيل دخول بحساب factory (buyer1@example.com)
  └── 3.4 التأكد من ظهور رسائل الخطأ العربية
```

---

## 🎯 السبب الرئيسي لخطأ "خطأ في الخادم"

> [!IMPORTANT]
> **السبب المؤكد:** عند إنشاء حساب جديد عبر Flutter → التسجيل ينجح (201) → المستخدم يحاول تسجيل الدخول لاحقاً أو يتم استدعاء `checkAuth()` → Laravel يرفضه بـ **403** لأن `is_verified = false` ولا يوجد نظام تأكيد بريد.
>
> Flutter يستقبل 403 → `ForbiddenException` → رسالة عامة "غير مصرح بهذا الإجراء" أو يُعالج كـ "خطأ في الخادم".

> [!WARNING]
> **BUG #1 (UserFactory double hashing):** يؤثر فقط على المستخدمين المُنشأين بالـ Seeder. لا يؤثر على التسجيل اليدوي عبر Flutter.

---

## ✅ Verification Checklist

- [ ] `UserFactory.php` — `password` بدون `Hash::make()`
- [ ] `AuthService.php` — مستخدم جديد يكون `is_verified = true`
- [ ] `auth_repository.dart` — رسائل خطأ واضحة من Laravel
- [ ] `api_interceptor.dart` — لا يتدخل في auth routes
- [ ] `php artisan migrate:fresh --seed` ينجح
- [ ] تسجيل حساب → نجاح
- [ ] تسجيل دخول → نجاح ويوجه للصفحة الرئيسية
- [ ] تسجيل دخول بكلمة مرور خاطئة → رسالة "بيانات الدخول غير صحيحة"

## Open Questions

> [!IMPORTANT]
> **هل تريد تفعيل نظام تأكيد البريد الإلكتروني لاحقاً؟** إذا نعم، سنجعل `is_verified = true` مؤقتاً مع ترك البنية جاهزة. إذا لا، سنزيل فحص `is_verified` نهائياً من `login()`.
