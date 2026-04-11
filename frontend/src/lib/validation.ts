import { z } from 'zod';

// Auth Schemas
export const loginSchema = z.object({
  email: z.string().email('البريد الإلكتروني غير صالح'),
  password: z.string().min(8, 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'),
});

export const registerSchema = z.object({
  firstName: z.string().min(2, 'الاسم الأول يجب أن يكون حرفين على الأقل'),
  lastName: z.string().min(2, 'اسم العائلة يجب أن يكون حرفين على الأقل'),
  email: z.string().email('البريد الإلكتروني غير صالح'),
  phone: z.string().optional(),
  password: z.string().min(8, 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'),
  confirmPassword: z.string(),
  role: z.enum(['buyer', 'seller', 'agent']),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'كلمات المرور غير متطابقة',
  path: ['confirmPassword'],
});

// Property Schemas
export const propertySchema = z.object({
  title: z.string().min(5, 'العنوان يجب أن يكون 5 أحرف على الأقل'),
  description: z.string().min(20, 'الوصف يجب أن يكون 20 حرف على الأقل'),
  type: z.enum(['apartment', 'house', 'villa', 'land', 'commercial']),
  listingType: z.enum(['sale', 'rent_monthly', 'rent_yearly', 'rent_daily']),
  price: z.number().positive('السعر يجب أن يكون رقماً موجباً'),
  currency: z.string().default('SYP'),
  area: z.number().positive('المساحة يجب أن تكون رقماً موجباً'),
  bedrooms: z.number().int().min(0).optional(),
  bathrooms: z.number().int().min(0).optional(),
  floor: z.number().int().optional(),
  yearBuilt: z.number().int().min(1900).max(new Date().getFullYear()).optional(),
  governorate: z.string().min(2, 'المحافظة مطلوبة'),
  areaName: z.string().min(2, 'المنطقة مطلوبة'),
  address: z.string().min(5, 'العنوان يجب أن يكون 5 أحرف على الأقل'),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
});

// Review Schema
export const reviewSchema = z.object({
  propertyId: z.number().int().positive(),
  userId: z.number().int().positive(),
  rating: z.number().int().min(1).max(5),
  comment: z.string().min(10, 'التعليق يجب أن يكون 10 أحرف على الأقل'),
});

// Message Schema
export const messageSchema = z.object({
  conversationId: z.number().int().positive(),
  senderId: z.number().int().positive(),
  content: z.string().min(1, 'الرسالة لا يمكن أن تكون فارغة'),
});

// Deal Schema
export const dealSchema = z.object({
  propertyId: z.number().int().positive(),
  buyerId: z.number().int().positive(),
  sellerId: z.number().int().positive(),
  price: z.number().positive('السعر يجب أن يكون رقماً موجباً'),
  status: z.enum(['pending', 'in_progress', 'completed', 'cancelled']).optional(),
});

// Search Filters Schema
export const searchFiltersSchema = z.object({
  type: z.string().optional(),
  listingType: z.string().optional(),
  governorate: z.string().optional(),
  area: z.string().optional(),
  minPrice: z.number().positive().optional(),
  maxPrice: z.number().positive().optional(),
  minArea: z.number().positive().optional(),
  maxArea: z.number().positive().optional(),
  bedrooms: z.number().int().min(0).optional(),
  bathrooms: z.number().int().min(0).optional(),
  minYear: z.number().int().min(1900).optional(),
  maxYear: z.number().int().max(new Date().getFullYear()).optional(),
  page: z.number().int().positive().optional(),
  limit: z.number().int().positive().optional(),
  sortBy: z.string().optional(),
  sortOrder: z.enum(['asc', 'desc']).optional(),
});

// Types
export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type PropertyInput = z.infer<typeof propertySchema>;
export type ReviewInput = z.infer<typeof reviewSchema>;
export type MessageInput = z.infer<typeof messageSchema>;
export type DealInput = z.infer<typeof dealSchema>;
export type SearchFiltersInput = z.infer<typeof searchFiltersSchema>;
