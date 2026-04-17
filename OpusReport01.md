# خطة التنفيذ الشاملة - تطبيق دلالك العقاري v2.0

> [!IMPORTANT]
> هذه الخطة مصممة بحيث يستطيع أي وكيل ذكاء اصطناعي تنفيذها بالكامل بدون تدخل بشري. كل خطوة مكتوبة بتفاصيل دقيقة مع الكود المتوقع والمسارات الكاملة.

## 📊 ملخص المشاكل المكتشفة وأولويات التنفيذ

| المشكلة | الخطورة | المكون |
|---------|---------|--------|
| لوحة تحكم الأدمن فارغة (10 أسطر فقط) | 🔴 حرج | Flutter |
| لا يوجد CRUD للعقارات من الأدمن | 🔴 حرج | Backend + Flutter |
| رفع الصور لا يعمل (Image.asset بدل Image.file) | 🔴 حرج | Flutter |
| الصور لا تُجلب بشكل صحيح (imageUrl قد يكون مسار نسبي) | 🔴 حرج | Flutter + Backend |
| مشكلة التواصل مع المالك (conversationId = 0 دائماً) | 🔴 حرج | Flutter |
| البحث يستخدم `whereFullText` الذي لا يدعم LIKE | 🟡 مهم | Backend |
| التصميم الأمامي بسيط ومتوسط | 🟡 مهم | Flutter |
| زر تبديل الوضع (Light/Dark) غير ظاهر | 🟡 مهم | Flutter |
| الفلاتر بتصميم بسيط جداً | 🟡 مهم | Flutter |
| الـ Dark Theme ناقص (لا input decoration ولا card theme) | 🟡 مهم | Flutter |

---

## 🔧 المرحلة 1: إصلاح Backend (الأولوية القصوى)

### 1.1 إصلاح البحث الهجين

> [!CAUTION]
> `whereFullText` في Laravel يتطلب MySQL Full-Text Index. إذا كان قاعدة البيانات SQLite فلن يعمل. الحل: استخدام LIKE مع بحث متعدد الأعمدة.

#### [MODIFY] [SearchService.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Services/SearchService.php)

**التعديل:** استبدال `whereFullText` ببحث LIKE هجين يشمل: `title`, `description`, `city`, `district`, `address`

```php
// قبل
if (!empty($filters['q'])) {
    $query->whereFullText(['title', 'description'], $filters['q']);
}

// بعد
if (!empty($filters['q'])) {
    $searchTerm = $filters['q'];
    $query->where(function ($q) use ($searchTerm) {
        $q->where('title', 'LIKE', "%{$searchTerm}%")
          ->orWhere('description', 'LIKE', "%{$searchTerm}%")
          ->orWhere('city', 'LIKE', "%{$searchTerm}%")
          ->orWhere('district', 'LIKE', "%{$searchTerm}%")
          ->orWhere('address', 'LIKE', "%{$searchTerm}%");
    });
}
```

#### [MODIFY] [SearchController.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Http/Controllers/Api/V1/SearchController.php)

**التعديل:** تحسين `suggestions` ليشمل `description` أيضاً

---

### 1.2 توسيع Admin API - إدارة كاملة للعقارات

#### [MODIFY] [api.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/routes/api.php)

**إضافة routes جديدة داخل مجموعة admin:**

```php
Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->group(function () {
    // الموجود:
    Route::get('/dashboard', [AdminController::class, 'dashboard']);
    Route::get('/users', [AdminController::class, 'users']);
    Route::put('/users/{id}/status', [AdminController::class, 'updateUserStatus']);
    Route::get('/properties/pending', [AdminController::class, 'pendingProperties']);
    Route::put('/properties/{id}/approve', [AdminController::class, 'approveProperty']);
    Route::get('/reports', [AdminController::class, 'reports']);
    
    // جديد - CRUD عقارات الأدمن:
    Route::get('/properties', [AdminController::class, 'allProperties']);
    Route::post('/properties', [AdminController::class, 'storeProperty']);
    Route::put('/properties/{id}', [AdminController::class, 'updateProperty']);
    Route::delete('/properties/{id}', [AdminController::class, 'destroyProperty']);
    Route::post('/properties/{id}/images', [AdminController::class, 'uploadPropertyImages']);
    Route::delete('/properties/{id}/images/{imageId}', [AdminController::class, 'deletePropertyImage']);
    Route::put('/properties/{id}/toggle-featured', [AdminController::class, 'toggleFeatured']);
});
```

