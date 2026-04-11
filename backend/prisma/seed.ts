import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting seed...');

  // Create admin user
  const adminPassword = await bcrypt.hash('admin123', 12);
  const admin = await prisma.users.upsert({
    where: { email: 'admin@dealak.com' },
    update: {},
    create: {
      email: 'admin@dealak.com',
      passwordHash: adminPassword,
      firstName: 'Admin',
      lastName: 'User',
      role: 'ADMIN',
      isVerified: true,
      isActive: true,
    },
  });

  console.log('✅ Admin user created:', admin.email);

  // Create test users
  const testPassword = await bcrypt.hash('password123', 12);

  const buyer = await prisma.users.upsert({
    where: { email: 'buyer@example.com' },
    update: {},
    create: {
      email: 'buyer@example.com',
      passwordHash: testPassword,
      firstName: 'John',
      lastName: 'Doe',
      role: 'BUYER',
      isVerified: true,
      isActive: true,
    },
  });

  console.log('✅ Buyer user created:', buyer.email);

  const seller = await prisma.users.upsert({
    where: { email: 'seller@example.com' },
    update: {},
    create: {
      email: 'seller@example.com',
      passwordHash: testPassword,
      firstName: 'Jane',
      lastName: 'Smith',
      role: 'SELLER',
      isVerified: true,
      isActive: true,
    },
  });

  console.log('✅ Seller user created:', seller.email);

  const agent = await prisma.users.upsert({
    where: { email: 'agent@example.com' },
    update: {},
    create: {
      email: 'agent@example.com',
      passwordHash: testPassword,
      firstName: 'Ahmad',
      lastName: 'Hassan',
      role: 'AGENT',
      isVerified: true,
      isActive: true,
    },
  });

  console.log('✅ Agent user created:', agent.email);

  // Create sample properties
  const property1 = await prisma.properties.create({
    data: {
      ownerId: seller.id,
      title: 'Modern Apartment in Damascus',
      slug: 'modern-apartment-damascus',
      description: 'Beautiful 3-bedroom apartment with stunning city views',
      propertyType: 'APARTMENT',
      status: 'AVAILABLE',
      listingType: 'SALE',
      price: 150000000,
      currency: 'SYP',
      areaSqm: 120,
      bedrooms: 3,
      bathrooms: 2,
      floors: 5,
      yearBuilt: 2020,
      address: 'Malki Street, Damascus',
      city: 'Damascus',
      district: 'Malki',
      latitude: 33.5138,
      longitude: 36.2765,
      isFeatured: true,
    },
  });

  console.log('✅ Property created:', property1.title);

  const property2 = await prisma.properties.create({
    data: {
      ownerId: seller.id,
      agentId: agent.id,
      title: 'Luxury Villa in Aleppo',
      slug: 'luxury-villa-aleppo',
      description: 'Spacious 5-bedroom villa with private garden and pool',
      propertyType: 'VILLA',
      status: 'AVAILABLE',
      listingType: 'SALE',
      price: 500000000,
      currency: 'SYP',
      areaSqm: 400,
      bedrooms: 5,
      bathrooms: 4,
      floors: 2,
      yearBuilt: 2018,
      address: 'New Aleppo District',
      city: 'Aleppo',
      district: 'New Aleppo',
      latitude: 36.2012,
      longitude: 37.1342,
      isFeatured: true,
    },
  });

  console.log('✅ Property created:', property2.title);

  // Create property images
  await prisma.propertyImages.create({
    data: {
      propertyId: property1.id,
      imageUrl: 'https://example.com/images/property1-1.jpg',
      isPrimary: true,
      sortOrder: 0,
    },
  });

  await prisma.propertyImages.create({
    data: {
      propertyId: property1.id,
      imageUrl: 'https://example.com/images/property1-2.jpg',
      isPrimary: false,
      sortOrder: 1,
    },
  });

  console.log('✅ Property images created');

  // Create system settings
  await prisma.systemSetting.createMany({
    data: [
      { key: 'site_name', value: 'DEALAK', valueType: 'STRING' },
      { key: 'site_description', value: 'Real Estate Platform in Syria', valueType: 'STRING' },
      { key: 'contact_email', value: 'contact@dealak.com', valueType: 'STRING' },
      { key: 'contact_phone', value: '+963958794195', valueType: 'STRING' },
      { key: 'maintenance_mode', value: 'false', valueType: 'BOOLEAN' },
    ],
    skipDuplicates: true,
  });

  console.log('✅ System settings created');

  console.log('🎉 Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
