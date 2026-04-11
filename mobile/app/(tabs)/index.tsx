import { View, Text, ScrollView, Image, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Search, MapPin, Home, Bed, Bath, Maximize } from 'lucide-react-native';

export default function HomeScreen() {
  const featuredProperties = [
    { id: 1, title: 'شقة فاخرة في دمشق', price: '150,000,000', location: 'الملكي، دمشق', beds: 3, baths: 2, area: 120 },
    { id: 2, title: 'فيلا في حلب', price: '500,000,000', location: 'جبل الحصن، حلب', beds: 5, baths: 4, area: 400 },
    { id: 3, title: 'شقة في حمص', price: '80,000,000', location: 'الإنشاءات، حمص', beds: 2, baths: 1, area: 90 },
  ];

  return (
    <SafeAreaView className="flex-1 bg-gray-50">
      <ScrollView className="flex-1">
        {/* Header */}
        <View className="bg-white p-4 shadow-sm">
          <Text className="text-2xl font-bold text-blue-600 mb-1">DEALAK</Text>
          <Text className="text-gray-600">ابحث عن عقارك المثالي</Text>
        </View>

        {/* Search Bar */}
        <View className="p-4">
          <View className="bg-white rounded-lg shadow-md flex-row items-center p-3">
            <Search size={20} color="#9ca3af" />
            <Text className="flex-1 ml-3 text-gray-500">ابحث عن عقار...</Text>
          </View>
        </View>

        {/* Categories */}
        <View className="px-4 mb-4">
          <Text className="text-lg font-bold mb-3">التصنيفات</Text>
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            {['شقق', 'منازل', 'فلل', 'أراضي', 'تجاري'].map((category) => (
              <TouchableOpacity key={category} className="bg-white rounded-lg px-4 py-2 mr-2 shadow-sm">
                <Text className="text-gray-700">{category}</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>

        {/* Featured Properties */}
        <View className="px-4 mb-4">
          <View className="flex-row justify-between items-center mb-3">
            <Text className="text-lg font-bold">عقارات مميزة</Text>
            <Text className="text-blue-600">عرض الكل</Text>
          </View>
          
          {featuredProperties.map((property) => (
            <View key={property.id} className="bg-white rounded-lg shadow-md mb-4 overflow-hidden">
              <View className="h-40 bg-gray-200" />
              <View className="p-4">
                <Text className="font-bold text-lg mb-1">{property.title}</Text>
                <View className="flex-row items-center mb-2">
                  <MapPin size={16} color="#6b7280" />
                  <Text className="text-gray-600 text-sm ml-1">{property.location}</Text>
                </View>
                <View className="flex-row gap-4 mb-3">
                  <View className="flex-row items-center">
                    <Bed size={16} color="#6b7280" />
                    <Text className="text-gray-600 text-sm ml-1">{property.beds}</Text>
                  </View>
                  <View className="flex-row items-center">
                    <Bath size={16} color="#6b7280" />
                    <Text className="text-gray-600 text-sm ml-1">{property.baths}</Text>
                  </View>
                  <View className="flex-row items-center">
                    <Maximize size={16} color="#6b7280" />
                    <Text className="text-gray-600 text-sm ml-1">{property.area} م²</Text>
                  </View>
                </View>
                <Text className="text-xl font-bold text-blue-600">{property.price} ل.س</Text>
              </View>
            </View>
          ))}
        </View>

        {/* Stats */}
        <View className="bg-blue-600 p-6 mx-4 rounded-lg mb-4">
          <View className="grid grid-cols-2 gap-4">
            <View className="text-center">
              <Text className="text-3xl font-bold text-white mb-1">1000+</Text>
              <Text className="text-blue-100">عقار متاح</Text>
            </View>
            <View className="text-center">
              <Text className="text-3xl font-bold text-white mb-1">500+</Text>
              <Text className="text-blue-100">عميل سعيد</Text>
            </View>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
