# 🔧 خطة إصلاح التسجيل + تعبئة قاعدة البيانات - DEALAK

**التاريخ:** 2026-04-15  
**الحالة:** ⏳ قيد التنفيذ

---

## 📋 المشكلة

1. **التسجيل يفشل** — يُرجع رسالة "بيانات غير صالحة" (HTTP 422)
2. **قاعدة البيانات فارغة** — لا توجد عقارات ولا مستخدمين للاختبار
3. **عدم توافق** بين ما يُرسله Flutter وما يتوقعه Laravel

---

## 🔍 التحليل الجذري (6 أخطاء مكتشفة)

---

### 🐛 الخطأ #1 — Password Validation Mismatch (CRITICAL)

**المشكلة:** Flutter يقبل أي كلمة مرور بطول 8 أحرف، بينما Laravel يتطلب حرف كبير + صغير + رقم.

| الجانب | القاعدة | مثال `abcdefgh` |
|--------|---------|-----------------|
| **Flutter** `validators.dart:10-13` | `length >= 8` فقط | ✅ يقبل |
| **Laravel** `RegisterRequest.php:22` | `min(8)->mixedCase()->numbers()` | ❌ يرفض (422) |

**الملفات:**
- `dealak_flutter/lib/core/utils/validators.dart` — سطر 10-13
- `dealak-backend/app/Http/Requests/Auth/RegisterRequest.php` — سطر 22

**الحل:**
```dart
// validators.dart — تحديث دالة password
static String? password(String? value) {
  if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
  if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
  if (!RegExp(r'[A-Z]').hasMatch(value)) return 'يجب أن تحتوي على حرف كبير (A-Z)';
  if (!RegExp(r'[a-z]').hasMatch(value)) return 'يجب أن تحتوي على حرف صغير (a-z)';
  if (!RegExp(r'[0-9]').hasMatch(value)) return 'يجب أن تحتوي على رقم (0-9)';
  return null;
}
```

---

### 🐛 الخطأ #2 — UserFactory أعمدة خاطئة (CRITICAL)

**المشكلة:** `UserFactory` يستخدم عمود `name` غير موجود في جدول `users`. الجدول يحتوي `first_name` + `last_name`.

**الملف:** `dealak-backend/database/factories/UserFactory.php` — سطر 27-33

**الحالي (خاطئ):**
```php
return [
    'name' => fake()->name(),           // ← عمود غير موجود!
    'email' => fake()->safeEmail(),
    'password' => Hash::make('password'),
    // مفقود: first_name, last_name, is_active, role
];
```

**الحل:**
```php
return [
    'first_name' => fake()->firstName(),
    'last_name' => fake()->lastName(),
    'email' => fake()->unique()->safeEmail(),
    'phone' => fake()->unique()->numerify('+963#########'),
    'password' => static::$password ??= Hash::make('Password1'),
    'role' => 'BUYER',
    'is_active' => true,
    'is_verified' => fake()->boolean(70),
    'bio' => fake()->optional()->sentence(),
];
```

---

### 🐛 الخطأ #3 — UserResource Data Wrapping في register/login (HIGH)

**المشكلة:** `response()->json(new UserResource(...))` يلف البيانات تلقائياً بـ `{"data": {...}}` بسبب `JsonResource`.

**Laravel يُرسل:**
```json
{
  "user": {"data": {"id": 1, "first_name": "أحمد"}},
  "token": "abc..."
}
```

**Flutter يتوقع:**
```json
{
  "user": {"id": 1, "first_name": "أحمد"},
  "token": "abc..."
}
```

**الملف:** `dealak-backend/app/Http/Controllers/Api/V1/AuthController.php` — سطر 27-31, 38-41

**الحل — الخيار الأفضل (إلغاء Wrapping عالمياً):**

إضافة في `AppServiceProvider::boot()`:
```php
\Illuminate\Http\Resources\Json\JsonResource::withoutWrapping();
```

**أو الحل البديل:** استخدام `->resolve()` في الـ Controller:
```php
'user' => (new UserResource($result['user']))->resolve(),
```

---

### 🐛 الخطأ #4 — `me()` Response Wrapping (HIGH)

**المشكلة:** نفس مشكلة الـ wrapping.

**الملف:** `AuthController.php` — سطر 52-54

