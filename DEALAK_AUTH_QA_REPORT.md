# 🔍 تقرير فحص المصادقة — DEALAK QA

**التاريخ:** 2026-04-15  
**النطاق:** Flutter ↔ Laravel Auth API — سطر سطر  
**الحالة:** 🚨 5 أخطاء حرجة مكتشفة

---

## 📋 تتبع المسار الكامل

### REGISTER FLOW (تسجيل)
```
Flutter: register_screen.dart
  → validators.dart (password: 8+ chars, uppercase, lowercase, digit)
  → auth_provider.dart (AuthNotifier.register)
  → auth_repository.dart (POST /auth/register)
  → dio_client.dart (http://10.183.151.121:8000/api/v1/auth/register)
  → ApiInterceptor (يضيف Bearer token)

Laravel: routes/api.php → AuthController@register
  → RegisterRequest (first_name*, last_name*, email*, phone?, password*, role?)
  → AuthService@register (User::create → hashed cast)
  → Sanctum token (abilities: [role])
  → Response 201: {message, user: UserResource, token}

Flutter: auth_repository.dart
  → saveToken(data['token'])
  → _unwrapUser(data['user']) → UserModel.fromJson()
  → auth_provider.dart → state = AuthState(user, isAuthenticated: true)
```

### LOGIN FLOW (تسجيل دخول)
```
Flutter: login_screen.dart
  → validator: required فقط (بدون تعقيد)
  → POST /auth/login {email, password}

Laravel: AuthController@login
  → LoginRequest (email*, password*)
  → AuthService@login (Hash::check → hashed cast)
  → Sanctum token
  → Response 200: {user: UserResource, token}

Flutter: نفس REGISTER → saveToken + unwrapUser
```

### ME FLOW (التحقق من المستخدم)
```
Flutter: GET /auth/me (مع Bearer token)
Laravel: auth:sanctum → UserResource (withoutWrapping)
Flutter: _unwrapUser → UserModel.fromJson
```

---

## 🚨 الأخطاء المكتشفة (مرتبة بالخطورة)

---

### 🔴 BUG #1 — UserSeeder: Double Hashing (CRITICAL)

**الملف:** `dealak-backend/database/seeders/UserSeeder.php` — سطر 25

**المشكلة:** `Hash::make('password123')` + User model فيه `'password' => 'hashed'` cast  
→ كلمة المرور تُشفّر مرتين → الأدمن ما يقدر يسجل دخول!

```php
// ❌ الحالي (مزدوج التشفير):
'password' => Hash::make('password123'),

// ✅ الصح:
'password' => 'Password123',
```

**ملاحظة:** `firstOrCreate` يمنع التنفيذ إذا الأدمن موجود (من DatabaseSeeder)، بس لو اشتغل لحاله → فشل.

---

### 🔴 BUG #2 — resetPassword: Double Hashing (CRITICAL)

**الملف:** `dealak-backend/app/Http/Controllers/Api/V1/AuthController.php` — سطر 89

**المشكلة:** `Hash::make($password)` + `hashed` cast = double hash  
→ بعد إعادة تعيين كلمة المرور، المستخدم ما يقدر يسجل دخول!

```php
// ❌ الحالي:
$user->forceFill(['password' => Hash::make($password)])->save();

// ✅ الصح:
$user->forceFill(['password' => $password])->save();
```

---

### 🔴 BUG #3 — Validation Errors لا تظهر للمستخدم (HIGH)

**الملف:** `dealak_flutter/lib/providers/auth_provider.dart` — سطر 61, 69

**المشكلة:** `e.toString()` يُرجع `"بيانات غير صالحة"` — رسالة عامة.  
المستخدم ما يعرف وش الخطأ بالضبط (بريد مسجل؟ كلمة ضعيفة؟ حقل ناقص؟)

```dart
// ❌ الحالي:
} catch (e) {
  state = state.copyWith(isLoading: false, error: e.toString());
}

// ✅ الصح:
} catch (e) {
  String errorMsg = e.toString();
  if (e is ValidationException && e.errors != null) {
    final allErrors = e.errors!.values.expand((list) => list).toList();
    errorMsg = allErrors.join('\n');
  }
  state = state.copyWith(isLoading: false, error: errorMsg);
}
```

---

### 🟠 BUG #4 — ApiInterceptor يطرد المستخدم عند 401 بدون refresh (HIGH)

**الملف:** `dealak_flutter/lib/core/network/api_interceptor.dart` — سطر 19

