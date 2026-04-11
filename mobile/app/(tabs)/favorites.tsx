import { View, Text, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Heart } from 'lucide-react-native';

export default function FavoritesScreen() {
  return (
    <SafeAreaView className="flex-1 bg-gray-50">
      <ScrollView className="flex-1 p-4">
        <Text className="text-2xl font-bold mb-4">المفضلة</Text>
        
        <View className="items-center justify-center py-20">
          <Heart size={64} color="#d1d5db" />
          <Text className="text-gray-500 mt-4 text-center">
            لا توجد عقارات في المفضلة
          </Text>
          <Text className="text-gray-400 mt-2 text-center">
            أضف عقارات إلى المفضلة للعودة إليها لاحقاً
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
