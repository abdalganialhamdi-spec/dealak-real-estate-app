# 📚 دليل الأكواد الشامل - DEALAK Real Estate

> **المشروع:** منصة ديلك العقارية (DEALAK)
> **تاريخ التوثيق:** أبريل 2026
> **التقنيات:** Laravel 12 (Backend) + Flutter (Frontend)

هذا الملف يشرح المعمارية البرمجية للمشروع، ويستعرض أهم الأكواد في الباك إند (Laravel) والفرونت إند (Flutter).

---

## 🏗️ 1. المعمارية البرمجية (Architecture)

يعتمد النظام على هندسة **Client-Server** باستخدام REST API:
- **Backend:** مبني على Laravel 12، يستخدم بنية `Controller -> Service -> Model`.
- **Frontend:** مبني على Flutter، يستخدم بنية طبقات (Clean Architecture مبسطة): `Screen -> Provider (Riverpod) -> Repository -> Model`.

---

## 🛠️ 2. شرح أكواد الباك إند (Laravel 12)

### 2.1. نظام الـ Routing (التوجيه)
جميع مسارات API مسجلة في `dealak-backend/routes/api.php` مع استخدام `Route::prefix('v1')`.

```php
// مسارات المصادقة
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    // ...
});

// مسارات محمية بـ Sanctum
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/properties', [PropertyController::class, 'store']);
    Route::get('/deals', [DealController::class, 'index']);
});

// مسارات الإدارة المحمية بصلاحية Admin
Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminController::class, 'dashboard']);
});
```

### 2.2. معالجة الطلبات (Controllers)
المتحكمات (Controllers) مسؤولة فقط عن استلام الطلب، استدعاء الخدمة، وإرجاع الرد بصيغة JSON. مثال `PropertyController`:

```php
public function index(Request $request): JsonResponse
{
    // استخدام Spatie QueryBuilder للفلترة والترتيب التلقائي
    $properties = QueryBuilder::for(Property::class)
        ->allowedFilters([
            'property_type', 'listing_type', 'city', 'status',
            AllowedFilter::range('price'),
        ])
        ->allowedSorts(['price', 'created_at', 'area_sqm', 'view_count'])
        ->allowedIncludes(['owner', 'images'])
        ->defaultSort('-created_at')
        ->paginate($request->per_page ?? 20);

    // إرجاع البيانات ضمن Collection لضمان Pagination المتسق
    return response()->json(new PropertyCollection($properties));
}
```

### 2.3. فصل المنطق (Services)
لمنع تضخم المتحكمات، يتم كتابة منطق العمليات المعقدة في `app/Services/`. مثال `DealService`:

```php
public function createDeal(array $data, User $user): Deal
{
    $property = Property::findOrFail($data['property_id']);
    
    // حساب العمولة (مثال: 2.5%)
    $commission = $data['amount'] * 0.025;

    $deal = Deal::create([
        ...$data,
        'commission' => $commission,
        'status' => 'PENDING',
    ]);

    // إطلاق حدث (Event) لإشعار الأطراف
    event(new DealStatusChanged($deal));

    return $deal;
}
```

### 2.4. تشكيل البيانات (API Resources)
تستخدم طبقة Resources (`app/Http/Resources/`) لتوحيد شكل البيانات المُرسلة. لقد أصلحنا جميع الموارد لضمان تناسق صفحات `Pagination`. مثال `PropertyRequestResource`:

```php
class PropertyRequestResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'property_type' => $this->property_type,
            'listing_type' => $this->listing_type,
            'min_price' => $this->min_price ? (float) $this->min_price : null,
            'status' => $this->status,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
```

### 2.5. نظام الحماية (Security & Policies)
يتم استخدام طبقة السياسات `Policies` لحماية النماذج (Models). قمنا بإنشاء `UserPolicy` لحماية بيانات المستخدمين:

```php
class UserPolicy
{
    public function update(User $authenticatedUser, User $user): bool
    {
        // يمكن للمستخدم تعديل حسابه فقط، أو يمكن للأدمن تعديل أي حساب
        return $authenticatedUser->id === $user->id || $authenticatedUser->role === 'ADMIN';
    }
}
```

---

## 📱 3. شرح أكواد الفرونت إند (Flutter)

التطبيق مقسم إلى ميزات (Features) داخل `dealak_flutter/lib/features/`. كل ميزة تحتوي على `screens` و `widgets`.

### 3.1. التوجيه (GoRouter)
نستخدم `GoRouter` مع حماية (AuthGuard) لمنع المستخدمين غير المسجلين من الدخول للصفحات المحمية.

