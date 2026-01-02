import { ApiClient } from './ApiClient';

/**
 * 图片格式
 */
export type ImageFormat = 'jpg' | 'png' | 'webp';

/**
 * 应用设置
 */
export interface AppSettings {
  notifications: boolean;
  autoSave: boolean;
  defaultQuality: number;
  defaultFormat: ImageFormat;
}

/**
 * 更新设置请求
 */
export interface UpdateSettingsRequest {
  notifications?: boolean;
  autoSave?: boolean;
  defaultQuality?: number;
  defaultFormat?: ImageFormat;
}

/**
 * 设置服务
 */
export class SettingsService {
  private static instance: SettingsService;
  private apiClient: ApiClient = ApiClient.getInstance();

  private constructor() {}

  public static getInstance(): SettingsService {
    if (!SettingsService.instance) {
      SettingsService.instance = new SettingsService();
    }
    return SettingsService.instance;
  }

  /**
   * 获取应用设置
   */
  async getSettings(): Promise<AppSettings> {
    return this.apiClient.get<AppSettings>('/settings');
  }

  /**
   * 更新应用设置
   */
  async updateSettings(request: UpdateSettingsRequest): Promise<AppSettings> {
    return this.apiClient.put<AppSettings>('/settings', request);
  }
}

