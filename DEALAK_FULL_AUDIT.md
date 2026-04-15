# 🔍 DEALAK — تقرير الفحص الشامل

**التاريخ:** 2026-04-15  
**النطاق:** فحص كامل Laravel Backend + Flutter Frontend  

---

## ✅ نتيجة التحقق من `DEALAK_REGISTER_FIX_PLAN.md`

### جميع الإصلاحات الستة تم تطبيقها بنجاح ✅

| # | الخطأ | الحالة | التحقق |
|---|-------|--------|--------|
| 1 | Password Validation Mismatch | ✅ مُصلح | `validators.dart:10-16` — يتحقق من حرف كبير + صغير + رقم |
| 2 | UserFactory أعمدة خاطئة | ✅ مُصلح | `UserFactory.php:19-29` — يستخدم `first_name`/`last_name` + جميع الحقول |
| 3 | UserResource Data Wrapping | ✅ مُصلح | `AppServiceProvider.php:23` — `JsonResource::withoutWrapping()` مفعّل |
| 4 | `me()` Response Wrapping | ✅ مُصلح | يُصلح تلقائياً مع `withoutWrapping()` + `_unwrapUser()` في Flutter |
| 5 | `login()` Response Wrapping | ✅ مُصلح | نفس الآلية |
| 6 | DatabaseSeeder لا يستدعي Seeders | ✅ مُصلح | `DatabaseSeeder.php:29-33` — يستدعي Gov/User/Property Seeders |

### إصلاحات إضافية تم تطبيقها:
- ✅ `auth_repository.dart` — دالة `_unwrapUser()` لحماية إضافية من data wrapper
- ✅ `register_screen.dart` — نموذج كامل مع validation و dropdown و controllers

---

## 🐛 المشاكل الجديدة المكتشفة (17 مشكلة)

---

### 🔴 مشاكل حرجة (CRITICAL) — 4 مشاكل

---

#### 🐛 C-1: `SearchService::search()` يستخدم `whereFullText` لكنه غير موجود في الكود!

**الخطورة:** 🔴 CRITICAL  
**الملف:** `dealak-backend/app/Services/SearchService.php` — سطر 16

**المشكلة:** الـ Migration أنشأ فهرس FullText صحيح في Properties table. لكن `whereFullText` في Laravel يعمل فقط مع MySQL ويحتاج صياغة محددة. إذا كان المستخدم يبحث بنص عربي أو كان محرك البحث InnoDB مع Collation غير مناسب، سيفشل البحث بصمت أو يُرجع `0 results`.

**الحل المقترح:**
```php
// SearchService.php — سطر 15-17
if (!empty($filters['q'])) {
    $searchTerm = $filters['q'];
    $query->where(function ($q) use ($searchTerm) {
        $q->where('title', 'LIKE', "%{$searchTerm}%")
          ->orWhere('description', 'LIKE', "%{$searchTerm}%")
          ->orWhere('city', 'LIKE', "%{$searchTerm}%")
          ->orWhere('district', 'LIKE', "%{$searchTerm}%");
    });
}
```

---

#### 🐛 C-2: `FavoriteController::index()` يُرجع Collection بدون Pagination format

**الخطورة:** 🔴 CRITICAL  
**الملف:** `dealak-backend/app/Http/Controllers/Api/V1/FavoriteController.php` — سطر 21

**المشكلة:** يستخدم `FavoriteResource::collection($favorites)` بينما `$favorites` هو `LengthAwarePaginator`. الـ `collection()` لا تُنتج format مع `meta` (pagination). Flutter يتوقع `PaginatedResponse` مع `data` + `meta`.

**الحالي:**
```php
return response()->json(FavoriteResource::collection($favorites));
// الناتج: [{...}, {...}] — بدون meta!
```

**Flutter يتوقع:**
```dart
PaginatedResponse.fromJson(response.data, FavoriteModel.fromJson);
// يحتاج: {"data": [...], "meta": {"current_page": 1, ...}}
```

**الحل:**
```php
// إنشاء FavoriteCollection مثل PropertyCollection أو استخدام:
return response()->json([
    'data' => FavoriteResource::collection($favorites),
    'meta' => [
        'current_page' => $favorites->currentPage(),
        'last_page' => $favorites->lastPage(),
        'per_page' => $favorites->perPage(),
        'total' => $favorites->total(),
    ],
]);
```

