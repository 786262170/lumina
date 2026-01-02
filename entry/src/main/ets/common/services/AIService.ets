import { ApiClient } from './ApiClient';
import { SceneType } from './ImageService';

/**
 * 提交问答请求
 */
export interface QuizSubmissionRequest {
  answers: Record<string, string>; // key为问题序号（1-based），value为选项ID
}

/**
 * 提交问答响应
 */
export interface QuizSubmissionResponse {
  sessionId: string;
  message: string;
}

/**
 * 推荐场景
 */
export interface Recommendation {
  sceneType: SceneType;
  sceneName: string;
  matchPercentage: number;
  previewImage?: string;
  description: string;
}

/**
 * 推荐功能
 */
export interface Feature {
  id: string;
  name: string;
  description: string;
  icon: string;
}

/**
 * 推荐响应
 */
export interface RecommendationsResponse {
  primaryRecommendation: Recommendation;
  alternatives: Recommendation[];
  recommendedFeatures: Feature[];
}

/**
 * AI 服务
 */
export class AIService {
  private static instance: AIService;
  private apiClient: ApiClient = ApiClient.getInstance();

  private constructor() {}

  public static getInstance(): AIService {
    if (!AIService.instance) {
      AIService.instance = new AIService();
    }
    return AIService.instance;
  }

  /**
   * 提交 AI 问答（可选认证）
   */
  async submitQuiz(answers: Record<string, string>): Promise<QuizSubmissionResponse> {
    return this.apiClient.post<QuizSubmissionResponse>('/ai/quiz', { answers }, false);
  }

  /**
   * 获取 AI 推荐（可选认证）
   */
  async getRecommendations(quizSessionId?: string): Promise<RecommendationsResponse> {
    const params = quizSessionId ? `?quizSessionId=${quizSessionId}` : '';
    return this.apiClient.get<RecommendationsResponse>(`/ai/recommendations${params}`, false);
  }
}

