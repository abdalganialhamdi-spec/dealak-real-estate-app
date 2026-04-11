import Link from 'next/link';

export default function PropertyDetailPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <Link href="/" className="text-2xl font-bold text-primary-600">
              DEALAK
            </Link>
            <nav className="flex gap-6">
              <Link href="/properties" className="text-gray-700 hover:text-primary-600">
                العقارات
              </Link>
              <Link href="/search" className="text-gray-700 hover:text-primary-600">
                البحث
              </Link>
              <Link href="/login" className="text-gray-700 hover:text-primary-600">
                تسجيل الدخول
              </Link>
            </nav>
          </div>
        </div>
      </header>

      {/* Breadcrumb */}
      <div className="container mx-auto px-4 py-4">
        <nav className="text-sm text-gray-600">
          <Link href="/" className="hover:text-primary-600">الرئيسية</Link>
          <span className="mx-2">/</span>
          <Link href="/properties" className="hover:text-primary-600">العقارات</Link>
          <span className="mx-2">/</span>
          <span className="text-gray-900">شقة فاخرة في دمشق</span>
        </nav>
      </div>

      {/* Property Details */}
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2">
            {/* Image Gallery */}
            <div className="bg-white rounded-lg shadow-md overflow-hidden mb-6">
              <div className="h-96 bg-gray-200"></div>
              <div className="grid grid-cols-4 gap-2 p-2">
                {[1, 2, 3, 4].map((i) => (
                  <div key={i} className="h-20 bg-gray-200 rounded cursor-pointer hover:opacity-75"></div>
                ))}
              </div>
            </div>

            {/* Property Info */}
            <div className="bg-white rounded-lg shadow-md p-6 mb-6">
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h1 className="text-3xl font-bold text-gray-900 mb-2">
                    شقة فاخرة في دمشق
                  </h1>
                  <p className="text-gray-600">📍 الملكي، دمشق</p>
                </div>
                <div className="text-left">
                  <div className="text-3xl font-bold text-primary-600">150,000,000 ل.س</div>
                  <div className="text-sm text-gray-500">بيع</div>
                </div>
              </div>

              <div className="grid grid-cols-4 gap-4 py-6 border-y">
                <div className="text-center">
                  <div className="text-2xl mb-1">🛏️</div>
                  <div className="font-bold">3</div>
                  <div className="text-sm text-gray-500">غرف نوم</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl mb-1">🚿</div>
                  <div className="font-bold">2</div>
                  <div className="text-sm text-gray-500">حمام</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl mb-1">📐</div>
                  <div className="font-bold">120</div>
                  <div className="text-sm text-gray-500">متر مربع</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl mb-1">🏢</div>
                  <div className="font-bold">5</div>
                  <div className="text-sm text-gray-500">طابق</div>
                </div>
              </div>

              <div className="py-6">
                <h2 className="text-xl font-bold mb-4">الوصف</h2>
                <p className="text-gray-700 leading-relaxed">
                  شقة فاخرة في حي الملكي بدمشق، تتكون من 3 غرف نوم وصالة واسعة، 
                  مطبخ مجهز بالكامل، شرفة مطلة على الحديقة، مواقف سيارات، 
                  أمن 24 ساعة، قرب من جميع الخدمات والمرافق العامة.
                </p>
              </div>

              <div className="py-6 border-t">
                <h2 className="text-xl font-bold mb-4">المميزات</h2>
                <div className="grid grid-cols-2 gap-3">
                  {['موقف سيارات', 'أمن 24 ساعة', 'شرفة', 'مطبخ مجهز', 'تكييف مركزي', 'إنترنت عالي السرعة'].map((feature) => (
                    <div key={feature} className="flex items-center gap-2">
                      <span className="text-green-500">✓</span>
                      <span>{feature}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Location */}
            <div className="bg-white rounded-lg shadow-md p-6">
              <h2 className="text-xl font-bold mb-4">الموقع</h2>
              <div className="h-64 bg-gray-200 rounded-lg"></div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Contact Card */}
            <div className="bg-white rounded-lg shadow-md p-6">
              <h3 className="text-xl font-bold mb-4">تواصل مع البائع</h3>
              <div className="flex items-center gap-4 mb-4">
                <div className="w-12 h-12 bg-gray-200 rounded-full"></div>
                <div>
                  <div className="font-bold">أحمد محمد</div>
                  <div className="text-sm text-gray-500">وسيط عقاري</div>
                </div>
              </div>
              <button className="w-full bg-primary-600 text-white py-3 rounded-lg hover:bg-primary-700 transition mb-3">
                إرسال رسالة
              </button>
              <button className="w-full border border-primary-600 text-primary-600 py-3 rounded-lg hover:bg-primary-50 transition mb-3">
                📞 +963 9XX XXX XXX
              </button>
              <button className="w-full border border-gray-300 py-3 rounded-lg hover:bg-gray-50 transition">
                💬 واتساب
              </button>
            </div>

            {/* Similar Properties */}
            <div className="bg-white rounded-lg shadow-md p-6">
              <h3 className="text-xl font-bold mb-4">عقارات مشابهة</h3>
              <div className="space-y-4">
                {[1, 2, 3].map((i) => (
                  <Link key={i} href={`/properties/${i}`} className="block">
                    <div className="flex gap-4">
                      <div className="w-24 h-24 bg-gray-200 rounded"></div>
                      <div className="flex-1">
                        <h4 className="font-bold mb-1">شقة في حلب</h4>
                        <p className="text-sm text-gray-500 mb-2">2 غرف، 90 م²</p>
                        <div className="font-bold text-primary-600">100,000,000 ل.س</div>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
