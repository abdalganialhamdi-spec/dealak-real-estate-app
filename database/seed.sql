-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  DEALAK Real Estate Platform — Seed Data                               ║
-- ║  Version:  1.0.0                                                       ║
-- ║  Date:     11 April 2026                                               ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ──────────────────────────────────────────────────────────────────────────
-- System Settings
-- ──────────────────────────────────────────────────────────────────────────
INSERT INTO system_settings (key, value, value_type) VALUES
  ('app_name', 'DEALAK', 'STRING'),
  ('app_version', '1.0.0', 'STRING'),
  ('default_currency', 'SYP', 'STRING'),
  ('max_property_images', '10', 'INTEGER'),
  ('max_message_length', '5000', 'INTEGER'),
  ('maintenance_mode', 'false', 'BOOLEAN');

-- ──────────────────────────────────────────────────────────────────────────
-- Users (Test Accounts)
-- ──────────────────────────────────────────────────────────────────────────
-- Password: admin123 (hashed with bcrypt)
INSERT INTO users (email, phone, password_hash, first_name, last_name, role, is_verified, is_active) VALUES
  ('admin@dealak.com', '+963900000001', '$2a$10$YourHashedPasswordHere', 'Admin', 'User', 'ADMIN', 1, 1),
  ('buyer@example.com', '+963900000002', '$2a$10$YourHashedPasswordHere', 'Ahmed', 'Ali', 'BUYER', 1, 1),
  ('seller@example.com', '+963900000003', '$2a$10$YourHashedPasswordHere', 'Mohammed', 'Hassan', 'SELLER', 1, 1),
  ('agent@example.com', '+963900000004', '$2a$10$YourHashedPasswordHere', 'Omar', 'Khalil', 'AGENT', 1, 1);

-- ──────────────────────────────────────────────────────────────────────────
-- Sample Properties
-- ──────────────────────────────────────────────────────────────────────────
INSERT INTO properties (owner_id, title, slug, description, property_type, status, listing_type, price, currency, area_sqm, bedrooms, bathrooms, city, district, is_featured, is_negotiable) VALUES
  (3, 'شقة فاخرة في حماة', 'luxury-apartment-hama-1', 'شقة فاخرة في حماة مع إطلالة رائعة، 3 غرف نوم، حمامين، مطبخ مجهز بالكامل', 'APARTMENT', 'AVAILABLE', 'SALE', 150000000, 'SYP', 120, 3, 2, 'حماة', 'المدينة', 1, 1),
  (3, 'فيلا في حلب', 'villa-aleppo-1', 'فيلا فاخرة في حلب مع حديقة خاصة، 4 غرف نوم، 3 حمام، موقف سيارات', 'VILLA', 'AVAILABLE', 'SALE', 300000000, 'SYP', 250, 4, 3, 'حلب', 'الشعباني', 1, 1),
  (3, 'شقة للإيجار في دمشق', 'apartment-damascus-rent-1', 'شقة للإيجار في دمشق، 2 غرف نوم، حمام، مطبخ، إطلالة على الحديقة', 'APARTMENT', 'AVAILABLE', 'RENT_MONTHLY', 500000, 'SYP', 80, 2, 1, 'دمشق', 'المزة', 0, 1),
  (3, 'أرض للبيع في اللاذقية', 'land-latakia-1', 'أرض للبيع في اللاذقية، مساحة 500 متر مربع، مناسبة للبناء', 'LAND', 'AVAILABLE', 'SALE', 100000000, 'SYP', 500, NULL, NULL, 'اللاذقية', 'المركز', 0, 1),
  (3, 'مكتب تجاري في حمص', 'office-homs-1', 'مكتب تجاري في حمص، مساحة 60 متر مربع، مناسب للمكاتب والشركات', 'OFFICE', 'AVAILABLE', 'RENT_MONTHLY', 300000, 'SYP', 60, NULL, NULL, 'حمص', 'الإنشائي', 0, 1);

-- ──────────────────────────────────────────────────────────────────────────
-- Sample Property Images
-- ──────────────────────────────────────────────────────────────────────────
INSERT INTO property_images (property_id, image_url, thumbnail_url, caption, is_primary, sort_order) VALUES
  (1, 'https://example.com/images/property1-1.jpg', 'https://example.com/images/property1-1-thumb.jpg', 'الواجهة الرئيسية', 1, 0),
  (1, 'https://example.com/images/property1-2.jpg', 'https://example.com/images/property1-2-thumb.jpg', 'غرفة المعيشة', 0, 1),
  (1, 'https://example.com/images/property1-3.jpg', 'https://example.com/images/property1-3-thumb.jpg', 'المطبخ', 0, 2),
  (2, 'https://example.com/images/property2-1.jpg', 'https://example.com/images/property2-1-thumb.jpg', 'الواجهة الرئيسية', 1, 0),
  (2, 'https://example.com/images/property2-2.jpg', 'https://example.com/images/property2-2-thumb.jpg', 'الحديقة', 0, 1);

-- ──────────────────────────────────────────────────────────────────────────
-- Sample Property Features
-- ──────────────────────────────────────────────────────────────────────────
INSERT INTO property_features (property_id, feature_key, feature_value) VALUES
  (1, 'parking', 'true'),
  (1, 'elevator', 'true'),
  (1, 'balcony', 'true'),
  (1, 'air_conditioning', 'true'),
  (1, 'furnished', 'false'),
  (2, 'parking', 'true'),
  (2, 'garden', 'true'),
  (2, 'security', 'true'),
  (2, 'elevator', 'false'),
  (3, 'parking', 'false'),
  (3, 'elevator', 'true'),
  (3, 'balcony', 'true'),
  (3, 'air_conditioning', 'true');

-- ──────────────────────────────────────────────────────────────────────────
-- Sample Reviews
-- ──────────────────────────────────────────────────────────────────────────
INSERT INTO reviews (user_id, property_id, rating, comment) VALUES
  (2, 1, 5, 'شقة ممتازة، الموقع رائع والخدمات جيدة'),
  (2, 2, 4, 'فيلا جميلة لكن تحتاج بعض التحسينات');

-- ──────────────────────────────────────────────────────────────────────────
-- Sample Discounts
-- ──────────────────────────────────────────────────────────────────────────
INSERT INTO discounts (property_id, code, discount_type, discount_value, currency, valid_from, valid_until, is_active, created_by) VALUES
  (1, 'WELCOME10', 'PERCENTAGE', 10, 'SYP', '2026-04-11', '2026-12-31', 1, 1),
  (2, 'SPRING20', 'PERCENTAGE', 20, 'SYP', '2026-04-11', '2026-06-30', 1, 1);
