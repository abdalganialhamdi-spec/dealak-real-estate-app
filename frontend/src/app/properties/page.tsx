import Link from 'next/link';

export default function PropertiesPage() {
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
              <Link href="/properties" className="text-primary-600 font-medium">
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

      {/* Search Filters */}
      <section className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-6">
          <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
            <select className="border rounded-lg px-4 py-3">
              <option>كل الأنواع</option>
              <option>شقة</option>
              <option>منزل</option>
              <option>فيلا</option>
              <option>أرض</option>
            </select>
            <select className="border rounded-lg px-4 py-3">
              <option>كل الإعلانات</option>
              <option>بيع</option>
              <option>إيجار شهري</option>
              <option>إيجار سنوي</option>
            </select>
            <select className="border rounded-lg px-4 py-3">
              <option>كل المحافظات</option>
              <option>دمشق</option>
              <option>حلب</option>
              <option>حمص</option>
              <option>حماة</option>
            </select>
            <select className="border rounded-lg px-4 py-3">
              <option>السعر</option>
              <option>أقل من 50 مليون</option>
              <option>50 - 100 مليون</option>
              <option>100 - 200 مليون</option>
              <option>أكثر من 200 مليون</option>
            </select>
            <button className="bg-primary-600 text-white py-3 rounded-lg hover:bg-primary-700 transition">
              بحث
            </button>
          </div>
        </div>
      </section>

      {/* Properties Grid */}
      <section className="container mx-auto px-4 py-8">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold text-gray-900">العقارات المتاحة</h2>
          <span className="text-gray-600">24 نتيجة</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <Link key={i} href={`/properties/${i}`} className="block">
              <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition">
                <div className="h-48 bg-gray-200 relative">
                  <span className="absolute top-2 right-2 bg-primary-600 text-white px-3 py-1 rounded-full text-sm">
                    مميز
                  </span>
                </div>
                <div className="p-4">
                  <h3 className="font-bold text-lg mb-2">شقة فاخرة في دمشق</h3>
                  <p className="text-gray-600 text-sm mb-3">
                    <span className="inline-block ml-2">📍 الملكي، دمشق</span>
                  </p>
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

        {/* Pagination */}
        <div className="flex justify-center mt-8 gap-2">
          <button className="px-4 py-2 border rounded-lg hover:bg-gray-50">السابق</button>
          <button className="px-4 py-2 bg-primary-600 text-white rounded-lg">1</button>
          <button className="px-4 py-2 border rounded-lg hover:bg-gray-50">2</button>
          <button className="px-4 py-2 border rounded-lg hover:bg-gray-50">3</button>
          <button className="px-4 py-2 border rounded-lg hover:bg-gray-50">التالي</button>
        </div>
      </section>
    </div>
  );
}
