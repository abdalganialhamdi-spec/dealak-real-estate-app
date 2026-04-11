import axios, { AxiosError, AxiosInstance } from 'axios';

// API Configuration
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://dealak-backend.abdalgani-otp.workers.dev';

// Create axios instance
const api: AxiosInstance = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000, // 30 seconds timeout
});

// Request interceptor - Add auth token
api.interceptors.request.use(
  (config) => {
    const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - Handle errors
api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    // Handle 401 Unauthorized
    if (error.response?.status === 401) {
      if (typeof window !== 'undefined') {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        window.location.href = '/login';
      }
    }

    // Handle 403 Forbidden
    if (error.response?.status === 403) {
      console.error('Access forbidden');
    }

    // Handle 404 Not Found
    if (error.response?.status === 404) {
      console.error('Resource not found');
    }

    // Handle 500 Server Error
    if (error.response?.status === 500) {
      console.error('Server error');
    }

    return Promise.reject(error);
  }
);

// API Methods
export const apiClient = {
  // Auth
  login: (email: string, password: string) =>
    api.post('/api/auth/login', { email, password }),

  register: (data: {
    firstName: string;
    lastName: string;
    email: string;
    phone?: string;
    password: string;
    role?: 'buyer' | 'seller' | 'agent';
  }) => api.post('/api/auth/register', data),

  logout: () => api.post('/api/auth/logout'),

  refreshToken: (refreshToken: string) =>
    api.post('/api/auth/refresh', { refreshToken }),

  // Properties
  getProperties: (params?: {
    type?: string;
    listingType?: string;
    governorate?: string;
    area?: string;
    minPrice?: number;
    maxPrice?: number;
    minArea?: number;
    maxArea?: number;
    bedrooms?: number;
    bathrooms?: number;
    minYear?: number;
    maxYear?: number;
    page?: number;
    limit?: number;
    sortBy?: string;
    sortOrder?: 'asc' | 'desc';
  }) => api.get('/api/properties', { params }),

  getProperty: (id: number) => api.get(`/api/properties/${id}`),

  createProperty: (data: any) => api.post('/api/properties', data),

  updateProperty: (id: number, data: any) =>
    api.put(`/api/properties/${id}`, data),

  deleteProperty: (id: number) => api.delete(`/api/properties/${id}`),

  // Users
  getUser: (id: number) => api.get(`/api/users/${id}`),

  updateUser: (id: number, data: any) =>
    api.put(`/api/users/${id}`, data),

  deleteUser: (id: number) => api.delete(`/api/users/${id}`),

  // Favorites
  getFavorites: (userId: number) =>
    api.get(`/api/favorites?userId=${userId}`),

  addFavorite: (data: { userId: number; propertyId: number }) =>
    api.post('/api/favorites', data),

  removeFavorite: (userId: number, propertyId: number) =>
    api.delete(`/api/favorites?userId=${userId}&propertyId=${propertyId}`),

  // Messages
  getMessages: (conversationId: number) =>
    api.get(`/api/messages?conversationId=${conversationId}`),

  sendMessage: (data: {
    conversationId: number;
    senderId: number;
    content: string;
  }) => api.post('/api/messages', data),

  // Deals
  getDeals: (userId?: number) =>
    api.get(`/api/deals${userId ? `?userId=${userId}` : ''}`),

  createDeal: (data: {
    propertyId: number;
    buyerId: number;
    sellerId: number;
    price: number;
    status?: string;
  }) => api.post('/api/deals', data),

  updateDeal: (id: number, data: any) =>
    api.put(`/api/deals/${id}`, data),

  // Reviews
  getReviews: (propertyId?: number) =>
    api.get(`/api/reviews${propertyId ? `?propertyId=${propertyId}` : ''}`),

  createReview: (data: {
    propertyId: number;
    userId: number;
    rating: number;
    comment: string;
  }) => api.post('/api/reviews', data),

  // Notifications
  getNotifications: (userId: number) =>
    api.get(`/api/notifications?userId=${userId}`),

  markNotificationAsRead: (id: number) =>
    api.put(`/api/notifications/${id}`, { read: true }),

  // Health Check
  healthCheck: () => api.get('/'),
};

export default api;
