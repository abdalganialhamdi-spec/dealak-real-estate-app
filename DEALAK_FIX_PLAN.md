# 🔧 DEALAK - خطة الإصلاح والإنهاء الشاملة
> **تاريخ الإنشاء:** 2026-04-15  
> **الحالة:** يحتاج تنفيذ  
> **الأولوية:** حرجة → عالية → متوسطة → منخفضة

---

## 📊 ملخص نتائج الفحص

| الفئة | عدد المشاكل | الأولوية |
|-------|-------------|----------|
| أخطاء Dart Analyzer (errors) | 2 | 🔴 حرجة |
| تحذيرات Dart Analyzer (warnings) | 3 | 🟠 عالية |
| معلومات Dart Analyzer (info) | 2 | 🟡 متوسطة |
| شاشات فارغة (Stub Screens) | 14 | 🔴 حرجة |
| مشاكل معمارية Flutter | 8 | 🟠 عالية |
| مشاكل API Contract | 5 | 🟠 عالية |
| مشاكل Laravel Backend | 6 | 🟠 عالية |
| مشاكل التكامل | 4 | 🔴 حرجة |
| نقص الاختبارات | 1 | 🟡 متوسطة |
| **المجموع** | **~45** | -- |

---

## 🔴 القسم 1: أخطاء Dart Analyzer (حرجة)

### 1.1 خطأ في `forgot_password_screen.dart` (سطر 36)
```
error - The argument type 'Future<void> Function()?' can't be assigned to the parameter type 'VoidCallback'.
```
**المشكلة:** `CustomButton.onPressed` يقبل `VoidCallback` لكن `_sendResetLink` هي `Future<void>` والتعبير `_sent ? null : _sendResetLink` ينتج `Future<void> Function()?`

**الإصلاح:**
```dart
// الحالي (خطأ):
CustomButton(label: _sent ? 'تم الإرسال' : 'إرسال رابط إعادة التعيين', onPressed: _sent ? null : _sendResetLink),

// المطلوب:
CustomButton(
  label: _sent ? 'تم الإرسال' : 'إرسال رابط إعادة التعيين',
  isLoading: _isLoading, // إضافة حالة التحميل
  onPressed: _sent ? () {} : () => _sendResetLink(),
),
```

### 1.2 خطأ في `widget_test.dart` (سطر 16)
```
error - The name 'MyApp' isn't a class
```
**المشكلة:** ملف الاختبار يستورد `MyApp` من `main.dart` لكن `main.dart` لا يصدّر أي class بهذا الاسم.

**الإصلاح:** إعادة كتابة ملف الاختبار ليتوافق مع `DealakAppWithApiConfig`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/app_with_api_config.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DealakAppWithApiConfig()));
    await tester.pumpAndSettle();
    // تحقق من ظهور شاشة الإعدادات أو الشاشة الرئيسية
    expect(find.byType(DealakAppWithApiConfig), findsOneWidget);
  });
}
```

---

## 🟠 القسم 2: تحذيرات Dart Analyzer (عالية)

### 2.1 استيراد غير مستخدم في `app_with_api_config.dart` (سطر 2)
```
warning - Unused import: 'package:flutter_riverpod/flutter_riverpod.dart'
```
**الإصلاح:** حذف السطر `import 'package:flutter_riverpod/flutter_riverpod.dart';`

### 2.2 استيراد غير مستخدم في `auth_guard.dart` (سطر 3)
```
warning - Unused import: 'package:dealak_flutter/core/router/route_names.dart'
```
**الإصلاح:** حذف الاستيراد + تفعيل منطق AuthGuard فعلياً (انظر القسم 4)

### 2.3 حقل غير مستخدم في `auth_guard.dart` (سطر 6)
```
warning - The value of the field '_storage' isn't used
```
**الإصلاح:** تفعيل AuthGuard الفعلي (انظر القسم 4.1)

---

## 🟡 القسم 3: معلومات Dart Analyzer (متوسطة)

### 3.1 استيراد غير مستخدم في `register_screen.dart` (سطر 5)
```
warning - Unused import: 'package:dealak_flutter/core/router/route_names.dart'
```
**الإصلاح:** حذف الاستيراد

### 3.2 استخدام `value` المهمل في `register_screen.dart` (سطر 60)
```
info - 'value' is deprecated. Use initialValue instead.
```
**الإصلاح:** في `DropdownButtonFormField`:
```dart
// الحالي:
value: _selectedRole,
// المطلوب:
initialValue: _selectedRole, // أو تجاهله حسب إصدار Flutter
```

---

## 🔴 القسم 4: مشاكل معمارية حرجة في Flutter

### 4.1 ❌ AuthGuard معطّل بالكامل
**الملف:** `lib/core/router/auth_guard.dart`
**المشكلة:** AuthGuard يرجع `null` دائماً = لا توجد حماية للمسارات. أي مستخدم يستطيع الوصول لكل الشاشات بدون تسجيل دخول.

**الإصلاح المطلوب:**
```dart
class AuthGuard {
  final SecureStorage _storage;
  AuthGuard(this._storage);