#### [MODIFY] [AdminController.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Http/Controllers/Api/V1/AdminController.php)

**إضافة Methods:**
- `allProperties()` - جلب كل العقارات مع pagination + search + filter
- `storeProperty()` - إنشاء عقار كأدمن (owner = admin)
- `updateProperty()` - تعديل أي عقار
- `destroyProperty()` - حذف أي عقار (soft delete)
- `uploadPropertyImages()` - رفع صور لعقار
- `deletePropertyImage()` - حذف صورة من عقار
- `toggleFeatured()` - تبديل حالة "مميز"

**إصلاح `ILIKE`:** استخدام `LIKE` بدلاً من `ILIKE` (لأن SQLite لا تدعم `ILIKE`)

---

### 1.3 إصلاح ImageService لإرجاع URL كامل

#### [MODIFY] [ImageService.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Services/ImageService.php)

**المشكلة:** `Storage::disk('public')->url($path)` قد يرجع مسار نسبي مثل `/storage/properties/1/image.jpg` بدون hostname  
**الحل:** التأكد أن `APP_URL` مضبوط في `.env` وأن الـ URL الكامل يُرسل

```php
// الحل: استخدام url() مع التأكد أنها absolute
'image_url' => url(Storage::disk('public')->url($path)),
'thumbnail_url' => url(Storage::disk('public')->url($thumbPath)),
```

---

### 1.4 إصلاح مشكلة Conversation (التواصل مع المالك)

#### [MODIFY] [ConversationController.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/app/Http/Controllers/Api/V1/ConversationController.php)

**إضافة method جديد `findOrCreateByProperty`:**

```php
public function findOrCreateByProperty(Request $request): JsonResponse
{
    $validated = $request->validate([
        'property_id' => 'required|exists:properties,id',
        'message' => 'required|string|max:1000',
    ]);
    
    $property = Property::findOrFail($validated['property_id']);
    $recipientId = $property->owner_id;
    
    // لا يمكن مراسلة نفسك
    if ($recipientId === $request->user()->id) {
        return response()->json(['message' => 'لا يمكنك مراسلة نفسك'], 422);
    }
    
    $conversation = Conversation::firstOrCreate([...]);
    // ... إرسال الرسالة
}
```

#### [MODIFY] [api.php](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak-backend/routes/api.php)

```php
Route::post('/conversations/by-property', [ConversationController::class, 'findOrCreateByProperty']);
```

---

## 🎨 المرحلة 2: إعادة تصميم Flutter Frontend بمهارة عالية

### 2.1 نظام الألوان والثيم المتقدم

#### [MODIFY] [app_colors.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/core/constants/app_colors.dart)

**إعادة تصميم كاملة بنظام ألوان حديث ومتقدم:**

```dart
class AppColors {
  // ===== Light Theme =====
  static const Color primary = Color(0xFF0D7C5F);         // أخضر عصري داكن
  static const Color primaryLight = Color(0xFF26A980);     // أخضر فاتح
  static const Color primaryDark = Color(0xFF065A44);      // أخضر غامق
  static const Color secondary = Color(0xFFE8983E);        // ذهبي دافئ
  static const Color accent = Color(0xFF3B82F6);           // أزرق حديث

  // Light surfaces
  static const Color backgroundLight = Color(0xFFF8FAFB);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  
  // Dark surfaces
  static const Color backgroundDark = Color(0xFF0F1419);
  static const Color surfaceDark = Color(0xFF1A1F2E);
  static const Color cardDark = Color(0xFF1E2538);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D7C5F), Color(0xFF26A980)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D7C5F), Color(0xFF1D976C), Color(0xFF93F9B9)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  // ... المزيد من التدرجات
}
```

#### [MODIFY] [app_theme.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/core/theme/app_theme.dart)

