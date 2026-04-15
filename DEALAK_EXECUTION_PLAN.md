# 🚀 DEALAK — خطة التنفيذ الفورية (Laravel MySQL + Flutter Settings)

> **التاريخ:** 15 أبريل 2026
> **الهدف:** تشغيل المشروع محلياً بـ MySQL + جعل Flutter يسأل عن IP:Port عند أول تشغيل

---

## 📊 الوضع الحالي (بعد فحص كل ملف)

### ✅ ما هو جاهز

| المكوّن | الحالة | الملفات |
|---------|--------|---------|
| **Models** (19 model) | ✅ مكتمل | `app/Models/*.php` — User, Property, Deal, Message, etc. |
| **Controllers** (12 controller) | ✅ مكتمل | `app/Http/Controllers/Api/V1/*.php` |
| **API Routes** | ✅ مكتمل | `routes/api.php` — 50+ endpoint |
| **Form Requests** (6 مجلدات) | ✅ مكتمل | `app/Http/Requests/` |
| **API Resources** (10 resources) | ✅ مكتمل | `app/Http/Resources/` |
| **Services** (8 services) | ✅ مكتمل | `app/Services/` |
| **Composer Dependencies** | ✅ مُثبت | Sanctum, Reverb, Spatie, Intervention |
| **Flutter هيكل المجلدات** | ✅ موجود | `lib/core/`, `lib/features/`, `lib/data/` |
| **Flutter pubspec.yaml** | ✅ مكتمل | Riverpod, Dio, GoRouter, etc. |

### ❌ ما هو مفقود (المطلوب الآن)

| المكوّن | الحالة | التفاصيل |
|---------|--------|----------|
| **Migrations** | ❌ فارغ تماماً | `database/migrations/` فارغ |
| **`.env` → MySQL** | ❌ مُعد لـ PostgreSQL | يحتاج تحويل إلى MySQL |
| **Flutter `main.dart`** | ❌ default counter app | يحتاج إعادة كتابة كاملة |
| **Flutter شاشة الإعدادات** | ❌ غير موجودة | شاشة تحديد API IP:Port |
| **Flutter network layer** | ❌ فارغ | `core/network/` فارغ |
| **Flutter storage layer** | ❌ فارغ | `core/storage/` فارغ |
| **Flutter providers** | ❌ فارغ | `providers/` فارغ |
| **Flutter constants** | ❌ فارغ | `core/constants/` فارغ |
| **Seeders** | ❌ فارغ | `database/seeders/` |

---

## 🎯 الخطة — مرحلتين

### المرحلة 1: Laravel — MySQL + Migrations
### المرحلة 2: Flutter — شاشة إعدادات API + تأسيس Network Layer

---

## 📋 المرحلة 1: Laravel Backend

### الخطوة 1.1 — تحويل `.env` إلى MySQL

**الملف:** `dealak-backend/.env`

```env
# ── قبل (PostgreSQL) ──
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=dealak
DB_USERNAME=dealak
DB_PASSWORD=secret

# ── بعد (MySQL) ──
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=dealak
DB_USERNAME=root
DB_PASSWORD=

# تبسيط: Session و Cache و Queue على file بدل Redis (لحد لاحقاً)
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
CACHE_STORE=file
```

---

### الخطوة 1.2 — إنشاء قاعدة البيانات

