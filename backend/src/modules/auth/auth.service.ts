import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { AppError, ConflictError, UnauthorizedError, NotFoundError } from '../../shared/errors/AppError';
import { config } from '../../config';

const prisma = new PrismaClient();

export class AuthService {
  async register(data: any) {
    const { email, password, firstName, lastName, role, phone } = data;

    // Check if user exists
    const existingUser = await prisma.users.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictError('User with this email already exists');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);

    // Create user
    const user = await prisma.users.create({
      data: {
        email,
        passwordHash,
        firstName,
        lastName,
        role: role || 'buyer',
        phone,
      },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        avatarUrl: true,
        isVerified: true,
        createdAt: true,
      },
    });

    // Generate tokens
    const { accessToken, refreshToken } = await this.generateTokens(user.id);

    return {
      user,
      accessToken,
      refreshToken,
    };
  }

  async login(data: any) {
    const { email, password } = data;

    // Find user
    const user = await prisma.users.findUnique({
      where: { email },
    });

    if (!user) {
      throw new UnauthorizedError('Invalid credentials');
    }

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.passwordHash);

    if (!isValidPassword) {
      throw new UnauthorizedError('Invalid credentials');
    }

    // Check if user is active
    if (!user.isActive) {
      throw new UnauthorizedError('Account is deactivated');
    }

    // Update last login
    await prisma.users.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    // Generate tokens
    const { accessToken, refreshToken } = await this.generateTokens(user.id);

    return {
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        avatarUrl: user.avatarUrl,
        isVerified: user.isVerified,
      },
      accessToken,
      refreshToken,
    };
  }

  async logout(userId: bigint) {
    // Revoke all refresh tokens for this user
    await prisma.refreshTokens.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async refreshToken(refreshToken: string) {
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, config.jwt.refreshSecret) as { userId: bigint };

    // Check if token exists and is not revoked
    const tokenRecord = await prisma.refreshTokens.findUnique({
      where: { token: refreshToken },
    });

    if (!tokenRecord || tokenRecord.revokedAt) {
      throw new UnauthorizedError('Invalid refresh token');
    }

    // Generate new tokens
    const { accessToken, refreshToken: newRefreshToken } = await this.generateTokens(decoded.userId);

    // Revoke old token
    await prisma.refreshTokens.update({
      where: { id: tokenRecord.id },
      data: { revokedAt: new Date() },
    });

    return { accessToken, refreshToken: newRefreshToken };
  }

  async forgotPassword(email: string) {
    const user = await prisma.users.findUnique({
      where: { email },
    });

    if (!user) {
      // Don't reveal if user exists
      return;
    }

    // Generate reset token
    const resetToken = jwt.sign(
      { userId: user.id },
      config.jwt.secret,
      { expiresIn: '1h' }
    );

    // TODO: Send email with reset token
    console.log(`Password reset token for ${email}: ${resetToken}`);
  }

  async resetPassword(token: string, newPassword: string) {
    const decoded = jwt.verify(token, config.jwt.secret) as { userId: bigint };

    const passwordHash = await bcrypt.hash(newPassword, 12);

    await prisma.users.update({
      where: { id: decoded.userId },
      data: { passwordHash },
    });
  }

  async getGoogleAuthUrl() {
    // TODO: Implement Google OAuth
    return 'https://accounts.google.com/o/oauth2/v2/auth';
  }

  async handleGoogleCallback(code: string) {
    // TODO: Implement Google OAuth callback
    return { accessToken: 'mock-token' };
  }

  private async generateTokens(userId: bigint) {
    const accessToken = jwt.sign(
      { userId },
      config.jwt.secret,
      { expiresIn: config.jwt.accessExpiration }
    );

    const refreshToken = jwt.sign(
      { userId },
      config.jwt.refreshSecret,
      { expiresIn: config.jwt.refreshExpiration }
    );

    // Store refresh token in database
    const hashedToken = await bcrypt.hash(refreshToken, 12);
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days

    await prisma.refreshTokens.create({
      data: {
        tokenHash: hashedToken,
        userId,
        expiresAt,
      },
    });

    return { accessToken, refreshToken };
  }
}
