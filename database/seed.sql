-- Seed data for DEALAK database

-- Insert admin user
INSERT INTO users (email, password_hash, first_name, last_name, phone, role, is_verified, is_active)
VALUES ('admin@dealak.com', '$2b$10$placeholder_hash', 'Admin', 'User', '+963958794195', 'admin', 1, 1);

-- Insert test users
INSERT INTO users (email, password_hash, first_name, last_name, phone, role, is_verified, is_active)
VALUES 
  ('buyer@example.com', '$2b$10$placeholder_hash', 'أحمد', 'محمد', '+963912345678', 'buyer', 1, 1),
  ('seller@example.com', '$2b$10$placeholder_hash', 'فاطمة', 'علي', '+963923456789', 'seller', 1, 1),
  ('agent@example.com', '$2b$10$placeholder_hash', 'خالد', 'أحمد', '+963934567890', 'agent', 1, 1);

-- Insert sample properties
INSERT INTO properties (seller_id, title, description, type, listing_type, price, area, governorate, district, rooms, bathrooms, status, is_featured)
VALUES 
  (3, 'شقة فاخرة في دمشق', 'شقة فاخرة في حي الملكي بدمشق، تتكون من 3 غرف نوم وصالة واسعة، مطبخ مجهز بالكامل، شرفة مطلة على الحديقة', 'apartment', 'sale', 150000000, 120, 'دمشق', 'الملكي', 3, 2, 'available', 1),
  (3, 'فيلا في حلب', 'فيلا فاخرة في حلب، 5 غرف نوم، حديقة خاصة، مواقف سيارات', 'villa', 'sale', 500000000, 400, 'حلب', 'جبل الحصن', 5, 4, 'available', 1),
  (3, 'شقة في حمص', 'شقة عصرية في حمص، 2 غرف نوم، موقع ممتاز', 'apartment', 'sale', 80000000, 90, 'حمص', 'الإنشاءات', 2, 1, 'available', 0),
  (3, 'أرض تجارية في حماة', 'أرض تجارية في موقع استراتيجي، مناسبة للمشاريع', 'land', 'sale', 200000000, 500, 'حماة', 'المركز', 0, 0, 'available', 0),
  (3, 'شقة للإيجار في اللاذقية', 'شقة مطلة على البحر، إيجار سنوي', 'apartment', 'rent_yearly', 12000000, 85, 'اللاذقية', 'المركز', 2, 1, 'available', 0),
  (3, 'منزل في طرطوس', 'منزل عائلي مع حديقة، موقع هادئ', 'house', 'sale', 180000000, 250, 'طرطوس', 'المركز', 4, 2, 'available', 0);

-- Insert property images
INSERT INTO property_images (property_id, image_url, alt_text, order_index)
VALUES 
  (1, 'https://example.com/images/property1-1.jpg', 'صورة الشقة - الواجهة', 0),
  (1, 'https://example.com/images/property1-2.jpg', 'صورة الشقة - الصالة', 1),
  (1, 'https://example.com/images/property1-3.jpg', 'صورة الشقة - المطبخ', 2),
  (2, 'https://example.com/images/property2-1.jpg', 'صورة الفيلا - الواجهة', 0),
  (2, 'https://example.com/images/property2-2.jpg', 'صورة الفيلا - الحديقة', 1);

-- Insert property features
INSERT INTO property_features (property_id, feature_name, feature_value)
VALUES 
  (1, 'parking', 'نعم'),
  (1, 'security', '24 ساعة'),
  (1, 'balcony', 'نعم'),
  (1, 'kitchen', 'مجهز بالكامل'),
  (1, 'ac', 'مركزي'),
  (2, 'parking', 'نعم'),
  (2, 'garden', 'نعم'),
  (2, 'security', '24 ساعة'),
  (2, 'pool', 'نعم');

-- Insert system settings
INSERT INTO system_settings (key, value, description)
VALUES 
  ('site_name', 'DEALAK', 'اسم الموقع'),
  ('site_description', 'منصة العقارات الأولى في سوريا', 'وصف الموقع'),
  ('contact_email', 'info@dealak.com', 'البريد الإلكتروني للتواصل'),
  ('contact_phone', '+963958794195', 'رقم الهاتف للتواصل'),
  ('currency', 'SYP', 'العملة الافتراضية'),
  ('commission_rate', '2', 'نسبة العمولة (%)');
