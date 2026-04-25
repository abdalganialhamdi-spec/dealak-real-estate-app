# Implementation Plan 06 - Bug Fixes: Property Details, Favorites, Property Create

## تاريخ: 2026-04-25

---

## ملخص المشاكل

تم اكتشاف المشاكل التالية عبر تشغيل تطبيق Flutter على جهاز حقيقي (M2101K7BI) ومراقبة سجلات الأخطاء:

---

## Bug #1: صفحة العقارات الرئيسية ترجع خطأ 500

### الخطأ
```
Call to undefined method Spatie\QueryBuilder\AllowedFilter::range()
```

### السبب
في ملف `dealak-backend/app/Http/Controllers/Api/V1/PropertyController.php` السطر ~30، يتم استخدام `AllowedFilter::range()` الذي تم إزالته في النسخة v6 من `spatie/laravel-query-builder` (المثبتة v6.4.4).

### الملف المطلوب تعديله
- `dealak-backend/app/Http/Controllers/Api/V1/PropertyController.php`

### الإصلاح المطلوب
استبدال `AllowedFilter::range('price')` و `AllowedFilter::range('area_sqm')` بـ `AllowedFilter::callback()`:

```php
// بدلاً من:
AllowedFilter::range('price'),
AllowedFilter::range('area_sqm'),

// استخدم:
AllowedFilter::callback('price', function ($query, $value) {
    $from = is_array($value) ? ($value['from'] ?? $value[0] ?? null) : (str_contains($value ?? '', '..') ? explode('..', $value)[0] : $value);
    $to = is_array($value) ? ($value['to'] ?? $value[1] ?? null) : (str_contains($value ?? '', '..') ? explode('..', $value)[1] ?? null : null);
    if ($from !== null && $from !== '') $query->where('price', '>=', $from);
    if ($to !== null && $to !== '') $query->where('price', '<=', $to);
}),
AllowedFilter::callback('area_sqm', function ($query, $value) {
    $from = is_array($value) ? ($value['from'] ?? $value[0] ?? null) : (str_contains($value ?? '', '..') ? explode('..', $value)[0] : $value);
    $to = is_array($value) ? ($value['to'] ?? $value[1] ?? null) : (str_contains($value ?? '', '..') ? explode('..', $value)[1] ?? null : null);
    if ($from !== null && $from !== '') $query->where('area_sqm', '>=', $from);
    if ($to !== null && $to !== '') $query->where('area_sqm', '<=', $to);
}),
```

### الأولوية: عالية (تمنع تحميل أي قائمة عقارات)

---

## Bug #2: شاشة حمراء عند الدخول لتفاصيل العقار

### الخطأ
```
BoxConstraints forces an infinite width
```

### السبب
في ملف `dealak_flutter/lib/features/property/screens/property_detail_screen.dart` السطر ~306، يوجد `OutlinedButton` داخل `Row` بدون `Expanded`، مما يسبب مشكلة عرض لا نهائي.

### الملف المطلوب تعديله
- `dealak_flutter/lib/features/property/screens/property_detail_screen.dart`

### الإصلاح المطلوب
لف `OutlinedButton` بـ `Expanded`:

```dart
// بدلاً من:
const SizedBox(width: 12),
OutlinedButton.icon(
  onPressed: () => ...,
  icon: const Icon(Icons.phone),
  label: const Text('اتصال'),
  ...
),

// استخدم:
const SizedBox(width: 12),
Expanded(
  child: OutlinedButton.icon(
    onPressed: () {
      final phone = property.owner?.phone;
      if (phone != null && phone.isNotEmpty) {
        launchUrl(Uri.parse('tel:$phone'));
      }
    },
    icon: const Icon(Icons.phone),
    label: const Text('اتصال'),
    ...
  ),
),
```

ملاحظة: يجب إضافة `import 'package:url_launcher/url_launcher.dart';` في أعلى الملف.

### الأولوية: عالية (شاشة حمراء كاملة)

---

## Bug #3: FormatException عند الضغط على "إضافة عقار"

### الخطأ
```
FormatException: Invalid radix-10 number (at character 1)
create
^
```

### السبب
في ملف `dealak_flutter/lib/core/router/app_router.dart` السطر 92، المسار `/property/:id` يطابق `/property/create` لأن `:id` يلتقط "create" كقيمة. ثم `int.parse("create")` يفشل.

