'use client';

import Link from 'next/link';
import { useProperties } from '@/hooks/useApi';

export default function Home() {
  const { data: propertiesData, isLoading } = useProperties({ featured: true, limit: 3 });
  const properties = propertiesData?.data?.properties || [];

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-white">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-primary-600">DEALAK</h1>
            <nav className="flex gap-6" aria-label="التنقل الرئيسي">
              <Link href="/properties" className="text-gray-700 hover:text-primary-600 focus:outline-none focus:ring-2 focus:ring-primary-600 rounded px-2 py-1">
                العقارات
              </Link>
              <Link href="/search" className="text-gray-700 hover:text-primary-600 focus:outline-none focus:ring-2 focus:ring-primary-600 rounded px-2 py-1">
                البحث
              </Link>
              <Link href="/login" className="text-gray-700 hover:text-primary-600 focus:outline-none focus:ring-2 focus:ring-primary-600 rounded px-2 py-1">
                تسجيل الدخول
              </Link>
            </nav>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="container mx-auto px-4 py-20" aria-labelledby="hero-heading">
        <div className="text-center">
          <h2 id="hero-heading" className="text-5xl font-bold text-gray-900 mb-6">
            ابحث عن عقارك المثالي في سوريا
          </h2>
          <p className="text-xl text-gray-600 mb-8">
            آلاف العقارات المتاحة للبيع والإيجار في جميع المحافظات
          </p>

          {/* Search Box */}
          <div className="max-w-3xl mx-auto bg-white rounded-lg shadow-lg p-6" role="search">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label htmlFor="property-type" className="sr-only">نوع العقار</label>
                <select id="property-type" className="border rounded-lg px-4 py-3 w-full focus:outline-none focus:ring-2 focus:ring-primary-600">
                  <option>نوع العقار</option>
                  <option>شقة</option>
                  <option>منزل</option>
                  <option>فيلا</option>
                  <option>أرض</option>
                </select>
              </div>
              <div>
                <label htmlFor="listing-type" className="sr-only">نوع الإعلان</label>
                <select id="listing-type" className="border rounded-lg px-4 py-3 w-full focus:outline-none focus:ring-2 focus:ring-primary-600">
                  <option>نوع الإعلان</option>
                  <option>بيع</option>
                  <option>إيجار شهري</option>
                  <option>إيجار سنوي</option>
                </select>
              </div>
              <div>
                <label htmlFor="governorate" className="sr-only">المحافظة</label>
                <select id="governorate" className="border rounded-lg px-4 py-3 w-full focus:outline-none focus:ring-2 focus:ring-primary-600">
                  <option>المحافظة</option>
                  <option>دمشق</option>
                  <option>حلب</option>
                  <option>حمص</option>
                  <option>حماة</option>
                </select>
              </div>
            </div>
            <Link href="/search" className="block w-full mt-4 bg-primary-600 text-white py-3 rounded-lg hover:bg-primary-700 transition text-center focus:outline-none focus:ring-2 focus:ring-primary-600 focus:ring-offset-2">
              بحث
            </Link>
          </div>
        </div>
      </section>

      {/* Featured Properties */}
      <section className="container mx-auto px-4 py-16" aria-labelledby="featured-heading">
        <h3 id="featured-heading" className="text-3xl font-bold text-gray-900 mb-8">عقارات مميزة</h3>

        {isLoading ? (
          <div className="text-center py-12" role="status" aria-live="polite" aria-busy="true">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4" aria-hidden="true"></div>
            <p className="text-gray-600">جاري تحميل العقارات...</p>
          </div>
        ) : properties.length === 0 ? (
          <div className="text-center py-12" role="status">
            <p className="text-gray-600">لا توجد عقارات مميزة حالياً</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {properties.map((property: any) => (
              <Link key={property.id} href={`/properties/${property.id}`} className="block focus:outline-none focus:ring-2 focus:ring-primary-600 rounded-lg">
                <article className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition h-full">
                  <div className="h-48 bg-gray-200">
                    {property.images && property.images.length > 0 && (
                      <img
                        src={property.images[0].imageUrl}
                        alt={property.title}
                        className="w-full h-full object-cover"
                        loading="lazy"
                      />
                    )}
                  </div>
                  <div className="p-4">
                    <h4 className="font-bold text-lg mb-2">{property.title}</h4>
                    <p className="text-gray-600 mb-4">
                      {property.bedrooms} غرف نوم، {property.bathrooms} حمام، {property.area} م²
                    </p>
                    <div className="flex justify-between items-center">
                      <span className="text-2xl font-bold text-primary-600">
                        {property.price.toLocaleString()} {property.currency}
                      </span>
                      <span className="text-sm text-gray-500">
                        {property.listingType === 'sale' ? 'بيع' : 'إيجار'}
                      </span>
                    </div>
                  </div>
                </article>
              </Link>
            ))}
          </div>
        )}
      </section>

      {/* Stats */}
      <section className="bg-primary-600 text-white py-16" aria-labelledby="stats-heading">
        <h2 id="stats-heading" className="sr-only">إحصائيات المنصة</h2>
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8 text-center">
            <div>
              <div className="text-4xl font-bold mb-2">1000+</div>
              <div className="text-primary-100">عقار متاح</div>
            </div>
            <div>
              <div className="text-4xl font-bold mb-2">500+</div>
              <div className="text-primary-100">عميل سعيد</div>
            </div>
            <div>
              <div className="text-4xl font-bold mb-2">50+</div>
              <div className="text-primary-100">وسيط عقاري</div>
            </div>
            <div>
              <div className="text-4xl font-bold mb-2">100+</div>
              <div className="text-primary-100">صفقة مكتملة</div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12" role="contentinfo">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div>
              <h5 className="font-bold text-lg mb-4">DEALAK</h5>
              <p className="text-gray-400">منصة العقارات الأولى في سوريا</p>
            </div>
            <div>
              <h5 className="font-bold text-lg mb-4">روابط سريعة</h5>
              <nav aria-label="روابط سريعة">
                <ul className="space-y-2 text-gray-400">
                  <li><Link href="/properties" className="hover:text-white focus:outline-none focus:ring-2 focus:ring-primary-600 rounded px-2 py-1">العقارات</Link></li>
                  <li><Link href="/about" className="hover:text-white focus:outline-none focus:ring-2 focus:ring-primary-600 rounded px-2 py-1">من نحن</Link></li>
                  <li><Link href="/contact" className="hover:text-white focus:outline-none focus:ring-2 focus:ring-primary-600 rounded px-2 py-1">اتصل بنا</Link></li>
                </ul>
              </nav>
            </div>
            <div>
              <h5 className="font-bold text-lg mb-4">الدعم</h5>
              <nav aria-label="الدعم">
                <ul className="space-y-2 text-gray-400">
                  <li><Link href="/help" className="hover:text-white focus:outline-none focus:ring-2 focus:ring-primary-600 rounded px-2 py-1">مركز المساعدة</Link></li>
                  <li><Link href="/faq" className="hover:text-white focus:outline-none focus:ring-2 focus:ring-primary-600 rounded px-2 py-1">الأسئلة الشائعة</Link></li>
                  <li><Link href="/privacy" className="hover:text-white focus:outline-none focus:ring-2 focus:ring-primary-600 rounded px-2 py-1">سياسة الخصوصية</Link></li>
                </ul>
              </nav>
            </div>
            <div>
              <h5 className="font-bold text-lg mb-4">تواصل معنا</h5>
              <address className="not-italic text-gray-400">
                <p>info@dealak.com</p>
                <p>+963 958 794 195</p>
              </address>
            </div>
          </div>
          <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; 2026 DEALAK. جميع الحقوق محفوظة.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
