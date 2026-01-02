import { ApiClient } from './ApiClient';
import { ImageOperation, SceneType } from './ImageService';

/**
 * 场景详情
 */
export interface SceneDetail {
  type: SceneType;
  title: string;
  description: string;
  presetSizes: string[];
  defaultOperations: ImageOperation[];
}

/**
 * 场景列表响应
 */
export interface ScenesResponse {
  scenes: SceneDetail[];
}

/**
 * 场景服务
 */
export class SceneService {
  private static instance: SceneService;
  private apiClient: ApiClient = ApiClient.getInstance();

  private constructor() {}

  public static getInstance(): SceneService {
    if (!SceneService.instance) {
      SceneService.instance = new SceneService();
    }
    return SceneService.instance;
  }

  /**
   * 获取场景列表（无需认证）
   */
  async getScenes(): Promise<ScenesResponse> {
    return this.apiClient.get<ScenesResponse>('/scenes', false);
  }

  /**
   * 获取场景详情（无需认证）
   */
  async getSceneDetail(sceneType: SceneType): Promise<SceneDetail> {
    return this.apiClient.get<SceneDetail>(`/scenes/${sceneType}`, false);
  }
}

