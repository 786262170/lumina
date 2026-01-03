import { ApiClient, ApiConfig } from './ApiClient';
import { picker } from '@kit.CoreFileKit';
import { ToastUtil } from '../utils/ToastUtil';
import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import { UserService } from './UserService';

/**
 * 上传的图片信息
 */
export interface UploadedImage {
  id: string;
  filename: string;
  url: string;
  thumbnail?: string;
  width: number;
  height: number;
  size: number;
  format: string;
  uploadedAt: string;
}

/**
 * 上传响应
 */
export interface UploadResponse {
  images: UploadedImage[];
}

/**
 * 文件数据接口
 */
export interface FileData {
  buffer: ArrayBuffer;
  fileName: string;
}

/**
 * 操作类型
 */
export type OperationType = 'cutout' | 'background' | 'lighting' | 'filter' | 'resize';

/**
 * 图片操作参数
 */
export interface ImageOperationParams {
  backgroundColor?: string;
  backgroundTemplateId?: string;
  brightness?: number;
  contrast?: number;
  saturation?: number;
  hue?: number;
  blur?: number;
  sharpness?: number;
  // 其他可能的参数
  templateId?: string;
  color?: string;
  opacity?: number;
  size?: string;
  position?: string;
}

/**
 * 图片操作
 */
export interface ImageOperation {
  type: OperationType;
  params: ImageOperationParams;
}

/**
 * 场景类型
 */
export type SceneType = 'taobao' | 'douyin' | 'xiaohongshu' | 'amazon' | 'custom';

/**
 * 处理图片请求
 */
export interface ProcessImageRequest {
  imageId: string;
  operations: ImageOperation[];
  outputSize?: string;
  quality?: number;
  edgeSmoothing?: boolean;
  sceneType?: SceneType;
}

/**
 * 任务状态
 */
export type TaskStatus = 'pending' | 'processing' | 'completed' | 'failed';

/**
 * 处理任务响应
 */
export interface ProcessTaskResponse {
  taskId: string;
  status: TaskStatus;
  estimatedTime: number;
}

/**
 * 批量处理请求
 */
export interface BatchProcessRequest {
  imageIds: string[];
  operations: ImageOperation[];
  outputSize?: string;
  quality?: number;
  edgeSmoothing?: boolean;
  sceneType?: SceneType;
}

/**
 * 批量处理响应
 */
export interface BatchProcessResponse {
  batchTaskId: string;
  tasks: ProcessTaskResponse[];
  totalCount: number;
}

/**
 * 处理状态响应
 */
export interface ProcessStatusResponse {
  taskId: string;
  status: TaskStatus;
  progress: number;
  message?: string;
  estimatedTimeRemaining?: number;
}

/**
 * 处理后的图片
 */
export interface ProcessedImage {
  id: string;
  url: string;
  thumbnail?: string;
  width: number;
  height: number;
  size: number;
  format: string;
  operations: ImageOperation[];
}

/**
 * 处理结果状态（仅completed或failed）
 */
export type ProcessResultStatus = 'completed' | 'failed';

/**
 * 处理结果响应
 */
export interface ProcessResultResponse {
  taskId: string;
  status: ProcessResultStatus;
  resultImage: ProcessedImage;
  processingTime: number;
  beforeImage: UploadedImage;
  error?: string;
}

/**
 * 图片分析请求
 */
export interface ImageAnalysisRequest {
  imageId: string;
  prompt?: string;
  maxTokens?: number;
}

/**
 * 图片分析响应
 */
export interface ImageAnalysisResponse {
  imageId: string;
  description: string;
  tags: string[];
  mainSubject: string;
  style: string;
  qualityScore: number;
  suggestions: string[];
}

/**
 * 图片服务
 */
export class ImageService {
  private static instance: ImageService;
  private apiClient: ApiClient = ApiClient.getInstance();

  private constructor() {}

  public static getInstance(): ImageService {
    if (!ImageService.instance) {
      ImageService.instance = new ImageService();
    }
    return ImageService.instance;
  }

  /**
   * 将字符串转换为 ArrayBuffer
   */
  private stringToArrayBuffer(str: string): ArrayBuffer {
    const buffer = new ArrayBuffer(str.length);
    const view = new Uint8Array(buffer);
    for (let i = 0; i < str.length; i++) {
      view[i] = str.charCodeAt(i);
    }
    return buffer;
  }