```sql
CREATE DATABASE IF NOT EXISTS dealak
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

---

### الخطوة 1.3 — إنشاء الـ Migrations (20 ملف)

كل migration مبني على الـ Models الموجودة فعلاً + الـ D1 SQL Schema كمرجع.

#### Migration 01: `create_users_table`

```php
Schema::create('users', function (Blueprint $table) {
    $table->id();                                    // BIGINT UNSIGNED AI
    $table->string('email')->unique();
    $table->string('phone')->unique()->nullable();
    $table->string('password');
    $table->string('first_name');
    $table->string('last_name');
    $table->enum('role', ['ADMIN','AGENT','BUYER','SELLER','TENANT','LANDLORD'])
          ->default('BUYER');
    $table->string('avatar_url')->nullable();
    $table->text('bio')->nullable();
    $table->string('national_id')->unique()->nullable();
    $table->boolean('is_verified')->default(false);
    $table->boolean('is_active')->default(true);
    $table->timestamp('email_verified_at')->nullable();
    $table->timestamp('last_login_at')->nullable();
    $table->rememberToken();
    $table->softDeletes();
    $table->timestamps();

    $table->index('role');
    $table->index('is_active');
    $table->index(['role', 'is_active']);
});
```

#### Migration 02: `create_user_devices_table`

```php
Schema::create('user_devices', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('device_token');
    $table->enum('platform', ['ANDROID', 'IOS', 'WEB']);
    $table->boolean('is_active')->default(true);
    $table->timestamps();

    $table->index('device_token');
});
```

#### Migration 03: `create_refresh_tokens_table`

```php
Schema::create('refresh_tokens', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('token_hash')->unique();
    $table->timestamp('expires_at');
    $table->timestamp('revoked_at')->nullable();
    $table->timestamps();

    $table->index('expires_at');
});
```

#### Migration 04: `create_personal_access_tokens_table`

```php
// Sanctum's default migration
Schema::create('personal_access_tokens', function (Blueprint $table) {
    $table->id();
    $table->morphs('tokenable');
    $table->string('name');
    $table->string('token', 64)->unique();
    $table->text('abilities')->nullable();
    $table->timestamp('last_used_at')->nullable();
    $table->timestamp('expires_at')->nullable();
    $table->timestamps();
});
```

#### Migration 05: `create_properties_table`

```php
Schema::create('properties', function (Blueprint $table) {
    $table->id();
    $table->foreignId('owner_id')->constrained('users');
    $table->foreignId('agent_id')->nullable()->constrained('users');
    $table->string('title');
    $table->string('slug')->unique();
    $table->text('description')->nullable();
    $table->enum('property_type', [
        'APARTMENT','HOUSE','VILLA','LAND',
        'COMMERCIAL','OFFICE','WAREHOUSE','FARM'
    ]);
    $table->enum('status', [
        'AVAILABLE','SOLD','RENTED','PENDING','RESERVED','DRAFT'
    ])->default('AVAILABLE');
    $table->enum('listing_type', [
        'SALE','RENT_MONTHLY','RENT_YEARLY','RENT_DAILY'
    ]);
    $table->decimal('price', 15, 2);
    $table->string('currency', 3)->default('SYP');
    $table->decimal('area_sqm', 10, 2)->nullable();
    $table->unsignedTinyInteger('bedrooms')->nullable();
    $table->unsignedTinyInteger('bathrooms')->nullable();
    $table->unsignedTinyInteger('floors')->nullable();
    $table->unsignedSmallInteger('year_built')->nullable();
    $table->string('address')->nullable();
    $table->string('city');
    $table->string('district')->nullable();
    $table->decimal('latitude', 10, 7)->nullable();
    $table->decimal('longitude', 10, 7)->nullable();
    $table->boolean('is_featured')->default(false);
    $table->boolean('is_negotiable')->default(true);
    $table->unsignedInteger('view_count')->default(0);
    $table->softDeletes();
    $table->timestamps();

    $table->index('property_type');
    $table->index('status');
    $table->index('listing_type');
    $table->index('price');
    $table->index('city');
    $table->index('is_featured');
    $table->index(['status', 'listing_type']);
    $table->index(['city', 'district']);
});
```

#### Migration 06: `create_property_images_table`

```php
Schema::create('property_images', function (Blueprint $table) {
    $table->id();
    $table->foreignId('property_id')->constrained()->cascadeOnDelete();
    $table->string('image_url');
    $table->string('thumbnail_url')->nullable();
    $table->string('caption')->nullable();
    $table->boolean('is_primary')->default(false);
    $table->unsignedInteger('sort_order')->default(0);
    $table->timestamps();

    $table->index('is_primary');
});
```

#### Migration 07: `create_property_features_table`

```php
Schema::create('property_features', function (Blueprint $table) {
    $table->id();
    $table->foreignId('property_id')->constrained()->cascadeOnDelete();
    $table->string('feature_key');
    $table->string('feature_value');

    $table->unique(['property_id', 'feature_key']);
    $table->index('feature_key');
});
```

#### Migration 08: `create_property_views_table`

```php
Schema::create('property_views', function (Blueprint $table) {
    $table->id();
    $table->foreignId('property_id')->constrained()->cascadeOnDelete();
    $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
    $table->string('ip_address', 45)->nullable();
    $table->text('user_agent')->nullable();
    $table->string('referrer')->nullable();
    $table->timestamp('viewed_at')->useCurrent();

    $table->index('viewed_at');
});
```

#### Migration 09: `create_favorites_table`

```php
Schema::create('favorites', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->foreignId('property_id')->constrained()->cascadeOnDelete();
    $table->timestamps();

    $table->unique(['user_id', 'property_id']);
});
```

#### Migration 10: `create_saved_searches_table`

```php
Schema::create('saved_searches', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('name');
    $table->json('filters');
    $table->boolean('notify_on_match')->default(true);
    $table->timestamp('last_notified_at')->nullable();
    $table->timestamps();
});
```

#### Migration 11: `create_conversations_table`

```php
Schema::create('conversations', function (Blueprint $table) {
    $table->id();
    $table->foreignId('participant_one_id')->constrained('users');
    $table->foreignId('participant_two_id')->constrained('users');
    $table->foreignId('property_id')->nullable()->constrained()->nullOnDelete();
    $table->timestamp('last_message_at')->nullable();
    $table->timestamps();

    $table->unique(['participant_one_id','participant_two_id','property_id']);
    $table->index('last_message_at');
});
```

#### Migration 12: `create_messages_table`

```php
Schema::create('messages', function (Blueprint $table) {
    $table->id();
    $table->foreignId('conversation_id')->constrained()->cascadeOnDelete();
    $table->foreignId('sender_id')->constrained('users');
    $table->foreignId('receiver_id')->constrained('users');
    $table->foreignId('property_id')->nullable()->constrained()->nullOnDelete();
    $table->string('subject')->nullable();
    $table->text('content');
    $table->enum('message_type', ['TEXT','IMAGE','FILE','LOCATION'])->default('TEXT');
    $table->json('attachments')->nullable();
    $table->boolean('is_read')->default(false);
    $table->timestamp('read_at')->nullable();
    $table->foreignId('parent_message_id')->nullable()->constrained('messages')->nullOnDelete();
    $table->timestamps();

    $table->index('is_read');
});
```

#### Migration 13: `create_property_requests_table`

```php
Schema::create('property_requests', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained();
    $table->enum('request_type', ['BUY','RENT','INVEST']);
    $table->enum('property_type', [
        'APARTMENT','HOUSE','VILLA','LAND',
        'COMMERCIAL','OFFICE','WAREHOUSE','FARM'
    ])->nullable();
    $table->decimal('min_price', 15, 2)->nullable();
    $table->decimal('max_price', 15, 2)->nullable();
    $table->string('currency', 3)->default('SYP');
    $table->decimal('min_area_sqm', 10, 2)->nullable();
    $table->decimal('max_area_sqm', 10, 2)->nullable();
    $table->unsignedTinyInteger('bedrooms')->nullable();
    $table->unsignedTinyInteger('bathrooms')->nullable();
    $table->string('preferred_city')->nullable();
    $table->string('preferred_district')->nullable();
    $table->text('description')->nullable();
    $table->enum('urgency', ['LOW','NORMAL','HIGH','URGENT'])->default('NORMAL');
    $table->enum('status', ['OPEN','MATCHED','CLOSED','CANCELLED'])->default('OPEN');
    $table->timestamps();

    $table->index('request_type');
    $table->index('status');
});
```

#### Migration 14: `create_deals_table`

```php
Schema::create('deals', function (Blueprint $table) {
    $table->id();
    $table->foreignId('property_id')->constrained();
    $table->foreignId('buyer_id')->constrained('users');
    $table->foreignId('seller_id')->constrained('users');
    $table->foreignId('agent_id')->nullable()->constrained('users');
    $table->foreignId('request_id')->nullable()->constrained('property_requests')->nullOnDelete();
    $table->enum('deal_type', ['SALE','RENT']);
    $table->decimal('agreed_price', 15, 2);
    $table->string('currency', 3)->default('SYP');
    $table->decimal('commission_rate', 5, 2)->nullable();
    $table->decimal('commission_amount', 15, 2)->nullable();
    $table->decimal('deposit_amount', 15, 2)->nullable();
    $table->boolean('deposit_paid')->default(false);
    $table->string('rent_period')->nullable();
    $table->timestamp('signed_at')->nullable();
    $table->enum('status', ['PENDING','IN_PROGRESS','COMPLETED','CANCELLED'])->default('PENDING');
    $table->text('notes')->nullable();
    $table->timestamps();

    $table->index('status');
});
```

#### Migration 15: `create_payments_table`

```php
Schema::create('payments', function (Blueprint $table) {
    $table->id();
    $table->foreignId('deal_id')->constrained();
    $table->foreignId('payer_id')->constrained('users');
    $table->foreignId('payee_id')->constrained('users');
    $table->enum('payment_type', ['DEPOSIT','INSTALLMENT','FULL','COMMISSION','RENT']);
    $table->decimal('amount', 15, 2);
    $table->string('currency', 3)->default('SYP');
    $table->enum('payment_method', ['CASH','BANK_TRANSFER','CHECK','ELECTRONIC']);
    $table->string('transaction_reference')->nullable();
    $table->unsignedInteger('installment_number')->nullable();
    $table->unsignedInteger('total_installments')->nullable();
    $table->enum('status', ['PENDING','COMPLETED','FAILED','REFUNDED'])->default('PENDING');
    $table->timestamp('paid_at')->nullable();
    $table->text('notes')->nullable();
    $table->timestamps();

    $table->index('status');
});
```

#### Migration 16: `create_discounts_table`

```php
Schema::create('discounts', function (Blueprint $table) {
    $table->id();
    $table->foreignId('property_id')->nullable()->constrained()->nullOnDelete();
    $table->string('code')->unique();
    $table->enum('discount_type', ['PERCENTAGE','FIXED']);
    $table->decimal('discount_value', 15, 2);
    $table->string('currency', 3)->default('SYP');
    $table->decimal('min_property_value', 15, 2)->nullable();
    $table->decimal('max_discount_amount', 15, 2)->nullable();
    $table->unsignedInteger('usage_limit')->nullable();
    $table->unsignedInteger('usage_count')->default(0);
    $table->timestamp('valid_from');
    $table->timestamp('valid_until');
    $table->boolean('is_active')->default(true);
    $table->foreignId('created_by')->constrained('users');
    $table->timestamps();

    $table->index('is_active');
    $table->index(['valid_from', 'valid_until']);
});
```

#### Migration 17: `create_reviews_table`

```php
Schema::create('reviews', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained();
    $table->foreignId('property_id')->constrained();
    $table->unsignedTinyInteger('rating');    // 1-5
    $table->text('comment')->nullable();
    $table->text('response')->nullable();     // رد المالك
    $table->timestamps();

    $table->unique(['user_id', 'property_id']);
    $table->index('rating');
});
```

#### Migration 18: `create_notifications_table`

```php
Schema::create('notifications', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('notification_type');      // MESSAGE, DEAL, PROPERTY, SYSTEM
    $table->string('title');
    $table->text('content')->nullable();
    $table->string('related_entity_type')->nullable();   // property, deal, message
    $table->unsignedBigInteger('related_entity_id')->nullable();
    $table->boolean('is_read')->default(false);
    $table->timestamp('read_at')->nullable();
    $table->boolean('is_push_sent')->default(false);
    $table->timestamps();

    $table->index('notification_type');
    $table->index('is_read');
});
```

#### Migration 19: `create_audit_logs_table`

```php
Schema::create('audit_logs', function (Blueprint $table) {
    $table->id();
    $table->string('table_name');
    $table->string('action');                // CREATE, UPDATE, DELETE
    $table->unsignedBigInteger('record_id')->nullable();
    $table->json('old_data')->nullable();
    $table->json('new_data')->nullable();
    $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
    $table->string('ip_address', 45)->nullable();
    $table->timestamps();

    $table->index(['table_name', 'action']);
    $table->index('record_id');
});
```

#### Migration 20: `create_system_settings_table`

```php
Schema::create('system_settings', function (Blueprint $table) {
    $table->id();
    $table->string('key')->unique();
    $table->text('value');
    $table->enum('value_type', ['STRING','INTEGER','BOOLEAN','JSON'])->default('STRING');
    $table->timestamps();
});
```

---

### الخطوة 1.4 — Seeder أساسي

```php
// DatabaseSeeder.php
public function run(): void
{
    // Admin user
    User::create([
        'first_name' => 'Admin',
        'last_name'  => 'Dealak',
        'email'      => 'admin@dealak.com',
        'password'   => Hash::make('admin123'),
        'role'       => 'ADMIN',
        'is_verified' => true,
        'is_active'   => true,
    ]);

    // System Settings
    SystemSetting::insert([
        ['key' => 'site_name', 'value' => 'DEALAK', 'value_type' => 'STRING'],
        ['key' => 'currency',  'value' => 'SYP',    'value_type' => 'STRING'],
    ]);
}
```

---

### الخطوة 1.5 — أوامر التشغيل

```bash
# 1. إنشاء قاعدة البيانات (MySQL CLI أو phpMyAdmin)
mysql -u root -e "CREATE DATABASE dealak CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 2. تشغيل migrations
cd dealak-backend
php artisan migrate