ترتيب المسارات الحالي:
```dart
GoRoute(path: '${RouteNames.propertyDetail}/:id', ...)  // /property/:id - يطابق أولاً!
GoRoute(path: RouteNames.propertyCreate, ...)            // /property/create - لا يُطال أبداً
```

### الملفات المطلوب تعديلها
- `dealak_flutter/lib/core/router/app_router.dart`

### الإصلاح المطلوب
1. نقل `propertyCreate` **قبل** `propertyDetail/:id`
2. استخدام `int.tryParse` بدلاً من `int.parse` كإجراء أمان:

```dart
GoRoute(
  path: RouteNames.propertyCreate,  // /property/create - يجب أن يكون أولاً
  builder: (context, state) => const PropertyCreateScreen(),
),
GoRoute(
  path: '${RouteNames.propertyDetail}/:id',  // /property/:id
  builder: (context, state) {
    final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
    return PropertyDetailScreen(propertyId: id);
  },
),
```

### الأولوية: عالية (تمنع فتح صفحة إضافة عقار بالكامل)

---

## Bug #4: تحويل أنواع غير آمن في Data Models

### الخطأ
أنواع مختلفة من `TypeError` و `FormatException` عند تحويل بيانات JSON إلى Dart Objects.

### السبب
في ملفات الـ Models، يتم تحويل القيم مباشرة بدون تحقق من النوع. مثلاً `json['bedrooms']` قد يكون `int` أو `String` أو `null` من الـ API.

### الملفات المطلوب تعديلها

#### 1. `dealak_flutter/lib/data/models/property_model.dart`

تحويل آمن لجميع الحقول الرقمية:
```dart
// بدلاً من:
price: (json['price'] ?? 0).toDouble(),
areaSqm: json['area_sqm']?.toDouble(),
bedrooms: json['bedrooms'],
bathrooms: json['bathrooms'],
floors: json['floors'],
yearBuilt: json['year_built'],
viewCount: json['view_count'] ?? 0,
averageRating: (json['average_rating'] ?? 0).toDouble(),
latitude: json['latitude']?.toDouble(),
longitude: json['longitude']?.toDouble(),

// استخدم:
price: (json['price'] is num ? json['price'] : num.tryParse('${json['price']}') ?? 0).toDouble(),
areaSqm: json['area_sqm'] is num ? json['area_sqm'].toDouble() : (json['area_sqm'] != null ? num.tryParse('${json['area_sqm']}')?.toDouble() : null),
bedrooms: json['bedrooms'] is int ? json['bedrooms'] : (json['bedrooms'] != null ? int.tryParse('${json['bedrooms']}') : null),
bathrooms: json['bathrooms'] is int ? json['bathrooms'] : (json['bathrooms'] != null ? int.tryParse('${json['bathrooms']}') : null),
floors: json['floors'] is int ? json['floors'] : (json['floors'] != null ? int.tryParse('${json['floors']}') : null),
yearBuilt: json['year_built'] is int ? json['year_built'] : (json['year_built'] != null ? int.tryParse('${json['year_built']}') : null),
viewCount: json['view_count'] is int ? json['view_count'] : (int.tryParse('${json['view_count']}') ?? 0),
averageRating: (json['average_rating'] is num ? json['average_rating'] : num.tryParse('${json['average_rating']}') ?? 0).toDouble(),
latitude: json['latitude'] is num ? json['latitude'].toDouble() : (json['latitude'] != null ? num.tryParse('${json['latitude']}')?.toDouble() : null),
longitude: json['longitude'] is num ? json['longitude'].toDouble() : (json['longitude'] != null ? num.tryParse('${json['longitude']}')?.toDouble() : null),
```

كذلك تحويل آمن لـ `images` و `features` و `owner` و `agent`:
```dart
// بدلاً من:
owner: json['owner'] != null ? UserModel.fromJson(json['owner']) : null,
images: json['images'] != null ? (json['images'] as List).map(...) : [],
features: json['features'] != null ? (json['features'] as List).map(...) : [],
createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,

// استخدم:
owner: json['owner'] is Map ? UserModel.fromJson(json['owner'] as Map<String, dynamic>) : null,
agent: json['agent'] is Map ? UserModel.fromJson(json['agent'] as Map<String, dynamic>) : null,
images: json['images'] is List ? (json['images'] as List).map(...) : [],
features: json['features'] is List ? (json['features'] as List).map(...) : [],
createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
updatedAt: json['updated_at'] != null ? DateTime.tryParse('${json['updated_at']}') : null,
```