  /**
   * 通过 URI 读取文件内容
   * 注意：对于 media/Photo URI，需要使用 photoAccessHelper，但需要 context
   * 这里先尝试直接路径，如果失败则提示需要 context
   */
  private async readFileFromUri(uri: string): Promise<FileData> {
    // 首先尝试直接文件路径读取
    let filePath = uri;
    if (uri.startsWith('file://')) {
      filePath = uri.replace('file://', '');
    }
    
    // 尝试不同的路径格式
    const pathVariants: string[] = [
      filePath,
      uri.replace('file:///', '/'),
      uri.replace('file://', '/'),
      uri.replace('file://', ''),
    ];
    
    for (let j = 0; j < pathVariants.length; j++) {
      const tryPath = pathVariants[j];
      try {
        console.info(`[ImageService] 尝试路径: ${tryPath}`);
        const file = fs.openSync(tryPath, fs.OpenMode.READ_ONLY);
        const stat = fs.statSync(tryPath);
        const fileSize = stat.size;
        const buffer = new ArrayBuffer(fileSize);
        fs.readSync(file.fd, buffer);
        fs.closeSync(file);
        
        const fileName = tryPath.split('/').pop() || 'image.jpg';
        console.info(`[ImageService] 成功读取文件: ${fileName}, 大小: ${fileSize}`);
        const result: FileData = { buffer, fileName };
        return result;
      } catch (tryError) {
        console.info(`[ImageService] 路径 ${tryPath} 失败: ${tryError}`);
      }
    }
    
    // 如果所有路径都失败，对于 media URI，需要特殊处理
    // 在 HarmonyOS 中，file://media/Photo/... 需要通过 photoAccessHelper 访问
    // 但由于服务类无法直接获取 context，这里先返回错误，提示需要从页面传入 context
    throw new Error(`无法读取文件: ${uri}。对于媒体库文件，需要使用 photoAccessHelper，请在页面中处理文件上传`);
  }

