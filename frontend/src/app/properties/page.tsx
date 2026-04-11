'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useProperties, useAddFavorite, useRemoveFavorite } from '@/hooks/useApi';
import { useAuthStore } from '@/store';

export default function PropertiesPage() {
  const { user } = useAuthStore();
  const [filters, setFilters] = useState({
    type: '',
    listingType: '',
    governorate: '',
    minPrice: '',
    maxPrice: '',
  });

  const { data: propertiesData, isLoading, error } = useProperties(filters);
  const addFavorite = useAddFavorite();
  const removeFavorite = useRemoveFavorite();

  const properties = propertiesData?.data?.properties || [];

  const handleSearch = () => {
    setFilters({
      type: (document.getElementById('type') as HTMLSelectElement)?.value || '',
      listingType: (document.getElementById('listingType') as HTMLSelectElement)?.value || '',
      governorate: (document.getElementById('governorate') as HTMLSelectElement)?.value || '',
      minPrice: (document.getElementById('minPrice') as HTMLInputElement)?.value || '',
      maxPrice: (document.getElementById('maxPrice') as HTMLInputElement)?.value || '',
    });
  };

  const handleFavorite = async (propertyId: number, isFavorite: boolean) => {
    if (!user) {
      alert('يجب تسجيل الدخول لإضافة العقار للمفضلة');
      return;
    }

    try {
      if (isFavorite) {
        await removeFavorite.mutateAsync({ userId: user.id, propertyId });
      } else {
        await addFavorite.mutateAsync({ userId: user.id, propertyId });
      }
    } catch (error) {
      console.error('Failed to toggle favorite:', error);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">جاري تحميل العقارات...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-red-600 mb-4">فشل تحميل العقارات</p>
          <button
            onClick={() => window.location.reload()}
            className="bg-primary-600 text-white px-6 py-2 rounded-lg"
          >
            إعادة المحاولة
          </button>
        </div>
      </div>
    );
  }

  if (properties.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-gray-600 mb-4">لا توجد عقارات متاحة</p>
          <button
            onClick={() => setFilters({ type: '', listingType: '', governorate: '', minPrice: '', maxPrice: '' })}
            className="bg-primary-600 text-white px-6 py-2 rounded-lg"
          >
            عرض جميع العقارات
          </button>
        </div>
      </div>
    );
  }

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
            <select
              id="type"
              className="border rounded-lg px-4 py-3"
              defaultValue=""
            >
              <option value="">كل الأنواع</option>
              <option value="apartment">شقة</option>
              <option value="house">منزل</option>
              <option value="villa">فيلا</option>
              <option value="land">أرض</option>
            </select>
            <select
              id="listingType"
              className="border rounded-lg px-4 py-3"
              defaultValue=""
            >
              <option value="">كل الإعلانات</option>
              <option value="sale">بيع</option>
              <option value="rent_monthly">إيجار شهري</option>
              <option value="rent_yearly">إيجار سنوي</option>
            </select>
            <select
              id="governorate"
              className="border rounded-lg px-4 py-3"
              defaultValue=""
            >
              <option value="">كل المحافظات</option>
              <option value="Damascus">دمشق</option>
              <option value="Aleppo">حلب</option>
              <option value="Homs">حمص</option>
              <option value="Hama">حماة</option>
            </select>
            <input
              id="minPrice"
              type="number"
              className="border rounded-lg px-4 py-3"
              placeholder="السعر من"
            />
            <input
              id="maxPrice"
              type="number"
              className="border rounded-lg px-4 py-3"
              placeholder="السعر إلى"
            />
          </div>
          <button
            onClick={handleSearch}
            className="mt-4 bg-primary-600 text-white py-3 rounded-lg hover:bg-primary-700 transition"
          >
            بحث
          </button>
        </div>
      </section>

      {/* Properties Grid */}
      <section className="container mx-auto px-4 py-8">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold text-gray-900">العقارات المتاحة</h2>
          <span className="text-gray-600">{properties.length} نتيجة</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {properties.map((property: any) => (
            <Link key={property.id} href={`/properties/${property.id}`} className="block">
              <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition">
                <div className="h-48 bg-gray-200 relative">
                  {property.featured && (
                    <span className="absolute top-2 right-2 bg-primary-600 text-white px-3 py-1 rounded-full text-sm">
                      مميز
                    </span>
                  )}
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
                  <p className="text-gray-600 text-sm mb-3">
                    <span className="inline-block ml-2">📍 {property.areaName}, {property.governorate}</span>
                  </p>
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
