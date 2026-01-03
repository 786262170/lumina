import { ApiClient } from './ApiClient';
import { SceneType } from './ImageService';
import { ToastUtil } from '../utils/ToastUtil';

/**
 * 作品信息
 */
export interface Work {
  id: string;
  filename: string;
  thumbnail?: string;
  category?: SceneType;
  size: number;
  createdAt: string;
}

/**
 * 分页信息
 */
export interface Pagination {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
}

/**
 * 作品列表响应
 */
export interface WorksListResponse {
  works: Work[];
  pagination: Pagination;
  totalStorage: number;
}

/**
 * 保存作品请求
 */
export interface SaveWorkRequest {
  processedImageId: string;
  filename: string;
  category?: SceneType;
  tags?: string[];
}

/**
 * 作品详情
 */
export interface WorkDetail extends Work {
  imageUrl: string;
  beforeImage: ESObject; // UploadedImage
  afterImage: ESObject; // ProcessedImage
  tags: string[];
  operations: ESObject[]; // ImageOperation[]
}

/**
 * 批量删除请求
 */
export interface BatchDeleteRequest {
  workIds: string[];
}

/**
 * 成功响应
 */
export interface SuccessResponse {
  success: boolean;
  message: string;
}

/**
 * 作品服务
 */
export class WorkService {
  private static instance: WorkService;
  private apiClient: ApiClient = ApiClient.getInstance();

  private constructor() {}

  public static getInstance(): WorkService {
    if (!WorkService.instance) {
      WorkService.instance = new WorkService();
    }
    return WorkService.instance;
  }

  /**
   * 获取作品列表
   */
  async getWorks(
    page: number = 1,
    pageSize: number = 20,
    category?: SceneType
  ): Promise<WorksListResponse> {
    // 手动构建查询字符串（HarmonyOS不支持URLSearchParams）
    let queryString = `page=${page}&pageSize=${pageSize}`;
    if (category) {
      queryString += `&category=${category}`;
    }

    return this.apiClient.get<WorksListResponse>(`/works?${queryString}`);
  }

  /**
   * 保存作品
   */
  async saveWork(request: SaveWorkRequest): Promise<Work> {
    try {
      const work = await this.apiClient.post<Work>('/works', request);
      ToastUtil.showSuccess('作品保存成功');
      return work;
    } catch (error) {
      // 错误提示已在 ApiClient 中显示
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }

  /**
   * 获取作品详情
   */
  async getWorkDetail(workId: string): Promise<WorkDetail> {
    return this.apiClient.get<WorkDetail>(`/works/${workId}`);
  }

  /**
   * 删除作品
   */
  async deleteWork(workId: string): Promise<SuccessResponse> {
    try {
      const response = await this.apiClient.delete<SuccessResponse>(`/works/${workId}`);
      ToastUtil.showSuccess('作品删除成功');
      return response;
    } catch (error) {
      // 错误提示已在 ApiClient 中显示
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }

  /**
   * 批量删除作品
   */
  async batchDeleteWorks(workIds: string[]): Promise<SuccessResponse> {
    try {
      const response = await this.apiClient.post<SuccessResponse>('/works/batch-delete', { workIds });
      ToastUtil.showSuccess(`已删除 ${workIds.length} 个作品`);
      return response;
    } catch (error) {
      // 错误提示已在 ApiClient 中显示
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }
}