---

#### 🐛 C-3: `ConversationController::messages()` نفس مشكلة الـ Pagination

**الخطورة:** 🔴 CRITICAL  
**الملف:** `dealak-backend/app/Http/Controllers/Api/V1/ConversationController.php` — سطر 72

**المشكلة:** `MessageResource::collection($messages)` لا يُنتج format مع pagination meta.

**الحل:** نفس الحل — إنشاء MessageCollection أو إرجاع format يدوي.

---

#### 🐛 C-4: `DealController::index()` — `orWhere` بدون scope يُسرّب بيانات

**الخطورة:** 🔴 CRITICAL — ثغرة أمنية  
**الملف:** `dealak-backend/app/Http/Controllers/Api/V1/DealController.php` — سطر 21-24

**المشكلة:** الـ `orWhere` بدون grouping يتجاوز أي شرط سابق. كل الصفقات التي agent_id ليس null ستظهر لأي مستخدم مسجل.

**الحالي (خطير):**
```php
$deals = Deal::with([...])
    ->where('buyer_id', $request->user()->id)
    ->orWhere('seller_id', $request->user()->id)    // ← يتجاوز where الأول
    ->orWhere('agent_id', $request->user()->id)      // ← يتجاوز كل الشروط
    ->latest()
    ->paginate();
```

**الحل:**
```php
$userId = $request->user()->id;
$deals = Deal::with([...])
    ->where(function ($q) use ($userId) {
        $q->where('buyer_id', $userId)
          ->orWhere('seller_id', $userId)
          ->orWhere('agent_id', $userId);
    })
    ->latest()
    ->paginate($request->per_page ?? 20);
```

---

### 🟠 مشاكل عالية (HIGH) — 5 مشاكل

---

#### 🐛 H-1: `register_screen.dart` — لا يُرسل `password_confirmation`

**الخطورة:** 🟠 HIGH  
**الملف:** `dealak_flutter/lib/features/auth/screens/register_screen.dart` — سطر 83-93

**المشكلة:** الـ register screen لا يحتوي حقل "تأكيد كلمة المرور" ولا يُرسل `password_confirmation`. حالياً الـ `RegisterRequest.php` لا يطلبه، لكن هذا خلل في UX وأمان — المستخدم قد يكتب كلمة مرور خاطئة.

**الحل:** إضافة حقل `confirmPassword` في الشاشة + إرسال `password_confirmation` في الـ request.

---

#### 🐛 H-2: `app.dart` — يُنشئ `GoRouter` في كل rebuild!

**الخطورة:** 🟠 HIGH — مشكلة أداء  
**الملف:** `dealak_flutter/lib/app.dart` — سطر 17-18

**المشكلة:** كل ما يتغير `themeMode` أو `locale`، يُعاد بناء الـ Widget ويُنشأ `Router` جديد → فقدان الـ navigation state.

**الحالي:**
```dart
Widget build(BuildContext context, WidgetRef ref) {
    final authGuard = AuthGuard(SecureStorage());   // كائن جديد كل مرة!
    final router = createRouter(authGuard);          // router جديد كل مرة!
```

**الحل:** نقل الـ router إلى Provider أو متغير static:
```dart
// في auth_provider.dart
final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.read(secureStorageProvider);
  return createRouter(AuthGuard(storage));
});
```

---

#### 🐛 H-3: `User` Model — `password` مع cast `hashed` + `Hash::make()` = Double Hashing!

**الخطورة:** 🟠 HIGH  
**الملف:** `dealak-backend/app/Models/User.php` — سطر 27  
**+ الملف:** `dealak-backend/app/Services/AuthService.php` — سطر 17

**المشكلة:** الـ User model يحتوي `'password' => 'hashed'` cast (Laravel 12 automatic hashing). وفي نفس الوقت `AuthService::register()` يستخدم `Hash::make($data['password'])`. هذا يعني الكلمة تُشفّر مرتين → لن يستطيع المستخدم تسجيل الدخول أبداً!

**ملاحظة:** نفس المشكلة في `UserController::updatePassword()` (سطر 67) و `DatabaseSeeder.php` (سطر 18).

