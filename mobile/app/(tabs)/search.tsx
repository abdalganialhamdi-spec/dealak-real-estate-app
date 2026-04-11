import { View, Text, ScrollView, TextInput, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Search, Filter, SlidersHorizontal } from 'lucide-react-native';

export default function SearchScreen() {
  return (
    <SafeAreaView className="flex-1 bg-gray-50">
      <ScrollView className="flex-1 p-4">
        <Text className="text-2xl font-bold mb-4">بحث متقدم</Text>
        
        {/* Search Input */}
        <View className="bg-white rounded-lg shadow-md flex-row items-center p-3 mb-4">
          <Search size={20} color="#9ca3af" />
          <TextInput 
            className="flex-1 ml-3 text-gray-700"
            placeholder="ابحث عن عقار..."
            placeholderTextColor="#9ca3af"
          />
          <TouchableOpacity>
            <Filter size={20} color="#0ea5e9" />
          </TouchableOpacity>
        </View>

        {/* Filters */}
        <View className="space-y-4">
          <View>
            <Text className="font-bold mb-2">نوع العقار</Text>
            <View className="bg-white rounded-lg shadow-md p-3">
              <Text className="text-gray-700">كل الأنواع</Text>
            </View>
          </View>

          <View>
            <Text className="font-bold mb-2">نوع الإعلان</Text>
            <View className="bg-white rounded-lg shadow-md p-3">
              <Text className="text-gray-700">كل الإعلانات</Text>
            </View>
          </View>

          <View>
            <Text className="font-bold mb-2">المحافظة</Text>
            <View className="bg-white rounded-lg shadow-md p-3">
              <Text className="text-gray-700">كل المحافظات</Text>
            </View>
          </View>

          <View className="flex-row gap-4">
            <View className="flex-1">
              <Text className="font-bold mb-2">السعر من</Text>
              <View className="bg-white rounded-lg shadow-md p-3">
                <TextInput 
                  className="text-gray-700"
                  placeholder="0"
                  keyboardType="numeric"
                />
              </View>
            </View>
            <View className="flex-1">
              <Text className="font-bold mb-2">السعر إلى</Text>
              <View className="bg-white rounded-lg shadow-md p-3">
                <TextInput 
                  className="text-gray-700"
                  placeholder="∞"
                  keyboardType="numeric"
                />
              </View>
            </View>
          </View>

          <View className="flex-row gap-4">
            <View className="flex-1">
              <Text className="font-bold mb-2">غرف نوم</Text>
              <View className="bg-white rounded-lg shadow-md p-3">
                <Text className="text-gray-700">الكل</Text>
              </View>
            </View>
            <View className="flex-1">
              <Text className="font-bold mb-2">حمام</Text>
              <View className="bg-white rounded-lg shadow-md p-3">
                <Text className="text-gray-700">الكل</Text>
              </View>
            </View>
          </View>
        </View>

        {/* Action Buttons */}
        <View className="mt-6 space-y-3">
          <TouchableOpacity className="bg-blue-600 rounded-lg p-4">
            <Text className="text-white text-center font-bold">بحث</Text>
          </TouchableOpacity>
          <TouchableOpacity className="border border-gray-300 rounded-lg p-4">
            <Text className="text-gray-700 text-center">إعادة تعيين</Text>
          </TouchableOpacity>
          <TouchableOpacity className="border border-blue-600 rounded-lg p-4">
            <Text className="text-blue-600 text-center">حفظ البحث</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
