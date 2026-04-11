'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

export default function RegisterPage() {
  const router = useRouter();
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    role: 'buyer',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Implement registration logic
    console.log('Register:', formData);
    router.push('/login');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-white flex items-center justify-center px-4 py-12">
      <div className="max-w-md w-full bg-white rounded-lg shadow-xl p-8">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-primary-600 mb-2">DEALAK</h1>
          <h2 className="text-2xl font-bold text-gray-900">إنشاء حساب جديد</h2>
          <p className="text-gray-600 mt-2">انضم إلينا اليوم</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                الاسم الأول
              </label>
              <input
                type="text"
                required
                value={formData.firstName}
                onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
                className="w-full border rounded-lg px-4 py-3 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                placeholder="محمد"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                اسم العائلة
              </label>
              <input
                type="text"
                required
                value={formData.lastName}
                onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
                className="w-full border rounded-lg px-4 py-3 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                placeholder="أحمد"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              البريد الإلكتروني
            </label>
            <input
              type="email"
              required
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              className="w-full border rounded-lg px-4 py-3 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              placeholder="example@email.com"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              رقم الهاتف
            </label>
            <input
              type="tel"
              value={formData.phone}
              onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              className="w-full border rounded-lg px-4 py-3 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              placeholder="+963 9XX XXX XXX"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              نوع الحساب
            </label>
            <select
              value={formData.role}
              onChange={(e) => setFormData({ ...formData, role: e.target.value })}
              className="w-full border rounded-lg px-4 py-3 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            >
              <option value="buyer">مشتري / مستأجر</option>
              <option value="seller">بائع / مالك</option>
              <option value="agent">وسيط عقاري</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              كلمة المرور
            </label>
            <input
              type="password"
              required
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              className="w-full border rounded-lg px-4 py-3 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              placeholder="••••••••"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              تأكيد كلمة المرور
            </label>
            <input
              type="password"
              required
              value={formData.confirmPassword}
              onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
              className="w-full border rounded-lg px-4 py-3 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              placeholder="••••••••"
            />
          </div>

          <button
            type="submit"
            className="w-full bg-primary-600 text-white py-3 rounded-lg hover:bg-primary-700 transition font-medium"
          >
            إنشاء الحساب
          </button>
        </form>

        <p className="text-center mt-6 text-gray-600">
          لديك حساب بالفعل؟{' '}
          <Link href="/login" className="text-primary-600 hover:underline font-medium">
            تسجيل الدخول
          </Link>
        </p>
      </div>
    </div>
  );
}