**الحل — خيار أ (الأفضل):** إزالة `Hash::make()` من كل الأماكن والاعتماد على الـ cast:
```php
// AuthService.php
'password' => $data['password'],  // الـ cast سيشفره تلقائياً

// DatabaseSeeder.php
'password' => 'admin123',  // الـ cast سيشفره تلقائياً
```

**الحل — خيار ب:** إزالة `'password' => 'hashed'` من الـ cast والاحتفاظ بـ `Hash::make()` اليدوي.

---

#### 🐛 H-4: `ConversationController::index()` — نفس مشكلة `orWhere` بدون scope

**الخطورة:** 🟠 HIGH  
**الملف:** `dealak-backend/app/Http/Controllers/Api/V1/ConversationController.php` — سطر 21-22

**الحل:**
```php
$userId = $request->user()->id;
$conversations = Conversation::with([...])
    ->where(function ($q) use ($userId) {
        $q->where('participant_one_id', $userId)
          ->orWhere('participant_two_id', $userId);
    })
    ->latest('last_message_at')
    ->paginate($request->per_page ?? 20);
```

---

#### 🐛 H-5: `SearchController::deleteSavedSearch()` — لا يتحقق من ملكية البحث

**الخطورة:** 🟠 HIGH — ثغرة أمنية  
**الملف:** `dealak-backend/app/Http/Controllers/Api/V1/SearchController.php` — سطر 82-86

**المشكلة:** أي مستخدم مسجل يمكنه حذف أي بحث محفوظ لأي مستخدم آخر.

**الحالي:**
```php
SavedSearch::findOrFail($id)->delete();  // لا يتحقق من user_id!
```

**الحل:**
```php
$request->user()->savedSearches()->findOrFail($id)->delete();
```

---

### 🟡 مشاكل متوسطة (MEDIUM) — 5 مشاكل

---

#### 🐛 M-1: `UserModel.fromJson()` — `json['id']` بدون null safety

**الخطورة:** 🟡 MEDIUM  
**الملف:** `dealak_flutter/lib/data/models/user_model.dart` — سطر 34

**المشكلة:** إذا كان `id` مفقوداً من الـ JSON → `TypeError` crash.

**الحل:**
```dart
id: json['id'] as int? ?? 0,
```

---

#### 🐛 M-2: `PropertyModel.fromJson()` — نفس مشكلة `id` بدون null safety

**الخطورة:** 🟡 MEDIUM  
**الملف:** `dealak_flutter/lib/data/models/property_model.dart` — سطر 70

**الحل:**
```dart
id: json['id'] as int? ?? 0,
```

---

#### 🐛 M-3: `auth_guard.dart` — الـ redirect يسمح بالوصول لـ `/` بدون token

**الخطورة:** 🟡 MEDIUM  
**الملف:** `dealak_flutter/lib/core/router/auth_guard.dart` — سطر 19

**المشكلة:** الشرط `state.matchedLocation != '/'` يعني أن صفحة Home (`/`) يمكن الوصول لها بدون تسجيل دخول. هذا قد يكون مقصوداً، لكن الصفحة تحاول عرض بيانات تحتاج authentication.

**الحل:** إذا كان المطلوب السماح بالتصفح بدون تسجيل → يجب التأكد من أن الـ providers تتعامل مع حالة عدم وجود token. إذا كان التسجيل مطلوباً → إزالة الاستثناء:
```dart
if (!hasToken && !isAuthRoute) {
  return RouteNames.login;
}
```

---

#### 🐛 M-4: `DealController` و `PropertyController` — `$this->authorize()` بدون Policy مسجّلة

**الخطورة:** 🟡 MEDIUM  
**الملف:** `DealController.php` — سطور 57, 70, 91  
**الملف:** `PropertyController.php` — سطور 78, 91, 104, 120

**المشكلة:** الـ Controllers تستدعي `$this->authorize('update', $property)` لكن يجب التأكد من أن الـ Policies مسجّلة في `AuthServiceProvider` أو تعمل بـ auto-discovery. الملفات `PropertyPolicy.php` و `DealPolicy.php` موجودة لكن يجب التحقق من تسجيلها.

---

#### 🐛 M-5: `PropertyController::featured()` و `similar()` — يُرجعان Collection بدون pagination wrap

**الخطورة:** 🟡 MEDIUM  
**الملف:** `dealak-backend/app/Http/Controllers/Api/V1/PropertyController.php` — سطر 137, 165

