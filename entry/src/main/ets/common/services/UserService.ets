import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

// 用户信息接口
export interface UserInfo {
  id: string;
  phone: string;
  nickname?: string;
  token?: string;
}

// 用户状态管理服务
export class UserService {
  private static instance: UserService;
  private dataPreferences: preferences.Preferences | null = null;
  private context: Context | null = null;
  private readonly PREF_KEY = 'user_preferences';
  private readonly USER_KEY = 'user_info';
  private readonly TOKEN_KEY = 'user_token';
  private readonly IS_LOGGED_IN_KEY = 'is_logged_in';

  private constructor() {}

  public static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  // 设置Context（需要在页面中调用）
  setContext(context: Context): void {
    this.context = context;
  }

  // 初始化Preferences
  async initPreferences(): Promise<void> {
    if (!this.context) {
      console.error('[UserService] Context未设置，无法初始化Preferences');
      return;
    }
    try {
      this.dataPreferences = await preferences.getPreferences(this.context, this.PREF_KEY);
    } catch (err) {
      console.error(`[UserService] 初始化Preferences失败: ${JSON.stringify(err)}`);
    }
  }

  // 保存用户信息
  async saveUserInfo(userInfo: UserInfo): Promise<void> {
    if (!this.dataPreferences) {
      await this.initPreferences();
    }
    try {
      await this.dataPreferences?.put(this.USER_KEY, JSON.stringify(userInfo));
      await this.dataPreferences?.put(this.TOKEN_KEY, userInfo.token || '');
      await this.dataPreferences?.put(this.IS_LOGGED_IN_KEY, true);
      await this.dataPreferences?.flush();
      console.log('[UserService] 用户信息已保存');
    } catch (err) {
      console.error(`[UserService] 保存用户信息失败: ${JSON.stringify(err)}`);
    }
  }

  // 获取用户信息
  async getUserInfo(): Promise<UserInfo | null> {
    if (!this.dataPreferences) {
      await this.initPreferences();
    }
    try {
      const userStr = await this.dataPreferences?.get(this.USER_KEY, '');
      if (userStr && userStr !== '') {
        return JSON.parse(userStr as string) as UserInfo;
      }
      return null;
    } catch (err) {
      console.error(`[UserService] 获取用户信息失败: ${JSON.stringify(err)}`);
      return null;
    }
  }

  // 检查是否已登录
  async isLoggedIn(): Promise<boolean> {
    if (!this.dataPreferences) {
      await this.initPreferences();
    }
    try {
      const isLoggedIn = await this.dataPreferences?.get(this.IS_LOGGED_IN_KEY, false);
      return isLoggedIn as boolean;
    } catch (err) {
      console.error(`[UserService] 检查登录状态失败: ${JSON.stringify(err)}`);
      return false;
    }
  }

  // 获取Token
  async getToken(): Promise<string> {
    if (!this.dataPreferences) {
      await this.initPreferences();
    }
    try {
      const token = await this.dataPreferences?.get(this.TOKEN_KEY, '');
      return token as string;
    } catch (err) {
      console.error(`[UserService] 获取Token失败: ${JSON.stringify(err)}`);
      return '';
    }
  }

  // 退出登录
  async logout(): Promise<void> {
    if (!this.dataPreferences) {
      await this.initPreferences();
    }
    try {
      await this.dataPreferences?.delete(this.USER_KEY);
      await this.dataPreferences?.delete(this.TOKEN_KEY);
      await this.dataPreferences?.put(this.IS_LOGGED_IN_KEY, false);
      await this.dataPreferences?.flush();
      console.log('[UserService] 已退出登录');
    } catch (err) {
      console.error(`[UserService] 退出登录失败: ${JSON.stringify(err)}`);
    }
  }
}