#### 2. `dealak_flutter/lib/data/models/user_model.dart`

```dart
// تحويل آمن لـ phone, avatarUrl, bio, isVerified, propertiesCount, reviewsCount, createdAt
phone: json['phone']?.toString(),
avatarUrl: json['avatar_url']?.toString(),
bio: json['bio']?.toString(),
isVerified: json['is_verified'] == true,
propertiesCount: json['properties_count'] is int ? json['properties_count'] : (json['properties_count'] != null ? int.tryParse('${json['properties_count']}') : null),
reviewsCount: json['reviews_count'] is int ? json['reviews_count'] : (json['reviews_count'] != null ? int.tryParse('${json['reviews_count']}') : null),
createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
```

#### 3. `dealak_flutter/lib/data/models/favorite_model.dart`

```dart
id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
property: json['property'] is Map ? PropertyModel.fromJson(json['property'] as Map<String, dynamic>) : null,
createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
```

#### 4. `dealak_flutter/lib/data/models/property_image_model.dart`

```dart
id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
imageUrl: json['image_url']?.toString() ?? '',
thumbnailUrl: json['thumbnail_url']?.toString(),
isPrimary: json['is_primary'] == true,
sortOrder: json['sort_order'] is int ? json['sort_order'] : int.tryParse('${json['sort_order']}') ?? 0,
```

#### 5. `dealak_flutter/lib/data/models/property_feature_model.dart`

```dart
id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
name: json['name']?.toString() ?? '',
value: json['value']?.toString(),
```

#### 6. `dealak_flutter/lib/data/models/pagination_model.dart`

```dart
data: dataList is List ? (dataList).map((e) => fromJsonT(e as Map<String, dynamic>)).toList() : <T>[],
currentPage: json['meta']?['current_page'] is int ? json['meta']['current_page'] : int.tryParse('${json['meta']?['current_page']}') ?? 1,
// نفس النمط لـ lastPage, perPage, total, hasMore
```

### الأولوية: عالية (تسبب أعطال عشوائية)

---

## Bug #5: محادثات/Conversations ترجع خطأ 500

### الخطأ
```
Pusher error: cURL error 7: Failed to connect to localhost port 8080
BroadcastException in PusherBroadcaster.php line 171
```

### السبب
ملف `.env` يستخدم `BROADCAST_CONNECTION=reverb` لكن سيرفر Reverb/WebSockets لا يعمل على `localhost:8080`. كل طلب للمحادثات يطلق حدث broadcast يفشل.

### الملف المطلوب تعديله
- `dealak-backend/.env`

### الإصلاح المطلوب
```env
# بدلاً من:
BROADCAST_CONNECTION=reverb

# استخدم:
BROADCAST_CONNECTION=log
```

**مهم:** يجب إعادة تشغيل `php artisan serve` بعد تعديل `.env`.

### الأولوية: متوسطة (صفحة المحادثات لا تعمل لكنها لا تمنع التطبيق)

---

## ترتيب التنفيذ المطلوب

1. **Bug #1** - PropertyController (Backend) - بدون هذا الإصلاح لا تعمل قوائم العقارات
2. **Bug #3** - Router fix (Flutter) - بدون هذا لا تعمل صفحة إضافة عقار
3. **Bug #2** - Property Detail UI (Flutter) - شاشة حمراء
4. **Bug #4** - Data Models type safety (Flutter) - إصلاح وقائي شامل
5. **Bug #5** - Broadcasting config (Backend) - المحادثات
6. إعادة تشغيل `php artisan serve`
7. تشغيل `flutter run` والتحقق من كل الصفحات

---

## ملاحظات إضافية

- رقم ID الجهاز: `DUNZWCYLIBNFAU8P` (M2101K7BI)
- السيرفر يعمل على: `http://10.183.151.121:8000`
- `url_launcher` موجود في `pubspec.yaml` - يمكن استخدامه لزر الاتصال