**المشكلة:** يُرجعان `PropertyResource::collection()` وهذا يُنتج مصفوفة مسطحة `[{...}, ...]`. لكن Flutter `PropertyRepository::getFeatured()` يستخدم `_extractList()` الذي يتعامل مع هذا. ✅ لا مشكلة فعلية لكن التنسيق غير متناسق مع باقي الـ endpoints.

---

### 🔵 مشاكل منخفضة (LOW) — 3 مشاكل

---

#### 🐛 L-1: `login_screen.dart` — يستخدم `Validators.password` في حقل كلمة المرور

**الخطورة:** 🔵 LOW — UX  
**الملف:** `dealak_flutter/lib/features/auth/screens/login_screen.dart` — سطر 50

**المشكلة:** عند تسجيل الدخول، يتحقق من تعقيد كلمة المرور (حرف كبير + صغير + رقم). هذا غير ضروري — المستخدم يكتب كلمة مرور موجودة مسبقاً. الـ validator يجب أن يكون فقط "مطلوب".

**الحل:**
```dart
validator: (v) => Validators.required(v, 'كلمة المرور'),
```

---

#### 🐛 L-2: `DatabaseSeeder.php` — Admin password لا يتوافق مع القواعد

**الخطورة:** 🔵 LOW  
**الملف:** `dealak-backend/database/seeders/DatabaseSeeder.php` — سطر 18

**المشكلة:** كلمة مرور الأدمن `admin123` لا تحتوي حرف كبير → لن يستطيع الأدمن تسجيل الدخول من التطبيق (إلا إذا تم تعديل الـ login validator كما في L-1).

**الحل:** تغيير كلمة المرور إلى `Admin123` أو ما يتوافق مع القواعد.

---

#### 🐛 L-3: `app_with_api_config.dart` — `ProviderScope.containerOf(context)` في `initState`

**الخطورة:** 🔵 LOW — محتملة  
**الملف:** `dealak_flutter/lib/app_with_api_config.dart` — سطر 32

**المشكلة:** استخدام `context` في `_initPrefs()` المستدعاة من `initState()`. الـ context قد لا يكون مرتبطاً بالشجرة بعد في هذه المرحلة.

**الحل:** استخدام `WidgetsBinding.instance.addPostFrameCallback` أو `didChangeDependencies`.

---

## 📊 ملخص الأولويات

| الأولوية | العدد | الأهم |
|----------|-------|-------|
| 🔴 CRITICAL | 4 | Double Hashing (H-3) + Data Leak (C-4) + Pagination (C-2, C-3) |
| 🟠 HIGH | 5 | Router rebuild (H-2) + Security (H-4, H-5) |
| 🟡 MEDIUM | 5 | Null safety + Auth guard + Policy registration |
| 🔵 LOW | 3 | UX + Seeder password + Context timing |

---

## 🚀 ترتيب الإصلاح المقترح

```
المرحلة 1: الأمان والبيانات (CRITICAL + Security)
  ├── 1.1 إصلاح Double Hashing (H-3) ← الأهم! قد يمنع تسجيل الدخول
  ├── 1.2 إصلاح orWhere scope في DealController (C-4)
  ├── 1.3 إصلاح orWhere scope في ConversationController (H-4)
  ├── 1.4 إصلاح ملكية SavedSearch (H-5)
  └── 1.5 إصلاح كلمة مرور الأدمن (L-2)

المرحلة 2: توافق API (Pagination + Search)
  ├── 2.1 إصلاح FavoriteController pagination (C-2)
  ├── 2.2 إصلاح ConversationController messages pagination (C-3)
  └── 2.3 إصلاح SearchService fulltext → LIKE (C-1)

المرحلة 3: Flutter fixes
  ├── 3.1 إصلاح Router rebuild (H-2)
  ├── 3.2 إضافة حقل تأكيد كلمة المرور (H-1)
  ├── 3.3 إصلاح login validator (L-1)
  ├── 3.4 إصلاح null safety في Models (M-1, M-2)
  └── 3.5 إصلاح auth_guard (M-3)

المرحلة 4: التنظيف
  ├── 4.1 التحقق من Policy auto-discovery (M-4)
  ├── 4.2 إصلاح context في app_with_api_config (L-3)
  └── 4.3 توحيد response format في featured/similar (M-5)
```
