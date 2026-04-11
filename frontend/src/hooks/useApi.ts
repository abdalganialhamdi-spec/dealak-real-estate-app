import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api';

// Types
export interface User {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  role: 'buyer' | 'seller' | 'agent' | 'admin';
  avatar?: string;
  createdAt: string;
}

export interface LoginResponse {
  user: User;
  token: string;
  refreshToken: string;
}

export interface Property {
  id: number;
  title: string;
  description: string;
  type: string;
  listingType: 'sale' | 'rent_monthly' | 'rent_yearly' | 'rent_daily';
  price: number;
  currency: string;
  area: number;
  bedrooms: number;
  bathrooms: number;
  floor?: number;
  yearBuilt?: number;
  governorate: string;
  areaName: string;
  address: string;
  latitude?: number;
  longitude?: number;
  ownerId: number;
  status: 'active' | 'pending' | 'sold' | 'rented';
  featured: boolean;
  views: number;
  createdAt: string;
  updatedAt: string;
  images?: PropertyImage[];
  features?: PropertyFeature[];
}

export interface PropertyImage {
  id: number;
  propertyId: number;
  imageUrl: string;
  isPrimary: boolean;
  order: number;
}

export interface PropertyFeature {
  id: number;
  propertyId: number;
  feature: string;
}

export interface PropertyFilters {
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
}

export interface Favorite {
  id: number;
  userId: number;
  propertyId: number;
  property?: Property;
  createdAt: string;
}

export interface Message {
  id: number;
  conversationId: number;
  senderId: number;
  content: string;
  read: boolean;
  createdAt: string;
}

export interface Deal {
  id: number;
  propertyId: number;
  buyerId: number;
  sellerId: number;
  price: number;
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled';
  createdAt: string;
  updatedAt: string;
}

export interface Review {
  id: number;
  propertyId: number;
  userId: number;
  rating: number;
  comment: string;
  createdAt: string;
}

export interface Notification {
  id: number;
  userId: number;
  type: string;
  title: string;
  message: string;
  read: boolean;
  createdAt: string;
}

// Auth Hooks
export function useLogin() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ email, password }: { email: string; password: string }) =>
      apiClient.login(email, password),
    onSuccess: (data) => {
      // Store token and user in localStorage
      if (typeof window !== 'undefined') {
        localStorage.setItem('token', data.data.token);
        localStorage.setItem('user', JSON.stringify(data.data.user));
      }
      // Invalidate queries
      queryClient.invalidateQueries({ queryKey: ['user'] });
    },
  });
}

export function useRegister() {
  return useMutation({
    mutationFn: (data: {
      firstName: string;
      lastName: string;
      email: string;
      phone?: string;
      password: string;
      role?: 'buyer' | 'seller' | 'agent';
    }) => apiClient.register(data),
  });
}

export function useLogout() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => apiClient.logout(),
    onSuccess: () => {
      // Clear localStorage
      if (typeof window !== 'undefined') {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
      }
      // Invalidate queries
      queryClient.clear();
    },
  });
}

// Property Hooks
export function useProperties(filters?: PropertyFilters) {
  return useQuery({
    queryKey: ['properties', filters],
    queryFn: () => apiClient.getProperties(filters),
  });
}

export function useProperty(id: number) {
  return useQuery({
    queryKey: ['property', id],
    queryFn: () => apiClient.getProperty(id),
    enabled: !!id,
  });
}

export function useCreateProperty() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: any) => apiClient.createProperty(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['properties'] });
    },
  });
}

export function useUpdateProperty() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) =>
      apiClient.updateProperty(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['properties'] });
    },
  });
}

export function useDeleteProperty() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => apiClient.deleteProperty(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['properties'] });
    },
  });
}

// User Hooks
export function useUser(id: number) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => apiClient.getUser(id),
    enabled: !!id,
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) =>
      apiClient.updateUser(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['user'] });
    },
  });
}

// Favorite Hooks
export function useFavorites(userId: number) {
  return useQuery({
    queryKey: ['favorites', userId],
    queryFn: () => apiClient.getFavorites(userId),
    enabled: !!userId,
  });
}

export function useAddFavorite() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: { userId: number; propertyId: number }) =>
      apiClient.addFavorite(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['favorites'] });
    },
  });
}

export function useRemoveFavorite() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ userId, propertyId }: { userId: number; propertyId: number }) =>
      apiClient.removeFavorite(userId, propertyId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['favorites'] });
    },
  });
}

// Message Hooks
export function useMessages(conversationId: number) {
  return useQuery({
    queryKey: ['messages', conversationId],
    queryFn: () => apiClient.getMessages(conversationId),
    enabled: !!conversationId,
  });
}

export function useSendMessage() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: {
      conversationId: number;
      senderId: number;
      content: string;
    }) => apiClient.sendMessage(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['messages'] });
    },
  });
}

// Deal Hooks
export function useDeals(userId?: number) {
  return useQuery({
    queryKey: ['deals', userId],
    queryFn: () => apiClient.getDeals(userId),
  });
}

export function useCreateDeal() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: {
      propertyId: number;
      buyerId: number;
      sellerId: number;
      price: number;
      status?: string;
    }) => apiClient.createDeal(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['deals'] });
    },
  });
}

export function useUpdateDeal() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) =>
      apiClient.updateDeal(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['deals'] });
    },
  });
}

// Review Hooks
export function useReviews(propertyId?: number) {
  return useQuery({
    queryKey: ['reviews', propertyId],
    queryFn: () => apiClient.getReviews(propertyId),
  });
}

export function useCreateReview() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: {
      propertyId: number;
      userId: number;
      rating: number;
      comment: string;
    }) => apiClient.createReview(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['reviews'] });
    },
  });
}

// Notification Hooks
export function useNotifications(userId: number) {
  return useQuery({
    queryKey: ['notifications', userId],
    queryFn: () => apiClient.getNotifications(userId),
    enabled: !!userId,
  });
}

export function useMarkNotificationAsRead() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => apiClient.markNotificationAsRead(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
  });
}

// Health Check Hook
export function useHealthCheck() {
  return useQuery({
    queryKey: ['health'],
    queryFn: () => apiClient.healthCheck(),
    refetchInterval: 30000, // Check every 30 seconds
  });
}
