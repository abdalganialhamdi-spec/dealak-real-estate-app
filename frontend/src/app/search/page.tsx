'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useProperties } from '@/hooks/useApi';

export default function SearchPage() {
  const [filters, setFilters] = useState({
    type: '',
    listingType: '',
    governorate: '',
    area: '',
    minPrice: '',
    maxPrice: '',
    minArea: '',
    maxArea: '',
    bedrooms: '',
    bathrooms: '',
    minYear: '',
    maxYear: '',
  });

  const { data: propertiesData, isLoading, error } = useProperties(filters);
  const properties = propertiesData?.data?.properties || [];

  const handleSearch = () => {
    setFilters({
      type: (document.getElementById('type') as HTMLSelectElement)?.value || '',
      listingType: (document.getElementById('listingType') as HTMLSelectElement)?.value || '',
      governorate: (document.getElementById('governorate') as HTMLSelectElement)?.value || '',
      area: (document.getElementById('area') as HTMLSelectElement)?.value || '',
      minPrice: (document.getElementById('minPrice') as HTMLInputElement)?.value || '',
      maxPrice: (document.getElementById('maxPrice') as HTMLInputElement)?.value || '',
      minArea: (document.getElementById('minArea') as HTMLInputElement)?.value || '',
      maxArea: (document.getElementById('maxArea') as HTMLInputElement)?.value || '',
      bedrooms: (document.getElementById('bedrooms') as HTMLSelectElement)?.value || '',
      bathrooms: (document.getElementById('bathrooms') as HTMLSelectElement)?.value || '',
      minYear: (document.getElementById('minYear') as HTMLInputElement)?.value || '',
      maxYear: (document.getElementById('maxYear') as HTMLInputElement)?.value || '',
    });
  };

  const handleReset = () => {
    setFilters({
      type: '',
      listingType: '',
      governorate: '',
      area: '',
      minPrice: '',
      maxPrice: '',
      minArea: '',
      maxArea: '',
      bedrooms: '',
      bathrooms: '',
      minYear: '',
      maxYear: '',
    });
  };

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
              <select
                id="type"
                className="w-full border rounded-lg px-4 py-3"
                defaultValue=""
              >
                <option value="">كل الأنواع</option>
                <option value="apartment">شقة</option>
                <option value="house">منزل</option>
                <option value="villa">فيلا</option>
                <option value="land">أرض</option>
                <option value="commercial">تجاري</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                نوع الإعلان
              </label>
              <select
                id="listingType"
                className="w-full border rounded-lg px-4 py-3"
                defaultValue=""
              >
                <option value="">كل الإعلانات</option>
                <option value="sale">بيع</option>
                <option value="rent_monthly">إيجار شهري</option>
                <option value="rent_yearly">إيجار سنوي</option>
                <option value="rent_daily">إيجار يومي</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                المحافظة
              </label>
              <select
                id="governorate"
                className="w-full border rounded-lg px-4 py-3"
                defaultValue=""
              >
                <option value="">كل المحافظات</option>
                <option value="Damascus">دمشق</option>
                <option value="Rif Dimashq">ريف دمشق</option>
                <option value="Aleppo">حلب</option>
                <option value="Homs">حمص</option>
                <option value="Hama">حماة</option>
                <option value="Latakia">اللاذقية</option>
                <option value="Tartus">طرطوس</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                المنطقة
              </label>
              <select
                id="area"
                className="w-full border rounded-lg px-4 py-3"
                defaultValue=""
              >
                <option value="">كل المناطق</option>
                <option value="Al-Malki">الملكي</option>
                <option value="Al-Mazza">المزة</option>
                <option value="Al-Shaalan">الشعلان</option>
                <option value="Al-Yarmouk">اليرموك</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                السعر من
              </label>
              <input
                id="minPrice"
                type="number"
                className="w-full border rounded-lg px-4 py-3"
                placeholder="0"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                السعر إلى
              </label>
              <input
                id="maxPrice"
                type="number"
                className="w-full border rounded-lg px-4 py-3"
                placeholder="∞"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                المساحة من (م²)
              </label>
              <input
                id="minArea"
                type="number"
                className="w-full border rounded-lg px-4 py-3"
                placeholder="0"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                المساحة إلى (م²)
              </label>
              <input
                id="maxArea"
                type="number"
                className="w-full border rounded-lg px-4 py-3"
                placeholder="∞"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                غرف نوم
              </label>
              <select
                id="bedrooms"
                className="w-full border rounded-lg px-4 py-3"
                defaultValue=""
              >
                <option value="">الكل</option>
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
                <option value="4">4</option>
                <option value="5">5+</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                حمام
              </label>
              <select
                id="bathrooms"
                className="w-full border rounded-lg px-4 py-3"
                defaultValue=""
              >
                <option value="">الكل</option>
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
                <option value="4">4+</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                سنة البناء من
              </label>
              <input
                id="minYear"
                type="number"
                className="w-full border rounded-lg px-4 py-3"
                placeholder="2000"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                سنة البناء إلى
              </label>
              <input
                id="maxYear"
                type="number"
                className="w-full border rounded-lg px-4 py-3"
                placeholder="2024"
              />
            </div>
          </div>

          <div className="mt-6 flex gap-4">
            <button
              onClick={handleSearch}
              className="bg-primary-600 text-white px-8 py-3 rounded-lg hover:bg-primary-700 transition"
            >
              بحث
            </button>
            <button
              onClick={handleReset}
              className="border border-gray-300 px-8 py-3 rounded-lg hover:bg-gray-50 transition"
            >
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

        {isLoading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
            <p className="text-gray-600">جاري البحث...</p>
          </div>
        ) : error ? (
          <div className="text-center py-12">
            <p className="text-red-600 mb-4">فشل البحث</p>
            <button
              onClick={handleSearch}
              className="bg-primary-600 text-white px-6 py-2 rounded-lg"
            >
              إعادة المحاولة
            </button>
          </div>
        ) : properties.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600 mb-4">لا توجد نتائج</p>
            <button
              onClick={handleReset}
              className="bg-primary-600 text-white px-6 py-2 rounded-lg"
            >
              إعادة تعيين البحث
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {properties.map((property: any) => (
              <Link key={property.id} href={`/properties/${property.id}`} className="block">
                <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition">
                  <div className="h-48 bg-gray-200">
                    {property.images && property.images.length > 0 && (
                      <img
                        src={property.images[0].imageUrl}
                        alt={property.title}
                        className="w-full h-full object-cover"
                      />
                    )}
                  </div>
                  <div className="p-4">
                    <h3 className="font-bold text-lg mb-2">{property.title}</h3>
                    <p className="text-gray-600 text-sm mb-3">📍 {property.areaName}, {property.governorate}</p>
                    <div className="flex gap-4 text-sm text-gray-500 mb-3">
                      <span>🛏️ {property.bedrooms} غرف</span>
                      <span>🚿 {property.bathrooms} حمام</span>
                      <span>📐 {property.area} م²</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-xl font-bold text-primary-600">
                        {property.price.toLocaleString()} {property.currency}
                      </span>
                      <span className="text-sm text-gray-500">
                        {property.listingType === 'sale' ? 'بيع' : 'إيجار'}
                      </span>
                    </div>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
