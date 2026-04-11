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
- [التقنيات المستخدمة](#-التقنيات-المستخدمة)
- [البنية المعمارية](#-البنية-المعمارية)
- [قاعدة البيانات](#-قاعدة-البيانات)
- [التثبيت والتشغيل](#-التثبيت-والتشغيل)
- [هيكل المشروع](#-هيكل-المشروع)
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
- **بحث متقدم** بفلاتر متعددة: الموقع، المساحة، السعر، النوع، عدد الغرف
- **بحث جغرافي** عرض العقارات على خريطة تفاعلية
- **عقارات قريبة** اكتشاف العقارات حسب نطاق جغرافي محدد
- **بحث محفوظ** حفظ معايير البحث والحصول على إشعارات

### 🏘️ إدارة العقارات
- **نشر العقارات** مع صور متعددة وتفاصيل شاملة
- **أنواع متنوعة** شقق، منازل، فلل، أراضي، تجاري
- **نماذج الإعلان** بيع، إيجار شهري/سنوي، إيجار يومي
- **معرض صور** رفع صور متعددة مع ترتيب مخصص
- **حالات متعددة** متاح، مباع، مؤجر، قيد المراجعة

### 💬 التواصل والمحادثات
- **محادثات فورية** WebSocket-based real-time messaging
- **أنواع الرسائل** نص، صور، ملفات، موقع جغرافي
- **ردود متسلسلة** نظام محادثات مبني على Conversations
- **إشعارات مباشرة** Push Notifications فورية

### 🤝 الصفقات والمدفوعات
- **سير عمل الصفقة** تفاوض → إيداع → توقيع عقد → استكمال الدفع → إتمام
- **طرق دفع متعددة** نقدي، تحويل بنكي، شيكات، محافظ إلكترونية
- **نظام التقسيط** دعم الأقساط مع تتبع رقم القسط
- **نظام العمولات** حساب عمولة الوسيط العقاري تلقائياً

### 🔔 الإشعارات
- **Push Notifications** إشعارات فورية عبر Firebase
- **أنواع متعددة** رسائل، تحديث صفقات، مدفوعات، عقار جديد
- **إشعارات ذكية** تنبيهات تلقائية عند تطابق بحث محفوظ

---

## 🛠️ التقنيات المستخدمة

### Backend
| التقنية | الاستخدام |
|---------|-----------|
| ![Node.js](https://img.shields.io/badge/-Node.js-339933?logo=nodedotjs&logoColor=fff) | Runtime Environment |
| ![Express](https://img.shields.io/badge/-Express.js-000?logo=express&logoColor=fff) | HTTP Framework |
| ![TypeScript](https://img.shields.io/badge/-TypeScript-3178C6?logo=typescript&logoColor=fff) | Type Safety |
| ![PostgreSQL](https://img.shields.io/badge/-PostgreSQL-4169E1?logo=postgresql&logoColor=fff) | Database |
| ![Prisma](https://img.shields.io/badge/-Prisma-2D3748?logo=prisma&logoColor=fff) | ORM |
| ![Socket.io](https://img.shields.io/badge/-Socket.io-010101?logo=socketdotio&logoColor=fff) | Real-time |

### Frontend Web
| التقنية | الاستخدام |
|---------|-----------|
| ![Next.js](https://img.shields.io/badge/-Next.js-000?logo=nextdotjs&logoColor=fff) | React Framework |
| ![Tailwind CSS](https://img.shields.io/badge/-Tailwind_CSS-06B6D4?logo=tailwindcss&logoColor=fff) | Styling |
| ![Zustand](https://img.shields.io/badge/-Zustand-553C7B) | State Management |
| ![React Query](https://img.shields.io/badge/-React_Query-FF4154?logo=reactquery&logoColor=fff) | Server State |

### Mobile
| التقنية | الاستخدام |
|---------|-----------|
| ![React Native](https://img.shields.io/badge/-React_Native-61DAFB?logo=react&logoColor=000) | Cross-platform |
| ![Expo](https://img.shields.io/badge/-Expo-000020?logo=expo&logoColor=fff) | Build & Dev |
| ![Expo Router](https://img.shields.io/badge/-Expo_Router-000?logo=expo&logoColor=fff) | Navigation |

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

### الجداول الرئيسية
- `users` - المستخدمون (6 أدوار)
- `properties` - العقارات (9 أنواع)
- `deals` - الصفقات
- `payments` - المدفوعات
- `messages` - الرسائل والمحادثات
- `notifications` - الإشعارات
- `reviews` - التقييمات
- `favorites` - المفضلة
- `discounts` - الخصومات

---

## 🚀 التثبيت والتشغيل

### المتطلبات المسبقة
- [Node.js 20 LTS](https://nodejs.org/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)

### 1. استنساخ المستودع
```bash
git clone https://github.com/abdalganialhamdi-spec/dealak-real-estate-app.git
cd dealak-real-estate-app
```

### 2. تشغيل البنية التحتية
```bash
docker-compose up -d
```

### 3. إعداد Backend
```bash
cd backend
cp .env.example .env
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run dev
```

### 4. إعداد Frontend Web
```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```

### 5. إعداد Mobile App
```bash
cd mobile
cp .env.example .env
npm install
npm start
```

---

## 📁 هيكل المشروع

```
dealak-real-estate-app/
├── backend/              # 🖥️ Backend API
│   ├── src/
│   │   ├── config/       # ⚙️ إعدادات
│   │   ├── modules/      # 📦 الوحدات
│   │   ├── middleware/   # 🛡️ Middleware
│   │   ├── shared/       # 🔧 Shared utilities
│   │   ├── jobs/         # ⏰ Background jobs
│   │   ├── websocket/    # 🔌 Socket.io
│   │   └── app.ts        # 🚀 Entry point
│   └── prisma/           # 🗄️ Database schema
│
├── frontend/             # 🌐 Frontend Web (Next.js)
│   └── src/
│       ├── app/          # 📄 Pages
│       ├── components/   # 🧩 Components
│       ├── hooks/        # 🪝 Custom hooks
│       └── lib/          # 📚 Utilities
│
├── mobile/               # 📱 Mobile App (React Native)
│   └── app/             # 📱 Screens
│
├── database/             # 🗄️ Database schemas
├── docs/                 # 📚 Documentation
└── docker-compose.yml    # 🐳 Docker setup
```

---

## 🤝 المساهمة

المساهمات مرحب بها! لمساهمتك:

1. **Fork** المستودع
2. أنشئ **Branch** جديد (`git checkout -b feature/amazing-feature`)
3. **Commit** التغييرات (`git commit -m 'Add amazing feature'`)
4. **Push** إلى الـ Branch (`git push origin feature/amazing-feature`)
5. افتح **Pull Request**

---

## 📄 الترخيص

هذا المشروع مرخص بموجب [MIT License](LICENSE).

---

<div align="center">

**الجهة:** وزارة التعليم العالي والبحث العلمي — جامعة حماة — المعهد التقاني للحاسوب  
**القسم:** قسم هندسة البرمجيات  
**المادة:** تحليل نظم المعلومات  
**الفصل الدراسي:** الأول لعام 2025/2026 م

---

صُنع بـ ❤️ في سوريا

</div>