# 3. تشغيل seeder
php artisan db:seed

# 4. تشغيل السيرفر
php artisan serve --host=0.0.0.0 --port=8000
```

> ⚠️ **ملاحظة:** `--host=0.0.0.0` ضروري لكي يكون API متاح من الموبايل عبر الشبكة المحلية

---

## 📋 المرحلة 2: Flutter — شاشة إعدادات API

### المنطق

```
التطبيق يفتح
    ↓
هل يوجد API URL محفوظ في SharedPreferences؟
    ├── لا → عرض شاشة الإعدادات (تحديد IP + Port)
    │          ↓
    │        اختبار الاتصال (GET /api/v1/health)
    │          ↓
    │        حفظ + الانتقال → Home/Login
    │
    └── نعم → محاولة اتصال بالـ API المحفوظ
               ├── نجح → Home/Login
               └── فشل → عرض شاشة الإعدادات مع رسالة خطأ
```

---

### الخطوة 2.1 — ملفات Flutter المطلوبة

```
lib/
├── main.dart                              # 🔄 إعادة كتابة كاملة
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart             # 🆕 ألوان + مفاتيح تخزين
│   │
│   ├── network/
│   │   └── dio_client.dart                # 🆕 Dio instance ديناميكي
│   │
│   └── storage/
│       └── app_preferences.dart           # 🆕 SharedPreferences helper
│
├── features/
│   └── settings/
│       └── screens/
│           └── api_settings_screen.dart   # 🆕 شاشة إعدادات API
│
└── shared/
    └── widgets/                           # (لاحقاً)
