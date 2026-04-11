import Link from 'next/link';

export default function SearchPage() {
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
              <Link href="/search" className="text-primary-600 font-medium">
                البحث
              </Link>
              <Link href="/login" className="text-gray-700 hover:text-primary-600">
                تسجيل الدخول
              </Link>
            </nav>
          </div>
        </div>
      </header>

      {/* Advanced Search */}
      <section className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-8">
          <h2 className="text-2xl font-bold mb-6">بحث متقدم</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                نوع العقار
              </label>
              <select className="w-full border rounded-lg px-4 py-3">
                <option>كل الأنواع</option>
                <option>شقة</option>
                <option>منزل</option>
                <option>فيلا</option>
                <option>أرض</option>
                <option>تجاري</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                نوع الإعلان
              </label>
              <select className="w-full border rounded-lg px-4 py-3">
                <option>كل الإعلانات</option>
                <option>بيع</option>
                <option>إيجار شهري</option>
                <option>إيجار سنوي</option>
                <option>إيجار يومي</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                المحافظة
              </label>
              <select className="w-full border rounded-lg px-4 py-3">
                <option>كل المحافظات</option>
                <option>دمشق</option>
                <option>ريف دمشق</option>
                <option>حلب</option>
                <option>حمص</option>
                <option>حماة</option>
                <option>اللاذقية</option>
                <option>طرطوس</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                المنطقة
              </label>
              <select className="w-full border rounded-lg px-4 py-3">
                <option>كل المناطق</option>
                <option>الملكي</option>
                <option>المزة</option>
                <option>الشعلان</option>
                <option>اليرموك</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                السعر من
              </label>
              <input type="number" className="w-full border rounded-lg px-4 py-3" placeholder="0" />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                السعر إلى
              </label>
              <input type="number" className="w-full border rounded-lg px-4 py-3" placeholder="∞" />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                المساحة من (م²)
              </label>
              <input type="number" className="w-full border rounded-lg px-4 py-3" placeholder="0" />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                المساحة إلى (م²)
              </label>
              <input type="number" className="w-full border rounded-lg px-4 py-3" placeholder="∞" />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                غرف نوم
              </label>
              <select className="w-full border rounded-lg px-4 py-3">
                <option>الكل</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5+</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                حمام
              </label>
              <select className="w-full border rounded-lg px-4 py-3">
                <option>الكل</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4+</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                سنة البناء من
              </label>
              <input type="number" className="w-full border rounded-lg px-4 py-3" placeholder="2000" />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                سنة البناء إلى
              </label>
              <input type="number" className="w-full border rounded-lg px-4 py-3" placeholder="2024" />
            </div>
          </div>

          <div className="mt-6 flex gap-4">
            <button className="bg-primary-600 text-white px-8 py-3 rounded-lg hover:bg-primary-700 transition">
              بحث
            </button>
            <button className="border border-gray-300 px-8 py-3 rounded-lg hover:bg-gray-50 transition">
              إعادة تعيين
            </button>
            <button className="border border-primary-600 text-primary-600 px-8 py-3 rounded-lg hover:bg-primary-50 transition">
              حفظ البحث
            </button>
          </div>
        </div>
      </section>

      {/* Search Results */}
      <section className="container mx-auto px-4 py-8">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold text-gray-900">نتائج البحث</h2>
          <div className="flex gap-4">
            <select className="border rounded-lg px-4 py-2">
              <option>الأحدث</option>
              <option>الأقل سعراً</option>
              <option>الأعلى سعراً</option>
              <option>الأصغر مساحة</option>
              <option>الأكبر مساحة</option>
            </select>
            <select className="border rounded-lg px-4 py-2">
              <option>عرض شبكي</option>
              <option>عرض قائمة</option>
            </select>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <Link key={i} href={`/properties/${i}`} className="block">
              <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition">
                <div className="h-48 bg-gray-200"></div>
                <div className="p-4">
                  <h3 className="font-bold text-lg mb-2">شقة فاخرة في دمشق</h3>
                  <p className="text-gray-600 text-sm mb-3">📍 الملكي، دمشق</p>
                  <div className="flex gap-4 text-sm text-gray-500 mb-3">
                    <span>🛏️ 3 غرف</span>
                    <span>🚿 2 حمام</span>
                    <span>📐 120 م²</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-xl font-bold text-primary-600">150,000,000 ل.س</span>
                    <span className="text-sm text-gray-500">بيع</span>
                  </div>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
