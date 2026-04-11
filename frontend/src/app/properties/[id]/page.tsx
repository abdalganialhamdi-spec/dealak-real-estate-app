'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useProperty, useAddFavorite, useRemoveFavorite } from '@/hooks/useApi';
import { useAuthStore } from '@/store';

export default function PropertyDetailPage({ params }: { params: { id: string } }) {
  const { user } = useAuthStore();
  const [isFavorite, setIsFavorite] = useState(false);
  const { data: propertyData, isLoading, error } = useProperty(parseInt(params.id));
  const addFavorite = useAddFavorite();
  const removeFavorite = useRemoveFavorite();

  const property = propertyData?.data?.property;

  const handleFavorite = async () => {
    if (!user) {
      alert('يجب تسجيل الدخول لإضافة العقار للمفضلة');
      return;
    }

    try {
      if (isFavorite) {
        await removeFavorite.mutateAsync({ userId: user.id, propertyId: property.id });
        setIsFavorite(false);
      } else {
        await addFavorite.mutateAsync({ userId: user.id, propertyId: property.id });
        setIsFavorite(true);
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
          <p className="text-gray-600">جاري تحميل تفاصيل العقار...</p>
        </div>
      </div>
    );
  }

  if (error || !property) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-red-600 mb-4">فشل تحميل تفاصيل العقار</p>
          <Link
            href="/properties"
            className="bg-primary-600 text-white px-6 py-2 rounded-lg"
          >
            العودة للعقارات
          </Link>
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
          <span className="text-gray-900">{property.title}</span>
        </nav>
      </div>

      {/* Property Details */}
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2">
            {/* Image Gallery */}
            <div className="bg-white rounded-lg shadow-md overflow-hidden mb-6">
              <div className="h-96 bg-gray-200">
                {property.images && property.images.length > 0 ? (
                  <img
                    src={property.images.find((img: any) => img.isPrimary)?.imageUrl || property.images[0].imageUrl}
                    alt={property.title}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-gray-400">
                    لا توجد صور
                  </div>
                )}
              </div>
              {property.images && property.images.length > 1 && (
                <div className="grid grid-cols-4 gap-2 p-2">
                  {property.images.slice(0, 4).map((image: any) => (
                    <div key={image.id} className="h-20 bg-gray-200 rounded cursor-pointer hover:opacity-75">
                      <img
                        src={image.imageUrl}
                        alt={property.title}
                        className="w-full h-full object-cover rounded"
                      />
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Property Info */}
            <div className="bg-white rounded-lg shadow-md p-6 mb-6">
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h1 className="text-3xl font-bold text-gray-900 mb-2">
                    {property.title}
                  </h1>
                  <p className="text-gray-600">📍 {property.areaName}, {property.governorate}</p>
                </div>
                <div className="text-left">
                  <div className="text-3xl font-bold text-primary-600">
                    {property.price.toLocaleString()} {property.currency}
                  </div>
                  <div className="text-sm text-gray-500">
                    {property.listingType === 'sale' ? 'بيع' : 'إيجار'}
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-4 gap-4 py-6 border-y">
                <div className="text-center">
                  <div className="text-2xl mb-1">🛏️</div>
                  <div className="font-bold">{property.bedrooms}</div>
                  <div className="text-sm text-gray-500">غرف نوم</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl mb-1">🚿</div>
                  <div className="font-bold">{property.bathrooms}</div>
                  <div className="text-sm text-gray-500">حمام</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl mb-1">📐</div>
                  <div className="font-bold">{property.area}</div>
                  <div className="text-sm text-gray-500">متر مربع</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl mb-1">🏢</div>
                  <div className="font-bold">{property.floor || '-'}</div>
                  <div className="text-sm text-gray-500">طابق</div>
                </div>
              </div>

              <div className="py-6">
                <h2 className="text-xl font-bold mb-4">الوصف</h2>
                <p className="text-gray-700 leading-relaxed">
                  {property.description}
                </p>
              </div>

              {property.features && property.features.length > 0 && (
                <div className="py-6 border-t">
                  <h2 className="text-xl font-bold mb-4">المميزات</h2>
                  <div className="grid grid-cols-2 gap-3">
                    {property.features.map((feature: any) => (
                      <div key={feature.id} className="flex items-center gap-2">
                        <span className="text-green-500">✓</span>
                        <span>{feature.feature}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Location */}
            <div className="bg-white rounded-lg shadow-md p-6">
              <h2 className="text-xl font-bold mb-4">الموقع</h2>
              <div className="h-64 bg-gray-200 rounded-lg flex items-center justify-center text-gray-400">
                {property.latitude && property.longitude ? (
                  <div className="text-center">
                    <p>📍 {property.latitude}, {property.longitude}</p>
                    <p className="text-sm mt-2">خريطة الموقع</p>
                  </div>
                ) : (
                  <p>لا توجد إحداثيات</p>
                )}
              </div>
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
                  <div className="font-bold">المالك</div>
                  <div className="text-sm text-gray-500">بائع</div>
                </div>
              </div>
              <button
                onClick={handleFavorite}
                className={`w-full py-3 rounded-lg transition mb-3 ${
                  isFavorite
                    ? 'bg-red-600 text-white hover:bg-red-700'
                    : 'bg-primary-600 text-white hover:bg-primary-700'
                }`}
              >
                {isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة'}
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
                <p className="text-gray-500 text-sm">قريباً...</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