```

---

### الخطوة 2.2 — `core/constants/app_constants.dart`

```dart
class AppConstants {
  // SharedPreferences Keys
  static const String prefApiHost = 'api_host';          // e.g. "192.168.1.5"
  static const String prefApiPort = 'api_port';          // e.g. "8000"
  static const String prefApiConfigured = 'api_configured'; // true/false
  static const String prefAuthToken = 'auth_token';

  // Defaults
  static const String defaultHost = '192.168.1.1';
  static const String defaultPort = '8000';
  static const String apiPrefix = '/api/v1';
}
```

---

### الخطوة 2.3 — `core/storage/app_preferences.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AppPreferences {
  final SharedPreferences _prefs;
  AppPreferences(this._prefs);

  // API Config
  bool get isApiConfigured => _prefs.getBool(AppConstants.prefApiConfigured) ?? false;

  String get apiHost => _prefs.getString(AppConstants.prefApiHost) ?? AppConstants.defaultHost;
  String get apiPort => _prefs.getString(AppConstants.prefApiPort) ?? AppConstants.defaultPort;

  String get baseUrl => 'http://$apiHost:$apiPort${AppConstants.apiPrefix}';

  Future<void> saveApiConfig(String host, String port) async {
    await _prefs.setString(AppConstants.prefApiHost, host);
    await _prefs.setString(AppConstants.prefApiPort, port);
    await _prefs.setBool(AppConstants.prefApiConfigured, true);
  }

  Future<void> clearApiConfig() async {
    await _prefs.remove(AppConstants.prefApiHost);
    await _prefs.remove(AppConstants.prefApiPort);
    await _prefs.setBool(AppConstants.prefApiConfigured, false);
  }

  // Auth Token
  String? get authToken => _prefs.getString(AppConstants.prefAuthToken);
  Future<void> saveToken(String token) => _prefs.setString(AppConstants.prefAuthToken, token);
  Future<void> clearToken() => _prefs.remove(AppConstants.prefAuthToken);
}
```

---

### الخطوة 2.4 — `core/network/dio_client.dart`

```dart
import 'package:dio/dio.dart';
import '../storage/app_preferences.dart';