  Future<String?> redirect(GoRouterState state) async {
    final hasToken = await _storage.hasToken();
    final isAuthRoute = ['/login', '/register', '/forgot-password', '/onboarding'].contains(state.matchedLocation);
    
    if (!hasToken && !isAuthRoute && state.matchedLocation != '/') {
      return RouteNames.login;
    }
    if (hasToken && isAuthRoute) {
      return RouteNames.home;
    }
    return null;
  }
}
```
**+ ربط AuthGuard مع GoRouter عبر `redirect` callback**

### 4.2 ❌ DealakAppContent لا يستخدم Router
**الملف:** `lib/app_with_api_config.dart` (سطر 62-88)
**المشكلة:** بعد إعداد API، يظهر `DealakAppContent` الذي هو مجرد `Scaffold` بسيط مع نص "متصل بالسيرفر". لا يستخدم `GoRouter` ولا يعرض `DealakApp`.

**الإصلاح:** استبدال `DealakAppContent` بـ `DealakApp` من `app.dart`:
```dart
// بدلاً من DealakAppContent، استخدم DealakApp مع تمرير baseUrl
return const DealakApp();
```

### 4.3 ❌ baseUrl لا يُمرر من إعدادات API إلى DioClient
**المشكلة:** المستخدم يدخل host/port في `ApiSettingsScreen`، لكن `DioClient` يستخدم `ApiEndpoints.baseUrl` الثابت (hardcoded IP: `10.183.151.121:8000`). الإعدادات المحفوظة **لا تؤثر** على الاتصال الفعلي.

**الإصلاح المطلوب:**
1. تحديث `dioClientProvider` ليقرأ من `AppPreferences`
2. أو تمرير `baseUrl` ديناميكياً عند الإقلاع
3. تحديث `DioClient.updateBaseUrl()` ليُستدعى بعد حفظ الإعدادات

### 4.4 ❌ app.dart غير مستخدم
**الملف:** `lib/app.dart`
**المشكلة:** `DealakApp` (الذي يحتوي على Router + Theme + Locale) **لا يُستدعى من أي مكان**. `main.dart` يستدعي `DealakAppWithApiConfig` فقط.

**الإصلاح:** ربط `DealakAppWithApiConfig` → `DealakApp` بعد نجاح الإعداد

### 4.5 ❌ ProfileScreen لا تنتقل لأي مكان
**الملف:** `lib/features/profile/screens/profile_screen.dart`
**المشكلة:** جميع `ListTile.onTap` فيها `() {}` فارغة - لا يوجد تنقل فعلي.

**الإصلاح:** إضافة context.push/go لكل عنصر:
```dart
onTap: () => context.push(RouteNames.editProfile),
onTap: () => context.push(RouteNames.myProperties),
onTap: () => context.push(RouteNames.deals),
onTap: () => context.push(RouteNames.notifications),
onTap: () => context.push(RouteNames.settings),
```

### 4.6 ❌ HomeScreen لا تنتقل عند الضغط على عقار أو بحث
**المشكلة:** الـ GestureDetector و _PropertyCard بدون onTap فعلي.

**الإصلاح:** إضافة التنقل:
```dart
GestureDetector(
  onTap: () => context.push(RouteNames.search),
  ...
)
// وللعقار:
GestureDetector(
  onTap: () => context.push('${RouteNames.propertyDetail}/${property.id}'),
  child: _PropertyCard(...),
)
```

### 4.7 ❌ غياب l10n الفعلي
**المشكلة:** المجلد `l10n/` موجود لكن لا يحتوي ملفات ترجمة. لا يوجد `flutter_gen` مُمكّن. كل النصوص hardcoded بالعربية.

### 4.8 ❌ assets فارغة
**المشكلة:** `pubspec.yaml` يشير إلى `assets/images/` و `assets/icons/` لكن `AppAssets` يشير إلى ملفات (logo.png, onboarding_1.png etc.) من المحتمل أنها **غير موجودة.**

**الإصلاح:** إنشاء الملفات المطلوبة أو إزالة المراجع

---

## 🔴 القسم 5: شاشات فارغة / Stubs (14 شاشة)

الشاشات التالية تعرض **نص فقط** ولا تتصل بـ API أو Providers:

| # | الشاشة | الملف | الحالة |
|---|--------|-------|--------|
| 1 | Property Detail | `property/screens/property_detail_screen.dart` | ❌ نص فقط - لا يجلب بيانات العقار |
| 2 | Property Create | `property/screens/property_create_screen.dart` | ❌ نص فقط - لا نموذج إضافة |
| 3 | Property List | `property/screens/property_list_screen.dart` | ❌ نص فقط - لا قائمة عقارات |
| 4 | Search | `search/screens/search_screen.dart` | ❌ نص فقط - لا بحث فعلي |
| 5 | Favorites | `favorites/screens/favorites_screen.dart` | ❌ نص فقط |
| 6 | Conversations | `messages/screens/conversations_screen.dart` | ❌ نص فقط |
| 7 | Chat | `messages/screens/chat_screen.dart` | ⚠️ UI بدائي - لا يتصل بـ API |
| 8 | Deals List | `deals/screens/deals_list_screen.dart` | ❌ نص فقط |
| 9 | Deal Detail | `deals/screens/deal_detail_screen.dart` | ❌ نص فقط |
| 10 | Edit Profile | `profile/screens/edit_profile_screen.dart` | ❌ نص فقط |
| 11 | Settings | `profile/screens/settings_screen.dart` | ❌ نص فقط |
| 12 | My Properties | `profile/screens/my_properties_screen.dart` | ❌ نص فقط |
| 13 | Notifications | `notifications/screens/notifications_screen.dart` | ❌ نص فقط |
| 14 | Requests List | `requests/screens/requests_list_screen.dart` | ❌ نص فقط |
| 15 | Create Request | `requests/screens/create_request_screen.dart` | ❌ نص فقط |
| 16 | Admin Dashboard | `admin/screens/admin_dashboard_screen.dart` | ❌ نص فقط |

### كل شاشة تحتاج:
1. استدعاء Provider/Repository المناسب
2. عرض البيانات بشكل صحيح مع Loading/Error states
3. ربط التنقل
4. تصميم UI كامل يليق بتطبيق عقارات احترافي

---

## 🟠 القسم 6: مشاكل تكامل API Contract

### 6.1 ❌ `/auth/me` - عدم تطابق هيكل الاستجابة
**المشكلة:**
- Laravel `me()` يرجع `UserResource` مباشرة (بنية `{id, first_name, ...}`)
- Flutter `getMe()` يتوقع `response.data` مباشرة
- لكن UserResource في Laravel تلف البيانات بـ `data: {}` افتراضياً
**الإصلاح:** التحقق من إعدادات `JsonResource::$wrap` في Laravel

### 6.2 ❌ كلمات المرور في Login
**المشكلة:** Laravel `AuthService.login()` يستخدم `abort(401)` الذي يرجع HTML default. Flutter يتوقع JSON.
**الإصلاح:** استخدام `ForceJsonResponse` middleware على كل routes الـ API (الملف موجود لكن قد لا يكون مسجل)

### 6.3 ⚠️ عدم تطابق pagination
**المشكلة:**
- Flutter `PaginatedResponse.fromJson` يقرأ من `json['meta']`
- Laravel `PropertyCollection` يستخدم `ResourceCollection` التي تضع الـ pagination في جذر الاستجابة وليس في `meta`
**الإصلاح:** مراجعة بنية PropertyCollection المرجعة

### 6.4 ⚠️ Featured Properties Response
**المشكلة:**
- Flutter `getFeatured()` يتوقع `response.data` كـ `List` مباشرة
- Laravel `featured()` يرجع `PropertyResource::collection()` التي قد تكون ملفوفة بـ `data`
**الإصلاح:** توحيد الهيكل

### 6.5 ⚠️ Property show لا يزيد view_count
**المشكلة:** `PropertyController.show()` يجلب العقار بدون زيادة `view_count`. الـ `PropertyView` model موجود لكن لا يُستخدم.

---

## 🟠 القسم 7: مشاكل Laravel Backend

### 7.1 ❌ AdminMiddleware غير مسجل
**المشكلة:** `AdminMiddleware` موجود كملف لكن يجب التحقق من تسجيله في `bootstrap/app.php` أو `Kernel.php`. المسار يستخدم `'admin'` كـ middleware alias.

**الإصلاح:** التحقق وتسجيل الـ middleware:
```php
// في bootstrap/app.php (Laravel 12)
->withMiddleware(function (Middleware $middleware) {
    $middleware->alias([
        'admin' => \App\Http\Middleware\AdminMiddleware::class,
    ]);
    // + ForceJsonResponse على API routes
})
```

### 7.2 ⚠️ `ForceJsonResponse` middleware قد لا يكون مفعّل
**المشكلة:** الملف موجود لكن يجب التحقق من تطبيقه على `api` routes group

### 7.3 ⚠️ SearchService - nearby بدون PostGIS
```php
// SearchController.php يستدعي searchNearby()
// يجب التحقق من SearchService أنه يستخدم Haversine formula
// لأن MySQL لا يدعم PostGIS بشكل أصلي
```

### 7.4 ⚠️ PropertyController `$this->authorize()` بدون Policy Registration
**المشكلة:** `PropertyController` يستخدم `$this->authorize('update', $property)` لكن يجب التحقق من تسجيل `PropertyPolicy` في `AuthServiceProvider`.

### 7.5 ⚠️ عدم وجود `password_confirmation` في RegisterRequest
**المشكلة:** Flutter `register_screen.dart` لا يرسل `password_confirmation`. يجب التحقق من `RegisterRequest` validation rules.

### 7.6 ⚠️ Favorite Route Conflict
**المشكلة:** المسارات تحتوي:
```php
Route::apiResource('favorites', ...)->except(['update', 'show']);
Route::delete('/favorites/{propertyId}', ...); // تداخل مع apiResource destroy
```
**الإصلاح:** إزالة `destroy` من `except` أو إزالة السطر المكرر

---

## 🟡 القسم 8: مشاكل إضافية

### 8.1 ⚠️ Providers مكتوبة لكن غير مستخدمة
| Provider | الملف | الحالة |
|----------|-------|--------|
| `deal_provider.dart` | `providers/deal_provider.dart` | ⚠️ قد يكون غير مستخدم في أي شاشة |
| `favorite_provider.dart` | `providers/favorite_provider.dart` | ⚠️ غير مستخدم |
| `message_provider.dart` | `providers/message_provider.dart` | ⚠️ غير مستخدم |
| `notification_provider.dart` | `providers/notification_provider.dart` | ⚠️ غير مستخدم |
| `search_provider.dart` | `providers/search_provider.dart` | ⚠️ غير مستخدم |

### 8.2 ⚠️ Repositories مكتوبة لكن غير مستخدمة
| Repository | الحالة |
|------------|--------|
| `deal_repository.dart` | ⚠️ غير متصل بشاشات |
| `favorite_repository.dart` | ⚠️ غير متصل |
| `message_repository.dart` | ⚠️ غير متصل |
| `notification_repository.dart` | ⚠️ غير متصل |
| `search_repository.dart` | ⚠️ غير متصل |

### 8.3 ⚠️ مجلدات widgets فارغة
كل feature لها مجلد `widgets/` فارغ - يحتاج إنشاء widget components لكل feature.

### 8.4 ⚠️ `Preferences` class مكرر
- `core/storage/preferences.dart` و `core/storage/app_preferences.dart` لهما وظائف متداخلة

### 8.5 ⚠️ خط Tajawal غير مُعرّف في pubspec.yaml
**المشكلة:** `AppTypography` يستخدم `fontFamily: 'Tajawal'` لكن الخط غير مُعرّف في `pubspec.yaml` ولا في مجلد `assets/fonts/`.

---

## 📋 خطة التنفيذ المقترحة (بالأولوية)

### المرحلة 1: إصلاح الأخطاء الحرجة (اليوم)
- [ ] 1.1 إصلاح خطأ `forgot_password_screen.dart` (نوع callback)
- [ ] 1.2 إصلاح `widget_test.dart` (MyApp → DealakAppWithApiConfig)
- [ ] 2.1-2.3 إصلاح التحذيرات (imports غير مستخدمة)
- [ ] 3.1-3.2 إصلاح المعلومات (deprecated + unused import)

### المرحلة 2: إصلاح المعمارية الأساسية (1-2 أيام)
- [ ] 4.2 ربط `DealakAppWithApiConfig` → `DealakApp` (استخدام الـ Router الحقيقي)
- [ ] 4.3 تمرير `baseUrl` ديناميكياً من الإعدادات إلى DioClient
- [ ] 4.1 تفعيل AuthGuard بمنطق حماية فعلي
- [ ] 4.5 ربط التنقل في ProfileScreen
- [ ] 4.6 ربط التنقل في HomeScreen
- [ ] 7.1 تسجيل AdminMiddleware
- [ ] 7.2 تفعيل ForceJsonResponse
- [ ] 6.1-6.4 إصلاح API Contract mismatches

### المرحلة 3: بناء الشاشات الأساسية (3-5 أيام)
- [ ] PropertyDetailScreen - عرض تفاصيل العقار + صور + خريطة + مالك + تقييمات
- [ ] PropertyListScreen - قائمة عقارات مع فلاتر وترقيم صفحات
- [ ] PropertyCreateScreen - نموذج إضافة عقار كامل مع رفع صور
- [ ] SearchScreen - بحث نصي + فلاتر متقدمة + اقتراحات
- [ ] FavoritesScreen - قائمة المفضلة مع إمكانية الحذف
- [ ] ConversationsScreen - قائمة المحادثات مع آخر رسالة
- [ ] ChatScreen - محادثة فعلية مع إرسال/استقبال رسائل

### المرحلة 4: بناء الشاشات الثانوية (2-3 أيام)
- [ ] EditProfileScreen - تعديل البيانات الشخصية + الصورة
- [ ] MyPropertiesScreen - عقاراتي مع خيارات تعديل/حذف
- [ ] DealsListScreen - قائمة الصفقات مع حالاتها
- [ ] DealDetailScreen - تفاصيل صفقة + مدفوعات
- [ ] NotificationsScreen - الإشعارات مع mark as read
- [ ] SettingsScreen - إعدادات (ثيم، لغة، إشعارات)
- [ ] RequestsListScreen - الطلبات العقارية
- [ ] CreateRequestScreen - إنشاء طلب عقاري
- [ ] AdminDashboardScreen - لوحة تحكم المدير

### المرحلة 5: التحسينات والبولندة (2 أيام)
- [ ] إضافة خط Tajawal للمشروع
- [ ] إنشاء ملفات assets المطلوبة
- [ ] دمج Preferences مع AppPreferences
- [ ] بناء widget components مشتركة لكل feature
- [ ] إضافة pull-to-refresh و infinite scrolling
- [ ] إضافة Shimmer loading effects
- [ ] تحسين Error handling مع Retry
- [ ] كتابة اختبارات widget أساسية

---

## 🎯 ملاحظات مهمة للتنفيذ

1. **الأولوية المطلقة**: المراحل 1 و 2 - بدونها التطبيق **لا يعمل** أصلاً (Router معطّل، API baseUrl ثابت)
2. **يجب فحص Laravel middleware registration** قبل أي شيء آخر
3. **كل شاشة يجب أن تستخدم** Provider + Repository الموجودين (لا حاجة لإنشاء جديد)
4. **فحص `PropertyCollection`** وبقية Collections للتأكد من هيكل pagination
5. **تشغيل `flutter analyze` بعد كل إصلاح** للتأكد من عدم إدخال أخطاء جديدة
6. **تشغيل `php artisan route:list`** للتحقق من تسجيل كل المسارات صحيحياً

---

## 🧪 خطة QA بعد الإصلاح

```
1. flutter analyze → 0 errors, 0 warnings
2. تشغيل التطبيق → يظهر API Settings → يتصل بالسيرفر → يظهر الشاشة الرئيسية
3. تسجيل حساب جديد → يعمل ✓
4. تسجيل دخول → يعمل ✓
5. AuthGuard يمنع الوصول بدون تسجيل → يعمل ✓
6. الشاشة الرئيسية تعرض العقارات المميزة ✓
7. الضغط على عقار → تفاصيل كاملة ✓
8. البحث عن عقار → نتائج ✓
9. إضافة/حذف من المفضلة ✓
10. المحادثات تعمل ✓
11. php artisan test → كل الاختبارات تمر ✓
```
