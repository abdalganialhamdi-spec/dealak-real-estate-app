<div align="center">

# 🏠 DEALAK — منصة عقارية متكاملة

### بيع • إيجار • إدارة العقارات في سوريا

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-20_LTS-339933?logo=nodedotjs)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-4169E1?logo=postgresql)](https://www.postgresql.org/)
[![Next.js](https://img.shields.io/badge/Next.js-14+-000000?logo=nextdotjs)](https://nextjs.org/)
[![React Native](https://img.shields.io/badge/React_Native-0.74-61DAFB?logo=react)](https://reactnative.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?logo=typescript)](https://www.typescriptlang.org/)

<br />

**DEALAK** هي منصة رقمية متكاملة تُسهّل عملية بيع وإيجار العقارات في سوريا من خلال تطبيق هاتف ذكي وموقع إلكتروني متصلين بنفس قاعدة البيانات، مع لوحة تحكم إدارية شاملة.

[🚀 الخطة التنفيذية](IMPLEMENTATION_PLAN.md) · [📊 تحليل المشروع](docs/analysis.md) · [🗄️ مخطط قاعدة البيانات](database/schema_final.dbml)

</div>

---

## 📋 الفهرس

- [نظرة عامة](#-نظرة-عامة)
- [الميزات الرئيسية](#-الميزات-الرئيسية)
- [المستخدمون والأدوار](#-المستخدمون-والأدوار)
- [التقنيات المستخدمة](#-التقنيات-المستخدمة)
- [البنية المعمارية](#-البنية-المعمارية)
- [قاعدة البيانات](#-قاعدة-البيانات)
- [واجهة برمجة التطبيقات](#-واجهة-برمجة-التطبيقات-api)
- [نظام الأمان](#-نظام-الأمان)
- [المنصات المدعومة](#-المنصات-المدعومة)
- [هيكل المشروع](#-هيكل-المشروع)
- [البدء السريع](#-البدء-السريع)
- [المتطلبات](#-المتطلبات)
- [لقطات الشاشة](#-لقطات-الشاشة)
- [خارطة الطريق](#-خارطة-الطريق)
- [فريق العمل](#-فريق-العمل)
- [المساهمة](#-المساهمة)
- [الترخيص](#-الترخيص)

---

## 🌟 نظرة عامة

سوق العقارات في سوريا يعاني من **غياب منصة رقمية موحدة** تربط البائعين والمشترين والوسطاء. **DEALAK** تحل هذه المشكلة من خلال:

- 🏘️ **منصة مركزية** لنشر والبحث عن العقارات بجميع أنواعها
- 📍 **بحث جغرافي ذكي** بتقنية PostGIS للعثور على عقارات قريبة
- 💬 **تواصل مباشر** بين الأطراف عبر محادثات فورية
- 🤝 **إتمام الصفقات** مع تتبع المدفوعات والعقود
- 📊 **تحليلات وإحصائيات** لفهم السوق واتخاذ قرارات ذكية

---

## ✨ الميزات الرئيسية

### 🔍 البحث والاستكشاف

| الميزة | الوصف |
|--------|-------|
| **بحث متقدم** | فلاتر متعددة: الموقع، المساحة، السعر، النوع، عدد الغرف، الأثاث |
| **بحث جغرافي** | عرض العقارات على خريطة تفاعلية بتقنية PostGIS |
| **عقارات قريبة** | اكتشاف العقارات حسب نطاق جغرافي محدد بالكيلومتر |
| **بحث محفوظ** | حفظ معايير البحث والحصول على إشعارات عند ظهور نتائج جديدة |
| **Full-Text Search** | بحث نصي ذكي يدعم اللغة العربية والإنجليزية |

### 🏘️ إدارة العقارات

| الميزة | الوصف |
|--------|-------|
| **نشر العقارات** | إضافة عقارات مع صور متعددة وتفاصيل شاملة |
| **أنواع متنوعة** | شقق، منازل، فلل، أراضي، تجاري، مكاتب، مستودعات، شاليهات، مزارع |
| **نماذج الإعلان** | بيع، إيجار شهري/سنوي، إيجار يومي |
| **معرض صور** | رفع صور متعددة مع صور مصغرة وترتيب مخصص |
| **ميزات العقار** | إضافة ميزات مخصصة: مواقف، مسبح، مصعد، حديقة، أمن |
| **روابط SEO** | عناوين URL ودّية (slugs) لتحسين محركات البحث |
| **حالات متعددة** | متاح، مباع، مؤجر، قيد المراجعة، خارج السوق |
| **مراجعة المحتوى** | العقارات تمر بمراجعة المدير قبل النشر |

### 💬 التواصل والمحادثات

| الميزة | الوصف |
|--------|-------|
| **محادثات فورية** | WebSocket-based real-time messaging |
| **أنواع الرسائل** | نص، صور، ملفات، موقع جغرافي |
| **ردود متسلسلة** | نظام محادثات مبني على Conversations |
| **إشعارات مباشرة** | Push Notifications فورية عبر Firebase |
| **أرشفة المحادثات** | أرشفة المحادثات دون حذفها |

### 🤝 الصفقات والمدفوعات

| الميزة | الوصف |
|--------|-------|
| **سير عمل الصفقة** | تفاوض → إيداع → توقيع عقد → استكمال الدفع → إتمام |
| **طرق دفع متعددة** | نقدي، تحويل بنكي، شيكات، محافظ إلكترونية |
| **نظام التقسيط** | دعم الأقساط مع تتبع رقم القسط والمبالغ |
| **نظام العمولات** | حساب عمولة الوسيط العقاري تلقائياً |
| **عقود رقمية** | رفع العقود الموقعة وربطها بالصفقة |
| **إيصالات** | توليد إيصالات لكل دفعة |
| **نظام الإيجار** | دعم فترات الإيجار: شهري، ربعي، نصف سنوي، سنوي |

### ❤️ المفضلة والتقييمات

| الميزة | الوصف |
|--------|-------|
| **قائمة المفضلة** | حفظ العقارات المفضلة للعودة لاحقاً |
| **نظام التقييم** | تقييم بـ 5 نجوم مع تعليقات تفصيلية |
| **ردود المالك** | إمكانية رد المالك أو الوسيط على التقييمات |
| **تقييم المستخدمين** | تقييم البائعين والوسطاء من المشترين |

### 🔔 الإشعارات

| الميزة | الوصف |
|--------|-------|
| **Push Notifications** | إشعارات فورية عبر Firebase Cloud Messaging |
| **أنواع متعددة** | رسائل، تحديث صفقات، مدفوعات، عقار جديد، تخفيض سعر |
| **إشعارات ذكية** | تنبيهات تلقائية عند تطابق بحث محفوظ مع عقار جديد |
| **إشعارات داخلية** | نظام إشعارات داخل التطبيق مع عداد غير المقروءة |

### 🏷️ الخصومات والعروض

| الميزة | الوصف |
|--------|-------|
| **أكواد خصم** | إنشاء كوبونات خصم بنسبة مئوية أو مبلغ ثابت |
| **صلاحية محددة** | تحديد فترة صلاحية الخصم (من — إلى) |
| **حدود الاستخدام** | تحديد عدد مرات الاستخدام لكل كوبون |
| **خصم على عقار محدد** | ربط الخصم بعقار معين أو جعله عاماً |
| **تتبع الاستخدام** | مراقبة عدد مرات استخدام كل كوبون |

### 📊 التحليلات والإحصائيات

| الميزة | الوصف |
|--------|-------|
| **تتبع المشاهدات** | عدد مشاهدات كل عقار مع تفاصيل الزائر |
| **لوحة تحكم** | إحصائيات بصرية: عقارات، صفقات، إيرادات |
| **سجل التدقيق** | تتبع جميع العمليات على قاعدة البيانات |
| **إحصائيات السوق** | Materialized Views لمتوسطات الأسعار حسب المدينة والنوع |

### ⚙️ إدارة النظام (Admin)

| الميزة | الوصف |
|--------|-------|
| **إدارة المستخدمين** | تفعيل/تعطيل الحسابات، تحقق من الهوية |
| **مراجعة العقارات** | قبول أو رفض العقارات المنشورة |
| **إعدادات النظام** | Key-Value settings قابلة للتعديل |
| **إدارة الخصومات** | إنشاء وإدارة كوبونات الخصم |
| **تقارير شاملة** | صفقات مكتملة، إيرادات، مستخدمين نشطين |

---

## 👥 المستخدمون والأدوار

| الدور | الرمز | الصلاحيات |
|-------|-------|----------|
| **المشتري / المستأجر** | 🏠 `buyer` / `tenant` | البحث، المفضلة، إرسال طلبات، المحادثات، التقييم، الدفع |
| **البائع / المالك** | 🏢 `seller` / `landlord` | نشر العقارات، إدارة الصور والميزات، استلام الطلبات، قبول/رفض، إتمام الصفقات |
| **الوسيط العقاري** | 👔 `agent` | كل صلاحيات البائع + إدارة عقارات الغير، كسب العمولة، إدارة عملاء متعددين |
| **مدير النظام** | ⚙️ `admin` | كل الصلاحيات + إدارة المستخدمين، مراجعة المحتوى، الخصومات، الإعدادات، التقارير |

---

## 🛠️ التقنيات المستخدمة

### Backend
| التقنية | الاستخدام |
|---------|-----------|
| ![Node.js](https://img.shields.io/badge/-Node.js-339933?logo=nodedotjs&logoColor=fff) | Runtime Environment |
| ![Express](https://img.shields.io/badge/-Express.js-000?logo=express&logoColor=fff) | HTTP Framework |
| ![TypeScript](https://img.shields.io/badge/-TypeScript-3178C6?logo=typescript&logoColor=fff) | Type Safety |
| ![PostgreSQL](https://img.shields.io/badge/-PostgreSQL-4169E1?logo=postgresql&logoColor=fff) | Relational Database |
| ![PostGIS](https://img.shields.io/badge/-PostGIS-4EAA25?logo=postgresql&logoColor=fff) | Geospatial Queries |
| ![Prisma](https://img.shields.io/badge/-Prisma-2D3748?logo=prisma&logoColor=fff) | ORM & Migrations |
| ![Redis](https://img.shields.io/badge/-Redis-DC382D?logo=redis&logoColor=fff) | Caching & Pub/Sub |
| ![Socket.io](https://img.shields.io/badge/-Socket.io-010101?logo=socketdotio&logoColor=fff) | Real-time Communication |
| ![JWT](https://img.shields.io/badge/-JWT-000?logo=jsonwebtokens&logoColor=fff) | Authentication |
| ![Swagger](https://img.shields.io/badge/-Swagger-85EA2D?logo=swagger&logoColor=000) | API Documentation |

### Frontend Web
| التقنية | الاستخدام |
|---------|-----------|
| ![Next.js](https://img.shields.io/badge/-Next.js-000?logo=nextdotjs&logoColor=fff) | React Framework (SSR + SSG) |
| ![Tailwind CSS](https://img.shields.io/badge/-Tailwind_CSS-06B6D4?logo=tailwindcss&logoColor=fff) | Utility-first Styling |
| ![Zustand](https://img.shields.io/badge/-Zustand-553C7B) | State Management |
| ![React Query](https://img.shields.io/badge/-React_Query-FF4154?logo=reactquery&logoColor=fff) | Server State Management |

### Mobile
| التقنية | الاستخدام |
|---------|-----------|
| ![React Native](https://img.shields.io/badge/-React_Native-61DAFB?logo=react&logoColor=000) | Cross-platform Mobile |
| ![Expo](https://img.shields.io/badge/-Expo-000020?logo=expo&logoColor=fff) | Build & Development |
| ![Firebase](https://img.shields.io/badge/-Firebase-FFCA28?logo=firebase&logoColor=000) | Push Notifications |

### DevOps
| التقنية | الاستخدام |
|---------|-----------|
| ![Docker](https://img.shields.io/badge/-Docker-2496ED?logo=docker&logoColor=fff) | Containerization |
| ![GitHub Actions](https://img.shields.io/badge/-GitHub_Actions-2088FF?logo=githubactions&logoColor=fff) | CI/CD Pipeline |
| ![Vercel](https://img.shields.io/badge/-Vercel-000?logo=vercel&logoColor=fff) | Frontend Hosting |
| ![Cloudflare](https://img.shields.io/badge/-Cloudflare-F38020?logo=cloudflare&logoColor=fff) | CDN & R2 Storage |

---

## 🏗️ البنية المعمارية

```
┌─────────────────────────────────────────────────────┐
│                      CLIENTS                         │
│  📱 Mobile App    🌐 Web App    📊 Admin Dashboard   │
├─────────────────────────────────────────────────────┤
│              API Gateway (Express.js)                │
│        Rate Limiting · Auth · CORS · Logging         │
├─────────────────────────────────────────────────────┤
│                 MODULAR BACKEND                      │
│  🔐 Auth    🏘️ Properties   🤝 Deals   💬 Messages  │
│  💳 Payments  📋 Requests   ⭐ Reviews  🔔 Notifs   │
├─────────────────────────────────────────────────────┤
│                    DATA LAYER                        │
│  🐘 PostgreSQL+PostGIS  🔴 Redis  ☁️ R2  🔥 FCM    │
└─────────────────────────────────────────────────────┘
```

**النمط المعماري:** Modular Monolith → Microservices-Ready

كل Module يحتوي على: `Controller → Service → Repository → Schema (Validation) → DTO → Tests`

---

## 🗄️ قاعدة البيانات

### المخطط: [`database/schema_final.dbml`](database/schema_final.dbml)

| المقياس | القيمة |
|---------|--------|
| المحرك | PostgreSQL 16+ مع PostGIS |
| عدد الجداول | **19 جدول** |
| العملة الافتراضية | SYP (الليرة السورية) |
| Full-Text Search | ✅ GIN Index (عربي + إنجليزي) |
| Spatial Queries | ✅ PostGIS GiST Index |
| Soft Delete | ✅ `deleted_at` على الجداول الرئيسية |
| Audit Trail | ✅ جدول `audit_logs` |

### الجداول

| الجدول | الوصف |
|--------|-------|
| `users` | المستخدمون (6 أدوار) |
| `user_devices` | أجهزة Push Notifications |
| `refresh_tokens` | JWT Refresh Tokens |
| `properties` | العقارات (9 أنواع) |
| `property_features` | ميزات العقار (Many-to-Many) |
| `property_images` | صور العقار مع thumbnails |
| `favorites` | المفضلة |
| `saved_searches` | البحوث المحفوظة مع إشعارات |
| `requests` | الطلبات العقارية |
| `deals` | الصفقات مع دعم الإيجار |
| `payments` | المدفوعات والأقساط |
| `discounts` | الخصومات وكوبونات |
| `conversations` | المحادثات (Thread-based) |
| `messages` | الرسائل (نص، صورة، ملف) |
| `notifications` | الإشعارات |
| `reviews` | التقييمات (1-5 نجوم) |
| `property_views` | تتبع المشاهدات |
| `audit_logs` | سجل التدقيق |
| `system_settings` | إعدادات النظام (Key-Value) |

---

## 🔌 واجهة برمجة التطبيقات (API)

**Base URL:** `https://api.dealak.com/api/v1`

### نقاط النهاية الرئيسية

| المجموعة | Endpoints | الوصف |
|----------|-----------|-------|
| 🔐 **Auth** | 8 | تسجيل، دخول، خروج، نسيت كلمة المرور، Google OAuth |
| 👤 **Users** | 7 | الملف الشخصي، تحديث، إدارة (Admin) |
| 🏘️ **Properties** | 11 | CRUD، بحث، فلاتر، قريب، صور، ميزات |
| 📋 **Requests** | 5 | إنشاء، عرض، تحديث، تغيير حالة |
| 🤝 **Deals** | 5 | إنشاء، عرض، تحديث حالة، رفع عقد |
| 💳 **Payments** | 4 | تسجيل، عرض، تأكيد |
| 💬 **Messages** | 5 | محادثات، رسائل، تعليم كمقروء |
| ❤️ **Favorites** | 3 | إضافة، حذف، عرض |
| ⭐ **Reviews** | 2 | إضافة، عرض |
| 🔔 **Notifications** | 4 | عرض، تعليم كمقروء، عداد |

> 📖 التوثيق الكامل متاح عبر Swagger على `/api-docs`

---

## 🔐 نظام الأمان

| الطبقة | التقنية |
|--------|---------|
| **المصادقة** | JWT (Access 15min + Refresh 30d) مع Token Rotation |
| **التشفير** | bcrypt (salt=12) لكلمات المرور |
| **التفويض** | RBAC (Role-Based Access Control) بـ 6 أدوار |
| **HTTPS** | SSL/TLS إلزامي عبر Cloudflare |
| **CORS** | Origins محددة فقط |
| **Rate Limiting** | حد 100 req/min عام، 5 req/15min لـ login |
| **Input Validation** | Zod schemas لكل endpoint |
| **SQL Injection** | Prisma ORM (Parameterized Queries) |
| **XSS** | Helmet.js + CSP + HTML Sanitization |
| **CSRF** | SameSite Cookies |
| **File Upload** | فحص MIME Type + حجم ≤ 5MB |
| **Audit Trail** | تسجيل جميع العمليات الحساسة |

---

## 📱 المنصات المدعومة

| المنصة | التقنية | الحالة |
|--------|---------|--------|
| 🌐 **Web** | Next.js 14 (SSR) | 🚧 قيد التطوير |
| 📱 **iOS** | React Native + Expo | 🚧 قيد التطوير |
| 🤖 **Android** | React Native + Expo | 🚧 قيد التطوير |
| 📊 **Admin Dashboard** | Next.js (Web) | 🚧 قيد التطوير |

### اللغات المدعومة

| اللغة | الحالة |
|-------|--------|
| 🇸🇾 العربية (RTL) | ✅ مدعومة |
| 🇬🇧 الإنجليزية (LTR) | ✅ مدعومة |

---

## 📁 هيكل المشروع

```
dealak-real-estate-app/
├── backend/                # 🖥️ Backend API (Node.js + Express + TypeScript)
│   ├── src/
│   │   ├── config/         # ⚙️ إعدادات (DB, Redis, Env, CORS)
│   │   ├── modules/        # 📦 وحدات (Auth, Users, Properties, Deals, ...)
│   │   ├── middleware/      # 🛡️ Auth, RBAC, Validation, Error Handling
│   │   ├── shared/         # 🔧 Errors, Utils, Types
│   │   ├── jobs/           # ⏰ Background Jobs
│   │   ├── websocket/      # 🔌 Socket.io (Chat + Notifications)
│   │   └── app.ts          # 🚀 Entry Point
│   └── prisma/             # 🗄️ Schema + Migrations + Seeds
│
├── frontend/               # 🌐 Frontend Web (Next.js 14)
│   └── src/
│       ├── app/            # 📄 Pages (App Router)
│       ├── components/     # 🧩 Reusable Components
│       ├── hooks/          # 🪝 Custom Hooks
│       ├── lib/            # 📚 API Client, Utils
│       ├── store/          # 🏪 Zustand Stores
│       └── types/          # 📝 TypeScript Types
│
├── mobile/                 # 📱 Mobile App (React Native + Expo)
│   └── src/
│       ├── screens/        # 📱 Screens
│       ├── components/     # 🧩 Components
│       ├── navigation/     # 🧭 Stack + Tab Navigation
│       └── services/       # 🔌 API Services
│
├── database/               # 🗄️ DB Schemas & Reports
├── docs/                   # 📚 Documentation
├── scripts/                # 🔧 Utility Scripts
├── .github/workflows/      # 🐙 CI/CD Pipelines
├── docker-compose.yml      # 🐳 Development Environment
└── README.md               # 📖 أنت هنا!
```

---

## 🚀 البدء السريع

### المتطلبات المسبقة

- [Node.js 20 LTS](https://nodejs.org/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)

### التثبيت

```bash
# 1. استنساخ المستودع
git clone https://github.com/abdalganialhamdi-spec/dealak-real-estate-app.git
cd dealak-real-estate-app

# 2. تشغيل البنية التحتية (PostgreSQL + Redis)
docker-compose up -d

# 3. إعداد Backend
cd backend
cp .env.example .env
npm install
npx prisma migrate dev
npx prisma db seed
npm run dev

# 4. إعداد Frontend (في terminal آخر)
cd ../frontend
npm install
npm run dev

# 5. إعداد Mobile (في terminal آخر)
cd ../mobile
npm install
npx expo start
```

### متغيرات البيئة

```env
# Backend (.env)
DATABASE_URL=postgresql://user:pass@localhost:5432/dealak
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key
JWT_REFRESH_SECRET=your-refresh-secret
CLOUDFLARE_R2_ENDPOINT=https://xxx.r2.cloudflarestorage.com
CLOUDFLARE_R2_ACCESS_KEY=your-key
CLOUDFLARE_R2_SECRET_KEY=your-secret
GOOGLE_CLIENT_ID=your-google-client-id
FIREBASE_SERVICE_ACCOUNT=path/to/firebase-credentials.json
```

---

## 📊 المتطلبات

### المتطلبات الوظيفية

| المعرف | الوصف | الأولوية |
|--------|-------|----------|
| FR-01 | تسجيل مستخدمين بأدوار متعددة (بائع، مشتري، وسيط) | 🔴 عالية |
| FR-02 | تسجيل دخول/خروج آمن مع JWT | 🔴 عالية |
| FR-03 | نشر عقارات مع صور وتفاصيل وميزات | 🔴 عالية |
| FR-04 | بحث متقدم بفلاتر متعددة | 🔴 عالية |
| FR-05 | بحث جغرافي بتقنية PostGIS | 🔴 عالية |
| FR-06 | خريطة تفاعلية لعرض العقارات | 🟡 متوسطة |
| FR-07 | محادثات فورية بين البائع والمشتري | 🔴 عالية |
| FR-08 | إشعارات Push Notifications | 🟡 متوسطة |
| FR-09 | إدارة الطلبات (إنشاء، قبول، رفض) | 🔴 عالية |
| FR-10 | إتمام الصفقات مع تتبع المدفوعات | 🔴 عالية |
| FR-11 | نظام المفضلة والبحوث المحفوظة | 🟡 متوسطة |
| FR-12 | نظام التقييمات والمراجعات | 🟢 منخفضة |
| FR-13 | إدارة الخصومات وكوبونات | 🟢 منخفضة |
| FR-14 | لوحة تحكم إدارية شاملة | 🔴 عالية |
| FR-15 | سجل تدقيق لجميع العمليات | 🟡 متوسطة |

### المتطلبات غير الوظيفية

| المعرف | الوصف | الهدف |
|--------|-------|-------|
| NFR-01 | **الأداء:** زمن الاستجابة | < 500ms (P95) |
| NFR-02 | **التوفر:** نسبة التشغيل | 99.5% uptime |
| NFR-03 | **الأمان:** حماية البيانات | 0 حوادث أمنية |
| NFR-04 | **التوسع:** مستخدمون متزامنون | 500+ متزامن |
| NFR-05 | **التوافق:** الأجهزة | iOS, Android, Web (جميع المتصفحات) |
| NFR-06 | **Accessibility:** الوصولية | WCAG 2.1 AA |
| NFR-07 | **SEO:** تحسين محركات البحث | SSR + Meta Tags |
| NFR-08 | **الخصوصية:** حماية البيانات | لا مشاركة بدون موافقة |

---

## 🗺️ خارطة الطريق

### ✅ المرحلة 1 — التحضير (أبريل 2026)
- [x] تحليل المتطلبات
- [x] إنشاء المستودع والوثائق
- [x] تصميم قاعدة البيانات (19 جدول)
- [x] مراجعة وتدقيق المخطط
- [ ] إعداد بيئة التطوير

### 🚧 المرحلة 2 — التطوير (مايو - يونيو 2026)
- [ ] Backend API كامل مع 54+ endpoint
- [ ] Frontend Web متجاوب مع RTL
- [ ] Mobile App لـ iOS و Android
- [ ] WebSocket للمحادثات الفورية

### 🔮 المرحلة 3 — التحسينات (بعد 3 أشهر)
- [ ] AI Property Valuation
- [ ] Virtual Tours 360°
- [ ] إحصائيات السوق المتقدمة
- [ ] PWA (Progressive Web App)

### 🌍 المرحلة 4 — التوسع (بعد 12 شهر)
- [ ] دعم دول إضافية
- [ ] B2B Features
- [ ] Property Management
- [ ] Blockchain Verification

---

## 👨‍💻 فريق العمل

| الاسم | الدور |
|-------|-------|
| مريم البكور | عضو فريق |
| سدرة بظ | عضو فريق |
| بيان غبشة | عضو فريق |
| كرم الحمد | عضو فريق |
| فرح الحميدي | عضو فريق |
| أيمان النعسان | عضو فريق |
| صفاء زقزوق | عضو فريق |

**المشرف:** المهندسة فاطمة الشيخ صبح

---

## 🤝 المساهمة

المساهمات مرحب بها! لمساهمتك:

1. **Fork** المستودع
2. أنشئ **Branch** جديد (`git checkout -b feature/amazing-feature`)
3. **Commit** التغييرات (`git commit -m 'Add amazing feature'`)
4. **Push** إلى الـ Branch (`git push origin feature/amazing-feature`)
5. افتح **Pull Request**

### قواعد المساهمة

- اتبع [Conventional Commits](https://www.conventionalcommits.org/)
- اكتب **Unit Tests** لكل ميزة جديدة
- حافظ على **TypeScript Strict Mode**
- اتبع **ESLint + Prettier** المُعدّ

---

## 📄 الترخيص

هذا المشروع مرخص بموجب [MIT License](LICENSE).

---

## 📞 التواصل

- **Email:** support@dealak.com
- **GitHub:** [github.com/abdalganialhamdi-spec/dealak-real-estate-app](https://github.com/abdalganialhamdi-spec/dealak-real-estate-app)

---

<div align="center">

**الجهة:** وزارة التعليم العالي والبحث العلمي — جامعة حماة — المعهد التقاني للحاسوب  
**القسم:** قسم هندسة البرمجيات  
**المادة:** تحليل نظم المعلومات  
**الفصل الدراسي:** الأول لعام 2025/2026 م

---

صُنع بـ ❤️ في سوريا

</div>
