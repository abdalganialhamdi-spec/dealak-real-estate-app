import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { User, Settings, LogOut, HelpCircle, Shield } from 'lucide-react-native';

export default function ProfileScreen() {
  return (
    <SafeAreaView className="flex-1 bg-gray-50">
      <ScrollView className="flex-1">
        {/* Header */}
        <View className="bg-blue-600 p-6 pb-16">
          <View className="items-center">
            <View className="w-24 h-24 bg-white rounded-full mb-4" />
            <Text className="text-white text-xl font-bold">أحمد محمد</Text>
            <Text className="text-blue-100">ahmed@example.com</Text>
          </View>
        </View>

        {/* Stats */}
        <View className="bg-white mx-4 -mt-8 rounded-lg shadow-md p-4 mb-4">
          <View className="flex-row justify-around">
            <View className="text-center">
              <Text className="text-2xl font-bold text-blue-600">5</Text>
              <Text className="text-gray-600 text-sm">عقارات</Text>
            </View>
            <View className="text-center">
              <Text className="text-2xl font-bold text-blue-600">12</Text>
              <Text className="text-gray-600 text-sm">مفضلة</Text>
            </View>
            <View className="text-center">
              <Text className="text-2xl font-bold text-blue-600">3</Text>
              <Text className="text-gray-600 text-sm">صفقات</Text>
            </View>
          </View>
        </View>

        {/* Menu Items */}
        <View className="bg-white mx-4 rounded-lg shadow-md mb-4">
          <TouchableOpacity className="flex-row items-center p-4 border-b border-gray-100">
            <User size={24} color="#0ea5e9" />
            <Text className="flex-1 ml-3">الملف الشخصي</Text>
          </TouchableOpacity>
          <TouchableOpacity className="flex-row items-center p-4 border-b border-gray-100">
            <Settings size={24} color="#0ea5e9" />
            <Text className="flex-1 ml-3">الإعدادات</Text>
          </TouchableOpacity>
          <TouchableOpacity className="flex-row items-center p-4 border-b border-gray-100">
            <HelpCircle size={24} color="#0ea5e9" />
            <Text className="flex-1 ml-3">مركز المساعدة</Text>
          </TouchableOpacity>
          <TouchableOpacity className="flex-row items-center p-4">
            <Shield size={24} color="#0ea5e9" />
            <Text className="flex-1 ml-3">سياسة الخصوصية</Text>
          </TouchableOpacity>
        </View>

        {/* Logout Button */}
        <View className="mx-4 mb-4">
          <TouchableOpacity className="bg-red-500 rounded-lg p-4 flex-row items-center justify-center">
            <LogOut size={24} color="white" />
            <Text className="text-white font-bold ml-2">تسجيل الخروج</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
