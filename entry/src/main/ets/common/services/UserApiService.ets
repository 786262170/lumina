import { ApiClient } from './ApiClient';

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
 * 更新用户信息请求
 */
export interface UpdateUserProfileRequest {
  nickname?: string;
  avatar?: string;
}

/**
 * 用户统计信息
 */
export interface UserStats {
  processedCount: number;
  remainingQuota: number;
  dailyQuota: number;
  membershipDaysLeft?: number;
  storageUsed: number;
  storageTotal: number;
}

/**
 * 用户API服务
 */
export class UserApiService {
  private static instance: UserApiService;
  private apiClient: ApiClient = ApiClient.getInstance();

  private constructor() {}

  public static getInstance(): UserApiService {
    if (!UserApiService.instance) {
      UserApiService.instance = new UserApiService();
    }
    return UserApiService.instance;
  }

  /**
   * 获取用户信息
   */
  async getUserProfile(): Promise<UserProfile> {
    return this.apiClient.get<UserProfile>('/user/profile');
  }

  /**
   * 更新用户信息
   */
  async updateUserProfile(request: UpdateUserProfileRequest): Promise<UserProfile> {
    return this.apiClient.put<UserProfile>('/user/profile', request);
  }

  /**
   * 获取用户统计信息
   */
  async getUserStats(): Promise<UserStats> {
    return this.apiClient.get<UserStats>('/user/stats');
  }
}