**المشكلة:** أي 401 (حتى انتهاء صلاحية token) → يمسح كل البيانات ويطرد المستخدم  
بدون ما يجرب يعمل refresh أولاً

```dart
// ❌ الحالي:
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401) {
    await _storage.clearAll();
  }
  handler.next(err);
}

// ✅ الصح — محاولة refresh قبل الطرد:
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401) {
    final token = await _storage.getToken();
    if (token != null && !_isRefreshRequest(err.requestOptions)) {
      try {
        final dio = Dio(BaseOptions(
          baseUrl: err.requestOptions.baseUrl,
          headers: {'Authorization': 'Bearer $token'},
        ));
        final response = await dio.post('/auth/refresh');
        final newToken = response.data['token'];
        await _storage.saveToken(newToken);
        // إعادة الطلب الأصلي بالـ token الجديد
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await Dio().fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        await _storage.clearAll();
      }
    }
  }
  handler.next(err);
}

bool _isRefreshRequest(RequestOptions options) {
  return options.path.contains('/auth/refresh');
}
```

---

### 🟠 BUG #5 — UserResource يُرجع `properties_count` و `reviews_count` دائماً null (MEDIUM)

**الملف:** `dealak-backend/app/Http/Resources/UserResource.php` — سطر 18-19

**المشكلة:** `whenCounted()` يُرجع القيمة فقط لو الاستخدام `withCount()`.  
Register/Login/Me ما تستخدم `withCount()` → دائماً null.

**الحل — خيار أ (الأفضل — إزالة من Auth responses):**
ما يضر، Flutter يتعامل مع null. بس يرسل بيانات فاضية.

**الحل — خيار ب (إضافة withCount):**
```php
// AuthService.php
$user = User::create([...])->loadCount(['properties', 'reviews']);
```

---

### 🟡 BUG #6 — register_screen.dart لا يُرسل password_confirmation (LOW)

**الملف:** `dealak_flutter/lib/features/auth/screens/register_screen.dart` — سطر 89-96

**المشكلة:** مافي حقل تأكيد كلمة المرور. لو المستخدم غلط بكلمة المرور، ما يعرف.

**الحل:** إضافة حقل confirmPassword + إرسال `password_confirmation`.

> **ملاحظة:** Laravel `RegisterRequest` ما يطلب `password_confirmation` حالياً،  
> بس لو حابب تضيفه، تحتاج تضيف `'password' => 'confirmed'` في rules.

---

## ✅ المسارات اللي شغالة صح

| المسار | الحالة | ملاحظة |
|--------|--------|--------|
| Register → API → DB | ✅ | `withoutWrapping()` + `_unwrapUser()` يشتغل |
| Login → Hash::check | ✅ | `hashed` cast يُرجع الـ hash من DB |
| Token storage | ✅ | SecureStorage + ApiInterceptor |
| Auth middleware | ✅ | `auth:sanctum` يعمل صح |
| Password validation match | ✅ | Flutter = Laravel (8 + mixedCase + numbers) |
| me() endpoint | ✅ | بلا wrapper → Flutter يقرأ صح |
| AuthGuard redirect | ✅ | يتطلب auth لكل الصفحات |
| API routes structure | ✅ | auth/login/register بدون middleware |

---

## 🚀 خطة الإصلاح (مرتبة)

```
المرحلة 1: إصلاح حرج (CRITICAL)
  ├── 1.1 UserSeeder.php — إزالة Hash::make()
  ├── 1.2 AuthController.php resetPassword — إزالة Hash::make()
  └── 1.3 Commit + Push

المرحلة 2: تحسين تجربة المستخدم (HIGH)
  ├── 2.1 auth_provider.dart — عرض Validation errors تفصيلية
  ├── 2.2 api_interceptor.dart — محاولة refresh قبل الطرد
  └── 2.3 Commit + Push

المرحلة 3: تنظيف (LOW)
  ├── 3.1 إضافة حقل تأكيد كلمة المرور
  ├── 3.2 UserResource — withCount أو إزالة whenCounted
  └── 3.3 Commit + Push
```

---

## 📊 ملخص

| الأولوية | العدد | التأثير |
|----------|-------|---------|
| 🔴 CRITICAL | 2 | يمنع تسجيل الدخول |
| 🟠 HIGH | 2 | UX سيء + فقدان بيانات |
| 🟡 LOW | 1 | تحسين أمني |
| ✅ يعمل | 8 | — |

**الخلاصة:** 5 أخطاء، 2 حرجة (double hashing)، 2 عالية، 1 منخفضة.