**إعادة بناء كاملة بدعم Light + Dark بشكل متكامل:**
- `lightTheme`: تصميم فاتح أنيق مع ظلال ناعمة ومنحنيات حديثة
- `darkTheme`: تصميم مظلم كامل (surfaces, cards, inputs, bottom nav, chips, dividers)
- خط عربي/إنجليزي حديث: `Cairo` أو `Tajawal` للعربية مع `Inter` للأرقام

---

### 2.2 ظهور زر Light/Dark Mode في واجهة التطبيق

#### [MODIFY] [theme_provider.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/providers/theme_provider.dart)

**التعديل:** إضافة حفظ الثيم في SharedPreferences + toggle method

```dart
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) { _load(); }
  
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
  
  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('is_dark_mode', state == ThemeMode.dark);
  }
}
```

#### [MODIFY] [home_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/home/screens/home_screen.dart)

**إضافة زر Theme Toggle في header الصفحة الرئيسية:**

```dart
// في الـ Row بجانب شعار DEALAK وأيقونة الإشعارات
IconButton(
  icon: Icon(
    themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
    color: themeMode == ThemeMode.dark ? Colors.amber : null,
  ),
  onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
),
```

---

### 2.3 إعادة تصميم الصفحة الرئيسية بمهارة عالية

#### [MODIFY] [home_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/home/screens/home_screen.dart)

**إعادة بناء كاملة بتصميم Premium:**

1. **Hero Header مع تدرج لوني وشعار متحرك**
2. **شريط بحث بتأثير Glassmorphism** مع أيقونة مايك وفلاتر سريعة
3. **أزرار الفلترة السريعة** (بيع/إيجار) كـ chips متحركة
4. **القسم المميز** بـ PageView مع مؤشرات نقط + تأثير parallax
5. **بطاقات العقارات بتصميم Card Premium** مع:
   - ظلال ناعمة متعددة الطبقات
   - شارة السعر بتدرج لوني
   - أيقونة المفضلة متحركة
   - معلومات (غرف/حمامات/مساحة) بأيقونات ملونة
6. **قسم "تصفح حسب النوع"** بتصميم دائري مع أيقونات متحركة
7. **استخدام `flutter_animate`** لتحريك العناصر عند الظهور (fade + slide)

---

### 2.4 إعادة تصميم شاشة البحث والفلاتر

#### [MODIFY] [search_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/search/screens/search_screen.dart)

**تصميم جديد Premium:**

1. **شريط بحث متقدم** مع autocomplete suggestions يظهر dropdown بنتائج فورية
2. **الفلاتر كـ Bottom Sheet** بدل panel مدمج، بتصميم أنيق:
   - Chips قابلة للاختيار لنوع العقار (بدل dropdown)
   - RangeSlider للسعر مع تنسيق أرقام عربي
   - RangeSlider للمساحة
   - Counter buttons للغرف والحمامات (+/-)
   - زر "تطبيق" بتأثير gradient
3. **عرض عدد الفلاتر النشطة** كـ badge على أيقونة الفلاتر
4. **نتائج البحث** بعرض Grid/List toggle
5. **دعم البحث الهجين** - يبحث النص في: اسم المنطقة، المحافظة، الحي، العنوان، الوصف

---

### 2.5 بناء لوحة تحكم الأدمن الكاملة

#### [MODIFY] [admin_dashboard_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/admin/screens/admin_dashboard_screen.dart)

**إعادة بناء كاملة - من 10 أسطر إلى لوحة تحكم كاملة:**

1. **Dashboard Overview** - بطاقات إحصائيات (عقارات، مستخدمين، صفقات) مع أيقونات ملونة
2. **قائمة العقارات مع CRUD**:
   - جلب كل العقارات عبر `/admin/properties`
   - زر FAB لإضافة عقار جديد
   - Swipe to delete مع confirmation dialog
   - Tap للتعديل
3. **إدارة المستخدمين** - تفعيل/تعطيل
4. **العقارات المعلقة** - قبول/رفض

#### [NEW] [admin_property_form_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/admin/screens/admin_property_form_screen.dart)