class DioClient {
  late Dio dio;
  final AppPreferences _prefs;

  DioClient(this._prefs) {
    dio = Dio(BaseOptions(
      baseUrl: _prefs.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _prefs.authToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  /// تحديث baseUrl بعد تغيير الإعدادات
  void updateBaseUrl() {
    dio.options.baseUrl = _prefs.baseUrl;
  }

  /// اختبار الاتصال بالسيرفر
  Future<bool> testConnection(String host, String port) async {
    try {
      final testDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final url = 'http://$host:$port/api/v1/properties?limit=1';
      final response = await testDio.get(url);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
```

---

### الخطوة 2.5 — `features/settings/screens/api_settings_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/app_preferences.dart';

class ApiSettingsScreen extends StatefulWidget {
  final AppPreferences prefs;
  final VoidCallback onConfigured;

  const ApiSettingsScreen({
    super.key,
    required this.prefs,
    required this.onConfigured,
  });

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  bool _isTesting = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: widget.prefs.apiHost);
    _portController = TextEditingController(text: widget.prefs.apiPort);
  }

  Future<void> _testAndSave() async {
    setState(() { _isTesting = true; _errorMessage = null; _success = false; });

    final host = _hostController.text.trim();
    final port = _portController.text.trim();

    if (host.isEmpty || port.isEmpty) {
      setState(() { _errorMessage = 'يرجى تعبئة جميع الحقول'; _isTesting = false; });
      return;
    }

    final client = DioClient(widget.prefs);
    final ok = await client.testConnection(host, port);

    if (ok) {
      await widget.prefs.saveApiConfig(host, port);
      setState(() { _success = true; _isTesting = false; });
      await Future.delayed(const Duration(milliseconds: 800));
      widget.onConfigured();
    } else {
      setState(() {
        _errorMessage = 'فشل الاتصال بالسيرفر\nتأكد من أن السيرفر يعمل على $host:$port';
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Logo / Icon
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.settings_ethernet,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),

                // Title
                const Text('إعدادات الاتصال',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('حدد عنوان ومنفذ السيرفر',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 32),

                // Host field
                TextField(
                  controller: _hostController,
                  keyboardType: TextInputType.url,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'عنوان السيرفر (IP / Domain)',
                    hintText: '192.168.1.5',
                    prefixIcon: const Icon(Icons.dns),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Port field
                TextField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'رقم المنفذ (Port)',
                    hintText: '8000',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),

                // Preview URL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'http://${_hostController.text}:${_portController.text}/api/v1',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Error message
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(_errorMessage!,
                      style: TextStyle(color: Colors.red[700], fontSize: 13)),
                  ),

                // Success message
                if (_success)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('تم الاتصال بنجاح ✓',
                          style: TextStyle(color: Colors.green, fontSize: 14)),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Connect button
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isTesting
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('اختبار الاتصال والحفظ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
```

---

### الخطوة 2.6 — `main.dart` (إعادة كتابة)

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/app_preferences.dart';
import 'features/settings/screens/api_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = AppPreferences(await SharedPreferences.getInstance());
  runApp(DealakApp(prefs: prefs));
}

class DealakApp extends StatefulWidget {
  final AppPreferences prefs;
  const DealakApp({super.key, required this.prefs});

  @override
  State<DealakApp> createState() => _DealakAppState();
}

class _DealakAppState extends State<DealakApp> {
  late bool _isConfigured;

  @override
  void initState() {
    super.initState();
    _isConfigured = widget.prefs.isApiConfigured;
  }

  void _onApiConfigured() {
    setState(() => _isConfigured = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEALAK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0284C7),
        fontFamily: 'Tajawal',
        useMaterial3: true,
      ),
      home: _isConfigured
          ? HomeScreen(prefs: widget.prefs)    // TODO: بناؤها لاحقاً
          : ApiSettingsScreen(
              prefs: widget.prefs,
              onConfigured: _onApiConfigured,
            ),
    );
  }
}

/// شاشة Home مؤقتة — تعرض أن الاتصال ناجح
class HomeScreen extends StatelessWidget {
  final AppPreferences prefs;
  const HomeScreen({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DEALAK'),
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'إعدادات الاتصال',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ApiSettingsScreen(
                    prefs: prefs,
                    onConfigured: () => Navigator.of(context).pop(),
                  ),
                ));
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text('متصل بالسيرفر',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(prefs.baseUrl,
                  style: TextStyle(color: Colors.grey[600], fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### الخطوة 2.7 — إضافة Health endpoint في Laravel

**الملف:** `routes/api.php` — إضافة في بداية `v1` group:

```php
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'app' => 'DEALAK',
        'version' => '1.0.0',
        'timestamp' => now()->toISOString(),
    ]);
});
```

---

## 📋 ملخص الخطوات بالترتيب

### Laravel (Backend)

| # | الأمر/الإجراء | التفاصيل |
|---|--------------|----------|
| 1 | تعديل `.env` | تحويل من PostgreSQL إلى MySQL + تبسيط drivers |
| 2 | إنشاء DB | `CREATE DATABASE dealak` عبر MySQL |
| 3 | إنشاء 20 migration | كل الجداول المطابقة للـ Models الموجودة |
| 4 | `php artisan migrate` | بناء الجداول |
| 5 | إنشاء Seeder | Admin user + System Settings |
| 6 | `php artisan db:seed` | إدخال البيانات الأولية |
| 7 | إضافة `/health` endpoint | للتحقق من الاتصال |
| 8 | `php artisan serve --host=0.0.0.0` | تشغيل على الشبكة المحلية |

### Flutter (Mobile)

| # | الملف | الإجراء |
|---|-------|--------|
| 1 | `core/constants/app_constants.dart` | 🆕 إنشاء |
| 2 | `core/storage/app_preferences.dart` | 🆕 إنشاء |
| 3 | `core/network/dio_client.dart` | 🆕 إنشاء |
| 4 | `features/settings/screens/api_settings_screen.dart` | 🆕 إنشاء |
| 5 | `main.dart` | 🔄 إعادة كتابة كاملة |

---

## 🔄 سير العمل بعد التنفيذ

```
[المستخدم يفتح التطبيق لأول مرة]
         │
         ▼
┌─────────────────────────┐
│   شاشة إعدادات API      │
│   ┌─────────────────┐   │
│   │ IP: 192.168.1.5 │   │
│   │ Port: 8000      │   │
│   └─────────────────┘   │
│   [اختبار الاتصال]       │
└─────────┬───────────────┘
          │ GET http://192.168.1.5:8000/api/v1/properties?limit=1
          ▼
   ┌──── نجح? ────┐
   │              │
   ▼ نعم          ▼ لا
[حفظ + Home]   [رسالة خطأ]
```

---

## ⚠️ ملاحظات مهمة

> [!IMPORTANT]
> - **MySQL موجود؟** تأكد أن MySQL يعمل على `127.0.0.1:3306` — يمكنك استخدام XAMPP أو WAMP أو MySQL مستقل
> - **`--host=0.0.0.0`** ضروري جداً لكي يكون API متاح من أجهزة أخرى على الشبكة
> - **IP الجهاز:** عندما تشغل Flutter على الموبايل، استخدم IP جهاز الكمبيوتر وليس `127.0.0.1` (لأن 127.0.0.1 يشير لجهاز الموبايل نفسه)
> - **Windows Firewall:** قد تحتاج السماح لـ port 8000 في جدار الحماية

> [!TIP]
> لمعرفة IP جهازك:
> ```bash
> ipconfig | grep IPv4
> ```
> عادةً يكون شيء مثل `192.168.1.X`
