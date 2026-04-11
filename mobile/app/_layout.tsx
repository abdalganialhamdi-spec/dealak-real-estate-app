import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="auto" />
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="property/[id]" options={{ title: 'تفاصيل العقار' }} />
        <Stack.Screen name="search" options={{ title: 'بحث' }} />
        <Stack.Screen name="login" options={{ title: 'تسجيل الدخول' }} />
        <Stack.Screen name="register" options={{ title: 'إنشاء حساب' }} />
      </Stack>
    </>
  );
}