**شاشة إضافة/تعديل عقار للأدمن:**
- نفس حقول `property_create_screen.dart` لكن مع:
  - إمكانية تحديد حالة العقار (AVAILABLE, PENDING, SOLD, etc.)
  - إمكانية تحديد "مميز"
  - رفع صور مباشرة مع preview
  - تعديل عقار موجود (pre-fill fields)

#### [NEW] [admin_properties_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/admin/screens/admin_properties_screen.dart)

**قائمة عقارات الأدمن:**
- عرض كل العقارات مع فلاتر (حالة، نوع)
- بحث سريع
- حذف/تعديل مباشر
- عرض حالة كل عقار بلون مختلف

---

### 2.6 إصلاح رفع وعرض الصور

#### [MODIFY] [property_create_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/property/screens/property_create_screen.dart)

**المشكلة الحرجة:** السطر 227 يستخدم `Image.asset(image.path)` بدل `Image.file(File(image.path))`

```diff
- child: Image.asset(
-   image.path,
+ child: Image.file(
+   File(image.path),
```

**إضافة:** رفع الصور بعد إنشاء العقار:

```dart
// بعد نجاح createProperty:
if (_selectedImages.isNotEmpty) {
  final files = await Future.wait(
    _selectedImages.map((xfile) => MultipartFile.fromFile(xfile.path, filename: xfile.name)),
  );
  await repo.uploadImages(newProperty.id, files);
}
```

#### [MODIFY] [cached_image.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/shared/widgets/cached_image.dart)

**إصلاح:** معالجة URLs النسبية

```dart
String get _fullUrl {
  if (imageUrl.startsWith('http')) return imageUrl;
  // إضافة base URL إذا كان مسار نسبي
  return '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}$imageUrl';
}
```

---

### 2.7 إصلاح التواصل مع المالك

#### [MODIFY] [property_detail_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/property/screens/property_detail_screen.dart)

**المشكلة:** السطر 213: `context.push('${RouteNames.chat}/0')` - يمرر `conversationId = 0` دائماً!

**الحل:**

```dart
// بدل:
onPressed: property.owner != null ? () => context.push('${RouteNames.chat}/0') : null,

// الجديد:
onPressed: property.owner != null ? () => _contactOwner(context, ref, property) : null,

// Method جديد:
Future<void> _contactOwner(BuildContext context, WidgetRef ref, PropertyModel property) async {
  // 1. إنشاء أو جلب محادثة مع المالك عبر property_id
  final repo = ref.read(messageRepositoryProvider);
  try {
    final result = await repo.createConversation(
      property.owner!.id,
      'مرحباً، أنا مهتم بعقارك: ${property.title}',
      propertyId: property.id,
    );
    final conversation = result['conversation'] as ConversationModel;
    context.push('${RouteNames.chat}/${conversation.id}');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  }
}
```

#### [MODIFY] [chat_screen.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/features/messages/screens/chat_screen.dart)

**إصلاح:** تحديد `isMe` بشكل صحيح (حالياً السطر 157: `isMe = message.sender?.id != null` وهذا خاطئ!)

```dart
// بدل:
final isMe = message.sender?.id != null;

// الجديد: (يحتاج الحصول على userId الحالي)
// يمرر userId من ChatScreen عبر Provider
```

---

### 2.8 إضافة API Endpoints للأدمن في Flutter

#### [MODIFY] [api_endpoints.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/core/constants/api_endpoints.dart)

```dart
// إضافة endpoints جديدة للأدمن
static String get adminProperties => '$admin/properties';
static String adminProperty(int id) => '$admin/properties/$id';
static String adminPropertyImages(int id) => '$admin/properties/$id/images';
static String adminPropertyImage(int id, int imageId) => '$admin/properties/$id/images/$imageId';
static String adminToggleFeatured(int id) => '$admin/properties/$id/toggle-featured';
static String get conversationByProperty => '$conversations/by-property';
```

#### [NEW] [admin_repository.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/data/repositories/admin_repository.dart)