  /**
   * 上传图片
   * 使用 multipart/form-data 格式上传文件
   */
  async uploadImages(imageUris: string[], sceneType?: SceneType): Promise<UploadResponse> {
    const httpRequest = http.createHttp();
    const url = `${ApiConfig.BASE_URL}/images/upload`;
    const userService = UserService.getInstance();
    
    try {
      // 构建 multipart/form-data 请求体
      const boundary = `----WebKitFormBoundary${Date.now()}`;
      const formDataParts: ArrayBuffer[] = [];
      
      // 添加文件字段
      for (let i = 0; i < imageUris.length; i++) {
        const uri = imageUris[i];
        
        try {
          // 对于媒体库文件，尝试使用 HTTP 请求的 fileUri 参数
          // 如果失败，则读取文件内容
          let fileData: FileData;
          if (uri.startsWith('file://media/Photo/')) {
            // 对于媒体库文件，先尝试直接使用 URI
            // 如果 HTTP 请求不支持，则读取文件内容
            try {
              fileData = await this.readFileFromUri(uri);
            } catch (mediaError) {
              console.warn(`[ImageService] 无法读取媒体库文件，尝试使用 URI 直接上传: ${mediaError}`);
              // 如果读取失败，尝试使用 HTTP 请求的 fileUri 参数
              // 注意：这需要后端支持直接上传 URI
              throw new Error(`无法读取媒体库文件: ${mediaError}。请确保应用有读取媒体库的权限`);
            }
          } else {
            // 读取文件
            fileData = await this.readFileFromUri(uri);
          }
          
          const fileBuffer = fileData.buffer;
          const fileName = fileData.fileName;
          
          // 构建文件部分的 multipart 数据
          const filePartHeader = `--${boundary}\r\nContent-Disposition: form-data; name="files"; filename="${fileName}"\r\nContent-Type: image/jpeg\r\n\r\n`;
          const filePartHeaderBuffer = new ArrayBuffer(filePartHeader.length);
          const filePartHeaderView = new Uint8Array(filePartHeaderBuffer);
          for (let j = 0; j < filePartHeader.length; j++) {
            filePartHeaderView[j] = filePartHeader.charCodeAt(j);
          }
          
          formDataParts.push(filePartHeaderBuffer);
          formDataParts.push(fileBuffer);
          formDataParts.push(this.stringToArrayBuffer('\r\n'));
        } catch (fileError) {
          console.error(`[ImageService] 读取文件失败: ${uri}, 错误: ${fileError}`);
          throw new Error(`读取文件失败: ${fileError}`);
        }
      }
      
      // 添加 sceneType 字段（如果提供）
      if (sceneType) {
        const sceneTypePart = `--${boundary}\r\nContent-Disposition: form-data; name="sceneType"\r\n\r\n${sceneType}\r\n`;
        formDataParts.push(this.stringToArrayBuffer(sceneTypePart));
      }
      
      // 添加结束边界
      const endBoundary = `--${boundary}--\r\n`;
      formDataParts.push(this.stringToArrayBuffer(endBoundary));
      
      // 合并所有部分
      let totalSize = 0;
      for (let i = 0; i < formDataParts.length; i++) {
        totalSize += formDataParts[i].byteLength;
      }
      
      const combinedBuffer = new ArrayBuffer(totalSize);
      const combinedView = new Uint8Array(combinedBuffer);
      let offset = 0;
      for (let i = 0; i < formDataParts.length; i++) {
        const partView = new Uint8Array(formDataParts[i]);
        combinedView.set(partView, offset);
        offset += partView.length;
      }
      
      // 构建请求头
      const token = await userService.getToken();
      const headers: Record<string, string> = {
        'Content-Type': `multipart/form-data; boundary=${boundary}`
      };
      
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
      
      // 发送请求
      console.info(`[ImageService] 开始上传 ${imageUris.length} 张图片到 ${url}`);
      
      const httpOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: combinedBuffer,
        readTimeout: ApiConfig.TIMEOUT,
        connectTimeout: ApiConfig.TIMEOUT
      };
      
      const response = await httpRequest.request(url, httpOptions);
      const responseCode = response.responseCode;
      const responseData = response.result.toString();
      
      console.info(`[ImageService] 上传响应: ${responseCode}, ${responseData}`);
      
      if (responseCode >= 200 && responseCode < 300) {
        // 明确类型转换，避免 any
        const parsedData: ESObject = JSON.parse(responseData) as ESObject;
        
        // 检查是否有错误字段
        const errorField: ESObject | undefined = parsedData['error'] as ESObject | undefined;
        if (errorField) {
          const errorMessage = (errorField['message'] as string) || '上传失败';
          ToastUtil.showError(errorMessage);
          throw new Error(errorMessage);
        }
        
        // 解析响应数据
        const dataField: ESObject | undefined = parsedData['data'] as ESObject | undefined;
        const imagesFieldRaw: ESObject | undefined = parsedData['images'] as ESObject | undefined;
        const imagesField: ESObject[] | undefined = imagesFieldRaw ? (imagesFieldRaw as ESObject[]) : undefined;
        
        let images: UploadedImage[] = [];
        if (imagesField && imagesField.length > 0) {
          for (let i = 0; i < imagesField.length; i++) {
            const imgRaw: ESObject | undefined = imagesField[i] as ESObject | undefined;
            if (imgRaw) {
              const img: ESObject = imgRaw;
              const uploadedImage: UploadedImage = {
                id: img['id'] as string,
                filename: img['filename'] as string,
                url: img['url'] as string,
                thumbnail: img['thumbnail'] as string | undefined,
                width: img['width'] as number,
                height: img['height'] as number,
                size: img['size'] as number,
                format: img['format'] as string,
                uploadedAt: img['uploadedAt'] as string
              };
              images.push(uploadedImage);
            }
          }
        } else if (dataField) {
          const dataImagesRaw: ESObject | undefined = dataField['images'] as ESObject | undefined;
          const dataImages: ESObject[] = dataImagesRaw ? (dataImagesRaw as ESObject[]) : [];
          for (let i = 0; i < dataImages.length; i++) {
            const imgRaw: ESObject | undefined = dataImages[i] as ESObject | undefined;
            if (imgRaw) {
              const img: ESObject = imgRaw;
              const uploadedImage: UploadedImage = {
                id: img['id'] as string,
                filename: img['filename'] as string,
                url: img['url'] as string,
                thumbnail: img['thumbnail'] as string | undefined,
                width: img['width'] as number,
                height: img['height'] as number,
                size: img['size'] as number,
                format: img['format'] as string,
                uploadedAt: img['uploadedAt'] as string
              };
              images.push(uploadedImage);
            }
          }
        }
        
        console.info(`[ImageService] 上传成功，共 ${images.length} 张图片`);
        ToastUtil.showSuccess(`成功上传 ${images.length} 张图片`);
        
        return { images };
      } else {
        const errorMsg = `上传失败 (${responseCode})`;
        ToastUtil.showError(errorMsg);
        throw new Error(errorMsg);
      }
    } catch (error) {
      console.error(`[ImageService] 上传图片失败: ${error}`);
      if (error instanceof Error) {
        if (!error.message.includes('上传失败')) {
          ToastUtil.showError(`上传失败: ${error.message}`);
        }
        throw error;
      } else {
        const errorMsg = `上传失败: ${String(error)}`;
        ToastUtil.showError(errorMsg);
        throw new Error(errorMsg);
      }
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 上传图片（通过文件内容）
   * 使用 multipart/form-data 格式上传文件
   * @param fileDataArray 文件数据数组，包含 buffer 和 fileName
   * @param sceneType 场景类型
   */
  async uploadImageFiles(fileDataArray: FileData[], sceneType?: SceneType): Promise<UploadResponse> {
    const httpRequest = http.createHttp();
    const url = `${ApiConfig.BASE_URL}/images/upload`;
    const userService = UserService.getInstance();
    
    try {
      // 构建 multipart/form-data 请求体
      const boundary = `----WebKitFormBoundary${Date.now()}`;
      const formDataParts: ArrayBuffer[] = [];
      
      // 添加文件字段
      for (let i = 0; i < fileDataArray.length; i++) {
        const fileData = fileDataArray[i];
        const fileBuffer = fileData.buffer;
        const fileName = fileData.fileName;
        
        // 构建文件部分的 multipart 数据
        const filePartHeader = `--${boundary}\r\nContent-Disposition: form-data; name="files"; filename="${fileName}"\r\nContent-Type: image/jpeg\r\n\r\n`;
        const filePartHeaderBuffer = new ArrayBuffer(filePartHeader.length);
        const filePartHeaderView = new Uint8Array(filePartHeaderBuffer);
        for (let j = 0; j < filePartHeader.length; j++) {
          filePartHeaderView[j] = filePartHeader.charCodeAt(j);
        }
        
        formDataParts.push(filePartHeaderBuffer);
        formDataParts.push(fileBuffer);
        formDataParts.push(this.stringToArrayBuffer('\r\n'));
      }
      
      // 添加 sceneType 字段（如果提供）
      if (sceneType) {
        const sceneTypePart = `--${boundary}\r\nContent-Disposition: form-data; name="sceneType"\r\n\r\n${sceneType}\r\n`;
        formDataParts.push(this.stringToArrayBuffer(sceneTypePart));
      }
      
      // 添加结束边界
      const endBoundary = `--${boundary}--\r\n`;
      formDataParts.push(this.stringToArrayBuffer(endBoundary));
      
      // 合并所有部分
      let totalSize = 0;
      for (let i = 0; i < formDataParts.length; i++) {
        totalSize += formDataParts[i].byteLength;
      }
      
      const combinedBuffer = new ArrayBuffer(totalSize);
      const combinedView = new Uint8Array(combinedBuffer);
      let offset = 0;
      for (let i = 0; i < formDataParts.length; i++) {
        const partView = new Uint8Array(formDataParts[i]);
        combinedView.set(partView, offset);
        offset += partView.length;
      }
      
      // 构建请求头
      const token = await userService.getToken();
      const headers: Record<string, string> = {
        'Content-Type': `multipart/form-data; boundary=${boundary}`
      };
      
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
      
      // 发送请求
      console.info(`[ImageService] 开始上传 ${fileDataArray.length} 张图片到 ${url}`);
      
      const httpOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: combinedBuffer,
        readTimeout: ApiConfig.TIMEOUT,
        connectTimeout: ApiConfig.TIMEOUT
      };
      
      const response = await httpRequest.request(url, httpOptions);
      const responseCode = response.responseCode;
      const responseData = response.result.toString();
      
      console.info(`[ImageService] 上传响应: ${responseCode}, ${responseData}`);
      
      if (responseCode >= 200 && responseCode < 300) {
        // 明确类型转换，避免 any
        const parsedData: ESObject = JSON.parse(responseData) as ESObject;
        
        // 检查是否有错误字段
        const errorField: ESObject | undefined = parsedData['error'] as ESObject | undefined;
        if (errorField) {
          const errorMessage = (errorField['message'] as string) || '上传失败';
          ToastUtil.showError(errorMessage);
          throw new Error(errorMessage);
        }
        
        // 解析响应数据
        const dataField: ESObject | undefined = parsedData['data'] as ESObject | undefined;
        const imagesFieldRaw: ESObject | undefined = parsedData['images'] as ESObject | undefined;
        const imagesField: ESObject[] | undefined = imagesFieldRaw ? (imagesFieldRaw as ESObject[]) : undefined;
        
        let images: UploadedImage[] = [];
        if (imagesField && imagesField.length > 0) {
          for (let i = 0; i < imagesField.length; i++) {
            const imgRaw: ESObject | undefined = imagesField[i] as ESObject | undefined;
            if (imgRaw) {
              const img: ESObject = imgRaw;
              const uploadedImage: UploadedImage = {
                id: img['id'] as string,
                filename: img['filename'] as string,
                url: img['url'] as string,
                thumbnail: img['thumbnail'] as string | undefined,
                width: img['width'] as number,
                height: img['height'] as number,
                size: img['size'] as number,
                format: img['format'] as string,
                uploadedAt: img['uploadedAt'] as string
              };
              images.push(uploadedImage);
            }
          }
        } else if (dataField) {
          const dataImagesRaw: ESObject | undefined = dataField['images'] as ESObject | undefined;
          const dataImages: ESObject[] = dataImagesRaw ? (dataImagesRaw as ESObject[]) : [];
          for (let i = 0; i < dataImages.length; i++) {
            const imgRaw: ESObject | undefined = dataImages[i] as ESObject | undefined;
            if (imgRaw) {
              const img: ESObject = imgRaw;
              const uploadedImage: UploadedImage = {
                id: img['id'] as string,
                filename: img['filename'] as string,
                url: img['url'] as string,
                thumbnail: img['thumbnail'] as string | undefined,
                width: img['width'] as number,
                height: img['height'] as number,
                size: img['size'] as number,
                format: img['format'] as string,
                uploadedAt: img['uploadedAt'] as string
              };
              images.push(uploadedImage);
            }
          }
        }
        
        console.info(`[ImageService] 上传成功，共 ${images.length} 张图片`);
        ToastUtil.showSuccess(`成功上传 ${images.length} 张图片`);
        
        return { images };
      } else {
        const errorMsg = `上传失败 (${responseCode})`;
        ToastUtil.showError(errorMsg);
        throw new Error(errorMsg);
      }
    } catch (error) {
      console.error(`[ImageService] 上传图片失败: ${error}`);
      if (error instanceof Error) {
        if (!error.message.includes('上传失败')) {
          ToastUtil.showError(`上传失败: ${error.message}`);
        }
        throw error;
      } else {
        const errorMsg = `上传失败: ${String(error)}`;
        ToastUtil.showError(errorMsg);
        throw new Error(errorMsg);
      }
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 处理单张图片
   */
  async processImage(request: ProcessImageRequest): Promise<ProcessTaskResponse> {
    try {
      const response = await this.apiClient.post<ProcessTaskResponse>('/images/process', request);
      ToastUtil.showSuccess('处理任务已创建，正在处理中...');
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
   * 批量处理图片
   */
  async batchProcess(request: BatchProcessRequest): Promise<BatchProcessResponse> {
    try {
      const response = await this.apiClient.post<BatchProcessResponse>('/images/batch-process', request);
      ToastUtil.showSuccess(`已创建批量处理任务，共 ${request.imageIds.length} 张图片`);
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
   * 获取处理进度
   */
  async getProcessStatus(taskId: string): Promise<ProcessStatusResponse> {
    return this.apiClient.get<ProcessStatusResponse>(`/images/process/${taskId}/status`);
  }

  /**
   * 获取处理结果
   */
  async getProcessResult(taskId: string): Promise<ProcessResultResponse> {
    return this.apiClient.get<ProcessResultResponse>(`/images/process/${taskId}/result`);
  }

  /**
   * 分析图片
   */
  async analyzeImage(request: ImageAnalysisRequest): Promise<ImageAnalysisResponse> {
    return this.apiClient.post<ImageAnalysisResponse>('/images/analyze', request);
  }

  /**
   * 下载图片
   * 注意：返回的是文件流，需要特殊处理
   */
  async downloadImage(imageId: string, quality: number = 85, format: string = 'jpg'): Promise<string> {
    // TODO: 实现文件下载
    // 这里返回图片URL，实际下载需要处理文件流
    const url = `/images/${imageId}/download?quality=${quality}&format=${format}`;
    // 使用ApiConfig的BASE_URL
    return `${ApiConfig.BASE_URL}${url}`;
  }

  /**
   * 轮询等待处理结果
   */
  async waitForProcessResult(
    taskId: string,
    onProgress?: (progress: number) => void,
    maxWaitTime: number = 30000
  ): Promise<ProcessResultResponse> {
    const startTime = Date.now();
    
    return new Promise((resolve, reject) => {
      const checkStatus = async () => {
        try {
          const status = await this.getProcessStatus(taskId);
          
          if (onProgress) {
            onProgress(status.progress || 0);
          }

          if (status.status === 'completed') {
            const result = await this.getProcessResult(taskId);
            resolve(result);
          } else if (status.status === 'failed') {
            reject(new Error('处理失败'));
          } else {
            // 检查是否超时
            if (Date.now() - startTime > maxWaitTime) {
              reject(new Error('处理超时'));
            } else {
              // 继续轮询
              setTimeout(checkStatus, 1000);
            }
          }
        } catch (error) {
          reject(error);
        }
      };

      checkStatus();
    });
  }
}

