import { ApiClient } from './ApiClient';
import { UserService, UserInfo } from './UserService';

/**
 * 发送验证码请求
 */
export interface SendCodeRequest {
  phoneNumber: string;
}

/**
 * 发送验证码响应
 */
export interface SendCodeResponse {
  success: boolean;
  message: string;
  expiresIn: number;
}

/**
 * 登录请求
 */
export interface LoginRequest {
  phoneNumber: string;
  verificationCode: string;
}

/**
 * 微信登录请求
 */
export interface WeChatLoginRequest {
  code: string;
}

/**
 * 用户信息
 */
export interface UserProfile {
  id: string;
  phoneNumber?: string;
  nickname?: string;
  avatar?: string;
  isPro: boolean;
  membershipType: string;
  membershipExpiry?: string;
  createdAt: string;
}

/**
 * 登录响应
 */
export interface LoginResponse {
  token: string;
  refreshToken: string;
  user: UserProfile;
  isNewUser: boolean;
  expiresIn: number;
}

/**
 * 成功响应
 */
export interface SuccessResponse {
  success: boolean;
  message: string;
}

/**
 * 认证服务
 */
export class AuthService {
  private static instance: AuthService;
  private apiClient: ApiClient = ApiClient.getInstance();
  private userService: UserService = UserService.getInstance();

  private constructor() {}

  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  /**
   * 发送验证码
   */
  async sendCode(phoneNumber: string): Promise<SendCodeResponse> {
    return this.apiClient.post<SendCodeResponse>(
      '/auth/send-code',
      { phoneNumber },
      false // 不需要认证
    );
  }

  /**
   * 手机号登录
   */
  async login(phoneNumber: string, verificationCode: string): Promise<LoginResponse> {
    const response = await this.apiClient.post<LoginResponse>(
      '/auth/login',
      { phoneNumber, verificationCode },
      false // 不需要认证
    );

    // 保存token和用户信息
    if (response.token) {
      const userInfo: UserInfo = {
        id: response.user.id,
        phone: response.user.phoneNumber || '',
        nickname: response.user.nickname,
        token: response.token
      };
      await this.userService.saveUserInfo(userInfo);
    }

    return response;
  }

  /**
   * 微信登录
   */
  async wechatLogin(code: string): Promise<LoginResponse> {
    const response = await this.apiClient.post<LoginResponse>(
      '/auth/wechat-login',
      { code },
      false // 不需要认证
    );

    // 保存token和用户信息
    if (response.token) {
      const userInfo: UserInfo = {
        id: response.user.id,
        phone: response.user.phoneNumber || '',
        nickname: response.user.nickname,
        token: response.token
      };
      await this.userService.saveUserInfo(userInfo);
    }

    return response;
  }

  /**
   * 游客模式
   */
  async guestMode(): Promise<LoginResponse> {
    const response = await this.apiClient.post<LoginResponse>(
      '/auth/guest',
      undefined,
      false // 不需要认证
    );

    // 保存token和用户信息
    if (response.token) {
      const userInfo: UserInfo = {
        id: response.user.id,
        phone: response.user.phoneNumber || '',
        nickname: response.user.nickname,
        token: response.token
      };
      await this.userService.saveUserInfo(userInfo);
    }

    return response;
  }

  /**
   * 登出
   */
  async logout(): Promise<SuccessResponse> {
    try {
      const response = await this.apiClient.post<SuccessResponse>('/auth/logout');
      // 清除本地用户信息
      await this.userService.logout();
      return response;
    } catch (error) {
      // 即使API调用失败，也清除本地信息
      await this.userService.logout();
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }
}