**الحالي:**
```php
return response()->json(new UserResource($request->user()));
// الناتج: {"data": {"id": 1, ...}}
```

**Flutter يتوقع:**
```dart
return UserModel.fromJson(response.data);
// response.data['id'] → null! لأن الـ id داخل data wrapper
```

**الحل:** يُصلح تلقائياً مع الحل العالمي `withoutWrapping()`.

**+ إصلاح Flutter كطبقة حماية إضافية:**
```dart
// auth_repository.dart — getMe()
final raw = response.data;
final userJson = (raw is Map && raw.containsKey('data') && raw['data'] is Map)
    ? raw['data'] : raw;
return UserModel.fromJson(userJson);
```

---

### 🐛 الخطأ #5 — login() نفس مشكلة Wrapping (HIGH)

**الملف:** `AuthController.php` — سطر 38-41  
**الحل:** نفس الحل (withoutWrapping أو resolve)

---

### 🐛 الخطأ #6 — DatabaseSeeder لا يستدعي Seeders (MEDIUM)

**المشكلة:** `DatabaseSeeder` ينشئ Admin واحد + إعدادات فقط. لا يستدعي `UserSeeder`, `PropertySeeder`, `GovernorateSeeder`.

**الملف:** `dealak-backend/database/seeders/DatabaseSeeder.php`

**الحل:**
```php
public function run(): void
{
    // Admin user
    User::create([...]);

    // System settings
    SystemSetting::insert([...]);

    // استدعاء باقي الـ Seeders
    $this->call([
        GovernorateSeeder::class,
        UserSeeder::class,
        PropertySeeder::class,
    ]);
}
```

---

## 📝 الملفات المطلوب تعديلها (مرتبة بالأولوية)

### Laravel (4 ملفات)

| # | الملف | التعديل |
|---|-------|---------|
| 1 | `database/factories/UserFactory.php` | استبدال `name` بـ `first_name`/`last_name` + إضافة الحقول المفقودة |
| 2 | `database/seeders/DatabaseSeeder.php` | استدعاء `GovernorateSeeder`, `UserSeeder`, `PropertySeeder` |
| 3 | `app/Providers/AppServiceProvider.php` | إضافة `JsonResource::withoutWrapping()` |
| 4 | `app/Http/Controllers/Api/V1/AuthController.php` | احتياطي: `->resolve()` إذا لم نستخدم withoutWrapping |

### Flutter (3 ملفات)

| # | الملف | التعديل |
|---|-------|---------|
| 5 | `lib/core/utils/validators.dart` | إضافة تحقق حرف كبير + صغير + رقم |
| 6 | `lib/data/repositories/auth_repository.dart` | التعامل مع `data` wrapper في login/register/me |
| 7 | `lib/features/auth/screens/register_screen.dart` | عرض رسائل validation تفصيلية |

---

## 🚀 خطوات التنفيذ

```
المرحلة 1: إصلاح Laravel
  ├── 1.1 إصلاح UserFactory.php
  ├── 1.2 إضافة withoutWrapping() في AppServiceProvider
  ├── 1.3 تحديث DatabaseSeeder
  └── 1.4 تشغيل: php artisan migrate:fresh --seed

المرحلة 2: إصلاح Flutter  
  ├── 2.1 تحديث validators.dart
  ├── 2.2 إصلاح auth_repository.dart (data wrapper)
  └── 2.3 تحسين register_screen.dart

المرحلة 3: التحقق
  ├── 3.1 flutter analyze → 0 errors
  ├── 3.2 تشغيل Laravel + Flutter
  ├── 3.3 اختبار تسجيل حساب جديد
  ├── 3.4 اختبار تسجيل دخول
  └── 3.5 التأكد من ظهور العقارات في الصفحة الرئيسية
```

---

## ✅ Verification Checklist

- [ ] `php artisan migrate:fresh --seed` ينجح بدون أخطاء
- [ ] `flutter analyze` → 0 errors
- [ ] تسجيل حساب جديد بكلمة مرور `Test1234` → ينجح
- [ ] تسجيل دخول → ينجح ويُظهر الصفحة الرئيسية
- [ ] الصفحة الرئيسية تعرض عقارات مميزة
- [ ] صفحة البحث تُرجع نتائج
