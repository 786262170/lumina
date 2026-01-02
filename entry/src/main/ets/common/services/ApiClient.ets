import http from '@ohos.net.http';
import { UserService } from './UserService';

/**
 * API 客户端配置
 */
export class ApiConfig {
  // 开发环境
  static readonly DEV_BASE_URL = 'http://localhost:8000/v1';
  // 生产环境（根据实际配置修改）
  static readonly PROD_BASE_URL = 'https://api.lumina.ai/v1';
  
  // 当前使用的Base URL（可通过环境变量切换）
  static readonly BASE_URL = ApiConfig.DEV_BASE_URL;
  
  static readonly TIMEOUT = 30000; // 30秒超时
}

/**
 * HTTP 请求方法
 */
export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';

/**
 * 错误详情接口
 */
export interface ErrorDetail {
  code: string;
  message: string;
  details?: Record<string, string>;
}

/**
 * API 响应接口
 */
export interface ApiResponse<T> {
  success?: boolean;
  data?: T;
  error?: ErrorDetail;
}

/**
 * HTTP 请求选项
 */
export interface RequestOptions {
  method: HttpMethod;
  path: string;
  data?: ESObject;
  needAuth?: boolean;
  headers?: Record<string, string>;
  timeout?: number;
}

/**
 * API 客户端类
 * 封装所有 HTTP 请求
 */
export class ApiClient {
  private static instance: ApiClient;
  private userService: UserService = UserService.getInstance();

  private constructor() {}

  public static getInstance(): ApiClient {
    if (!ApiClient.instance) {
      ApiClient.instance = new ApiClient();
    }
    return ApiClient.instance;
  }

  /**
   * 发送 HTTP 请求
   */
  async request<T>(options: RequestOptions): Promise<T> {
    const method = options.method;
    const path = options.path;
    const data: ESObject | undefined = options.data;
    const needAuth = options.needAuth !== undefined ? options.needAuth : true;
    const customHeaders = options.headers;
    const timeout = options.timeout !== undefined ? options.timeout : ApiConfig.TIMEOUT;

    const httpRequest = http.createHttp();
    const url = `${ApiConfig.BASE_URL}${path}`;

    // 构建请求头
    const requestHeaders: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    
    // 合并自定义请求头
    if (customHeaders) {
      const headerKeys = Object.keys(customHeaders);
      for (let i = 0; i < headerKeys.length; i++) {
        const key = headerKeys[i];
        requestHeaders[key] = customHeaders[key];
      }
    }

    // 添加认证头
    if (needAuth) {
      const token = await this.userService.getToken();
      if (token) {
        requestHeaders['Authorization'] = `Bearer ${token}`;
      }
    }

    // 构建请求选项
    const httpOptions: http.HttpRequestOptions = {
      method: http.RequestMethod[method],
      header: requestHeaders,
      readTimeout: timeout,
      connectTimeout: timeout
    };

    // 添加请求体
    if (data && (method === 'POST' || method === 'PUT')) {
      httpOptions.extraData = JSON.stringify(data);
    }

    try {
      console.info(`[ApiClient] ${method} ${url}`);
      if (data) {
        console.info(`[ApiClient] Request data: ${JSON.stringify(data)}`);
      }

      const response = await httpRequest.request(url, httpOptions);
      const responseCode = response.responseCode;
      const responseData = response.result.toString();

      console.info(`[ApiClient] Response code: ${responseCode}`);
      console.info(`[ApiClient] Response data: ${responseData}`);

      // 解析响应
      let parsedData: ESObject;
      try {
        parsedData = JSON.parse(responseData) as ESObject;
      } catch (parseError) {
        // 如果响应不是JSON，抛出错误
        const errorMsg = `响应解析失败: ${parseError}`;
        throw new Error(errorMsg);
      }

      // 处理HTTP状态码
      if (responseCode >= 200 && responseCode < 300) {
        // 检查是否有错误字段
        const errorField: ESObject | undefined = parsedData['error'] as ESObject | undefined;
        if (errorField) {
          const errorObj = errorField as ErrorDetail;
          throw new Error(errorObj.message || '请求失败');
        }
        
        // 如果响应有data字段，返回data，否则返回整个响应
        const dataField: ESObject | undefined = parsedData['data'] as ESObject | undefined;
        if (dataField !== undefined) {
          return dataField as T;
        } else {
          // 返回整个响应对象
          return parsedData as T;
        }
      } else if (responseCode === 401) {
        // 未认证，清除token
        await this.userService.logout();
        throw new Error('登录已过期，请重新登录');
      } else if (responseCode === 403) {
        throw new Error('权限不足');
      } else if (responseCode === 404) {
        throw new Error('资源不存在');
      } else if (responseCode === 429) {
        throw new Error('请求过于频繁，请稍后再试');
      } else {
        // 其他错误
        const errorField: ESObject | undefined = parsedData['error'] as ESObject | undefined;
        let errorMessage = `请求失败 (${responseCode})`;
        if (errorField) {
          const errorObj = errorField as ErrorDetail;
          errorMessage = errorObj.message || errorMessage;
        }
        throw new Error(errorMessage);
      }
    } catch (error) {
      if (error instanceof Error) {
        console.error(`[ApiClient] 请求失败: ${error.message}`);
        throw error;
      } else {
        const errorMsg = `请求失败: ${String(error)}`;
        console.error(`[ApiClient] ${errorMsg}`);
        throw new Error(errorMsg);
      }
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * GET 请求
   */
  async get<T>(path: string, needAuth: boolean = true, headers?: Record<string, string>): Promise<T> {
    return this.request<T>({
      method: 'GET',
      path: path,
      needAuth: needAuth,
      headers: headers
    });
  }

  /**
   * POST 请求
   */
  async post<T>(path: string, data?: ESObject, needAuth: boolean = true, headers?: Record<string, string>): Promise<T> {
    return this.request<T>({
      method: 'POST',
      path: path,
      data: data,
      needAuth: needAuth,
      headers: headers
    });
  }

  /**
   * PUT 请求
   */
  async put<T>(path: string, data?: ESObject, needAuth: boolean = true, headers?: Record<string, string>): Promise<T> {
    return this.request<T>({
      method: 'PUT',
      path: path,
      data: data,
      needAuth: needAuth,
      headers: headers
    });
  }

  /**
   * DELETE 请求
   */
  async delete<T>(path: string, needAuth: boolean = true, headers?: Record<string, string>): Promise<T> {
    return this.request<T>({
      method: 'DELETE',
      path: path,
      needAuth: needAuth,
      headers: headers
    });
  }
}