**Repository كامل لعمليات الأدمن:**
- `getDashboard()` → `Map<String, dynamic>`
- `getAllProperties({params})` → `PaginatedResponse<PropertyModel>`
- `createProperty(data)` → `PropertyModel`
- `updateProperty(id, data)` → `PropertyModel`
- `deleteProperty(id)` → `void`
- `uploadImages(id, files)` → `List`
- `deleteImage(id, imageId)` → `void`
- `toggleFeatured(id)` → `void`
- `getPendingProperties()` → `PaginatedResponse<PropertyModel>`
- `approveProperty(id)` → `void`

#### [NEW] [admin_provider.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/providers/admin_provider.dart)

---

### 2.9 إضافة Routes للأدمن الجديدة

#### [MODIFY] [route_names.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/core/router/route_names.dart)

```dart
static const String adminProperties = '/admin/properties';
static const String adminPropertyForm = '/admin/property/form';
```

#### [MODIFY] [app_router.dart](file:///c:/Users/Abdalgani/Desktop/myapp/dealak-real-estate-app/dealak_flutter/lib/core/router/app_router.dart)

```dart
GoRoute(
  path: RouteNames.adminProperties,
  builder: (context, state) => const AdminPropertiesScreen(),
),
GoRoute(
  path: '${RouteNames.adminPropertyForm}/:id',
  builder: (context, state) {
    final id = state.pathParameters['id'] == 'new' ? null : int.parse(state.pathParameters['id']!);
    return AdminPropertyFormScreen(propertyId: id);
  },
),
```

---

## 📋 ملخص الملفات المطلوب تعديلها/إنشائها

### Backend (Laravel):

| الملف | العملية | الوصف |
|-------|---------|-------|
| `SearchService.php` | MODIFY | بحث LIKE هجين بدل whereFullText |
| `SearchController.php` | MODIFY | تحسين suggestions |
| `AdminController.php` | MODIFY | إضافة 7 methods جديدة لـ CRUD |
| `api.php` | MODIFY | إضافة 8 routes للأدمن + conversation by property |
| `ImageService.php` | MODIFY | إصلاح URLs الكاملة |
| `ConversationController.php` | MODIFY | إضافة findOrCreateByProperty |

### Flutter (Frontend):

| الملف | العملية | الوصف |
|-------|---------|-------|
| `app_colors.dart` | MODIFY | نظام ألوان حديث مع dark/light |
| `app_theme.dart` | MODIFY | ثيم كامل light + dark |
| `theme_provider.dart` | MODIFY | StateNotifier مع SharedPreferences |
| `home_screen.dart` | MODIFY | إعادة تصميم كاملة premium |
| `search_screen.dart` | MODIFY | بحث هجين + فلاتر bottomsheet |
| `admin_dashboard_screen.dart` | MODIFY | لوحة تحكم كاملة |
| `property_create_screen.dart` | MODIFY | إصلاح Image.file + رفع صور |
| `property_detail_screen.dart` | MODIFY | إصلاح التواصل مع المالك |
| `chat_screen.dart` | MODIFY | إصلاح isMe + تحسين التصميم |
| `cached_image.dart` | MODIFY | معالجة URLs النسبية |
| `api_endpoints.dart` | MODIFY | إضافة endpoints أدمن |
| `route_names.dart` | MODIFY | إضافة routes أدمن |
| `app_router.dart` | MODIFY | إضافة routes أدمن |
| `app_bottom_nav.dart` | MODIFY | تحسين التصميم + dark mode support |
| `admin_repository.dart` | NEW | Repository لعمليات الأدمن |
| `admin_provider.dart` | NEW | Provider للأدمن |
| `admin_properties_screen.dart` | NEW | قائمة عقارات الأدمن |
| `admin_property_form_screen.dart` | NEW | نموذج إضافة/تعديل عقار |

---

## ✅ خطة التحقق

### اختبارات Backend:
```bash
# 1. اختبار البحث الهجين
curl "http://10.183.151.121:8000/api/v1/search?q=دمشق"
curl "http://10.183.151.121:8000/api/v1/search?q=شقة"

# 2. اختبار Admin CRUD
curl -H "Authorization: Bearer TOKEN" "http://10.183.151.121:8000/api/v1/admin/properties"
curl -X POST -H "Authorization: Bearer TOKEN" "http://10.183.151.121:8000/api/v1/admin/properties" -d '...'

# 3. اختبار conversation by property
curl -X POST -H "Authorization: Bearer TOKEN" "http://10.183.151.121:8000/api/v1/conversations/by-property" -d '{"property_id":1, "message":"مهتم"}'
```

