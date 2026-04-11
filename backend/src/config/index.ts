import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('3000'),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),
  JWT_ACCESS_EXPIRATION: z.string().default('15m'),
  JWT_REFRESH_EXPIRATION: z.string().default('30d'),
  CORS_ORIGIN: z.string().default('*'),
  CLOUDFLARE_R2_ENDPOINT: z.string().optional(),
  CLOUDFLARE_R2_ACCESS_KEY: z.string().optional(),
  CLOUDFLARE_R2_SECRET_KEY: z.string().optional(),
  CLOUDFLARE_R2_BUCKET: z.string().optional(),
  GOOGLE_CLIENT_ID: z.string().optional(),
  GOOGLE_CLIENT_SECRET: z.string().optional(),
  GOOGLE_REDIRECT_URI: z.string().optional(),
  FIREBASE_PROJECT_ID: z.string().optional(),
  FIREBASE_PRIVATE_KEY: z.string().optional(),
  FIREBASE_CLIENT_EMAIL: z.string().optional(),
  RATE_LIMIT_WINDOW_MS: z.string().default('900000'),
  RATE_LIMIT_MAX_REQUESTS: z.string().default('100'),
  RATE_LIMIT_AUTH_WINDOW_MS: z.string().default('900000'),
  RATE_LIMIT_AUTH_MAX_REQUESTS: z.string().default('5'),
  LOG_LEVEL: z.string().default('info'),
  LOG_FILE: z.string().default('logs/app.log'),
});

const parsedEnv = envSchema.safeParse(process.env);

if (!parsedEnv.success) {
  console.error('❌ Invalid environment variables:', parsedEnv.error.format());
  process.exit(1);
}

export const config = {
  env: parsedEnv.data.NODE_ENV,
  port: parseInt(parsedEnv.data.PORT, 10),
  database: {
    url: parsedEnv.data.DATABASE_URL,
  },
  redis: {
    url: parsedEnv.data.REDIS_URL,
  },
  jwt: {
    secret: parsedEnv.data.JWT_SECRET,
    refreshSecret: parsedEnv.data.JWT_REFRESH_SECRET,
    accessExpiration: parsedEnv.data.JWT_ACCESS_EXPIRATION,
    refreshExpiration: parsedEnv.data.JWT_REFRESH_EXPIRATION,
  },
  cors: {
    origin: parsedEnv.data.CORS_ORIGIN.split(','),
  },
  cloudflare: {
    endpoint: parsedEnv.data.CLOUDFLARE_R2_ENDPOINT,
    accessKey: parsedEnv.data.CLOUDFLARE_R2_ACCESS_KEY,
    secretKey: parsedEnv.data.CLOUDFLARE_R2_SECRET_KEY,
    bucket: parsedEnv.data.CLOUDFLARE_R2_BUCKET,
  },
  google: {
    clientId: parsedEnv.data.GOOGLE_CLIENT_ID,
    clientSecret: parsedEnv.data.GOOGLE_CLIENT_SECRET,
    redirectUri: parsedEnv.data.GOOGLE_REDIRECT_URI,
  },
  firebase: {
    projectId: parsedEnv.data.FIREBASE_PROJECT_ID,
    privateKey: parsedEnv.data.FIREBASE_PRIVATE_KEY,
    clientEmail: parsedEnv.data.FIREBASE_CLIENT_EMAIL,
  },
  rateLimit: {
    windowMs: parseInt(parsedEnv.data.RATE_LIMIT_WINDOW_MS, 10),
    maxRequests: parseInt(parsedEnv.data.RATE_LIMIT_MAX_REQUESTS, 10),
    authWindowMs: parseInt(parsedEnv.data.RATE_LIMIT_AUTH_WINDOW_MS, 10),
    authMaxRequests: parseInt(parsedEnv.data.RATE_LIMIT_AUTH_MAX_REQUESTS, 10),
  },
  logging: {
    level: parsedEnv.data.LOG_LEVEL,
    file: parsedEnv.data.LOG_FILE,
  },
};