```dart
// app_router.dart
GoRouter createRouter(AuthGuard authGuard) {
  return GoRouter(
    initialLocation: RouteNames.home,
    redirect: (context, state) => authGuard.redirect(state), // حماية المسارات
    routes: [
      ShellRoute( // مسار غلافي ليحتوي شريط التنقل السفلي
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: RouteNames.home, builder: (c, s) => const HomeScreen()),
          GoRoute(path: RouteNames.profile, builder: (c, s) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '${RouteNames.dealDetail}/:id', // مسار ديناميكي للـ ID
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DealDetailScreen(dealId: id);
        },
      ),
    ],
  );
}
```

### 3.2. طبقة إدارة الحالة (Riverpod)
نستخدم `flutter_riverpod` كبديل عصري لـ GetX و Provider. يتم تخزين الحالة وجلب البيانات بشكل نظيف.

```dart
// request_provider.dart
final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepository(ref.read(dioClientProvider)); // حقن التبعيات (DI)
});

// FutureProvider يقوم بجلب البيانات ومعالجة حالات Loading/Error/Data تلقائياً
final requestsProvider = FutureProvider<PaginatedResponse<PropertyRequestModel>>((ref) async {
  final repo = ref.read(requestRepositoryProvider);
  return repo.getRequests();
});
```

### 3.3. طبقة الاتصال بالشبكة (Dio & Repositories)
يتم تمرير `DioClient` للمستودعات لإجراء طلبات API. قمنا ببناء جميع المستودعات الناقصة (Review, Payment, Request).

```dart
// request_repository.dart
class RequestRepository {
  final DioClient _dioClient;

  RequestRepository(this._dioClient);

  Future<PaginatedResponse<PropertyRequestModel>> getRequests({int page = 1}) async {
    final response = await _dioClient.get(
      ApiEndpoints.requests,
      queryParameters: {'page': page},
    );
    // تحويل JSON إلى Objects
    return PaginatedResponse.fromJson(response.data, PropertyRequestModel.fromJson);
  }
}
```

### 3.4. واجهات المستخدم (Screens)
تتميز الشاشات بتصميم RTL عربي واستخدام حالات `AsyncValue` الخاصة بـ Riverpod.

```dart
// requests_list_screen.dart
class RequestsListScreen extends ConsumerWidget {
  const RequestsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // الاستماع لمزود البيانات
    final requestsAsync = ref.watch(requestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي العقارية')),
      body: requestsAsync.when(
        // في حالة وجود بيانات
        data: (requests) {
          if (requests.isEmpty) {
            return const EmptyStateWidget(message: 'لا توجد طلبات');
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) => _RequestCard(request: requests[index]),
          );
        },
        // أثناء التحميل
        loading: () => const LoadingWidget(),
        // في حالة وجود خطأ (مع زر إعادة المحاولة)
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.read(requestsProvider.notifier).loadRequests(),
        ),
      ),
    );
  }
}
```

---

## 🔐 4. أبرز الإصلاحات التي تمت في المشروع

تم إصلاح ومعالجة العديد من المشاكل الحرجة التي كانت تعيق عمل المشروع:

1. **مشكلة Double Hashing (التشفير المزدوج):** 
   - تم إزالة `Hash::make()` من `AuthService` و `UserController` لأنه كان يتم تشفير كلمة المرور مرة ثانية بسبب إعدادات Casts في نموذج (Model) المستخدم، مما كان يمنع تسجيل الدخول تماماً.
   
2. **ثغرة أمنية في SavedSearch (البحث المحفوظ):**
   - تم تعديل `SearchController` لضمان أن المستخدم لا يستطيع حذف بحوث تعود لمستخدمين آخرين `where('user_id', $request->user()->id)`.

3. **تناسق تنسيق البيانات (Pagination Consistency):**
   - تم إضافة `PropertyRequestResource`, `UserCollection`, و `ReviewCollection` لضمان أن كل واجهات API تُرجع استجابتها بصيغة `{ "data": [...], "meta": {...} }` الموحدة.

4. **إضافة الشاشات الناقصة في Flutter:**
   - تم برمجة شاشات (الطلبات العقارية `RequestsListScreen`، تفاصيل الصفقات `DealDetailScreen`، الإشعارات `NotificationsScreen`، إنشاء الطلب `CreateRequestScreen`) وربطها بالكامل مع الـ API و Riverpod Providers.

5. **مشاكل Context في Flutter:**
   - تم حل مشكلة `ProviderScope.containerOf(context)` التي كانت تعمل قبل بناء الـ Widget Tree (في initState) باستخدام `WidgetsBinding.instance.addPostFrameCallback`.

---
*تم التحديث بواسطة AI Assistant - 2026/04/25*