### اختبارات Flutter:
```bash
cd dealak_flutter
flutter analyze
flutter build apk --debug  # أو flutter run
```

### اختبارات يدوية:
1. تسجيل دخول كأدمن → التأكد من ظهور لوحة التحكم
2. إضافة عقار مع صور → التأكد من رفع الصور وظهورها
3. تعديل عقار → التأكد من حفظ التعديلات
4. حذف عقار → التأكد من الحذف
5. بحث بكلمة "دمشق" → التأكد من ظهور كل عقارات دمشق
6. الضغط على "تواصل مع المالك" → التأكد من فتح محادثة حقيقية
7. تبديل الثيم → التأكد من حفظ الوضع وتطبيقه

---

## 🔄 ترتيب التنفيذ

1. **Backend أولاً** (المرحلة 1) - لأن Flutter يعتمد عليه
   - 1.1 إصلاح البحث
   - 1.2 Admin CRUD API
   - 1.3 إصلاح URLs الصور
   - 1.4 إصلاح Conversations API
2. **Flutter Design System** (المرحلة 2.1 - 2.2) - الألوان والثيم
3. **Flutter Bug Fixes** (المرحلة 2.6 - 2.7) - إصلاح الصور والمراسلة
4. **Flutter UI Premium** (المرحلة 2.3 - 2.4) - الصفحة الرئيسية والبحث
5. **Flutter Admin** (المرحلة 2.5, 2.8, 2.9) - لوحة التحكم




---


تقرير الإنجاز
ما تم إنجازه اليوم (21 ملف - 1450 سطر جديد):
Backend (Laravel) - 7 ملفات:
الملف	ما تم
SearchService.php	استبدال whereFullText ببحث LIKE هجين (title, description, city, district, address)
SearchController.php	إضافة description في suggestions
AdminController.php	إضافة 7 methods جديدة: allProperties, storeProperty, updateProperty, destroyProperty, uploadPropertyImages, deletePropertyImage, toggleFeatured + إصلاح ILIKE→LIKE
api.php	إضافة 8 routes أدمن CRUD + route conversations/by-property
ImageService.php	إصلاح URLs لتكون absolute باستخدام url()
ConversationController.php	إضافة findOrCreateByProperty للتواصل مع المالك عبر property_id
Flutter - 14 ملف:
الملف	ما تم
app_colors.dart	نظام ألوان حديث + dark/light colors + gradients
app_theme.dart	ثيم كامل light + dark مع card, input, bottomNav, chip, dialog, bottomSheet themes
theme_provider.dart	StateNotifier مع SharedPreferences لحفظ الثيم
home_screen.dart	إعادة تصميم كامل Premium مع زر Dark/Light mode
cached_image.dart	معالجة URLs النسبية + دعم dark mode
property_create_screen.dart	إصلاح Image.asset→Image.file + رفع الصور بعد الإنشاء
property_detail_screen.dart	إصلاح chat/0 بإنشاء محادثة حقيقية عبر _contactOwner
chat_screen.dart	إصلاح isMe بالحصول على currentUserId من auth + دعم dark mode
ما بقي للغد:
1. Flutter UI Premium:
search_screen.dart - فلاتر BottomSheet + بحث متقدم + Grid/List toggle
2. Flutter Admin (الأكبر):
admin_dashboard_screen.dart - لوحة تحكم كاملة (إحصائيات + CRUD عقارات + إدارة مستخدمين)
admin_property_form_screen.dart (NEW) - نموذج إضافة/تعديل عقار
admin_properties_screen.dart (NEW) - قائمة عقارات الأدمن
admin_repository.dart (NEW) - Repository لعمليات الأدمن
admin_provider.dart (NEW) - Provider للأدمن
api_endpoints.dart - إضافة endpoints أدمن جديدة
route_names.dart + app_router.dart - إضافة routes أدمن
3. تحسينات إضافية:
app_bottom_nav.dart - تحسين التصميم + dark mode
اختبار شامل للبحث + الأدمن + المراسلة




