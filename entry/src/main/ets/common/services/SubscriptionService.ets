import { ApiClient } from './ApiClient';

/**
 * 计划ID
 */
export type PlanId = 'monthly' | 'annual';

/**
 * 支付方式
 */
export type PaymentMethod = 'wechat' | 'alipay';

/**
 * 徽章颜色
 */
export type BadgeColor = 'primary' | 'accent';

/**
 * 计划徽章
 */
export interface PlanBadge {
  text: string;
  color: BadgeColor;
}

/**
 * 订阅计划
 */
export interface SubscriptionPlan {
  id: PlanId;
  name: string;
  price: number;
  period: string;
  periodSubtext?: string;
  badge?: PlanBadge;
  features: string[];
  highlighted: boolean;
}

/**
 * 订阅计划响应
 */
export interface SubscriptionPlansResponse {
  plans: SubscriptionPlan[];
}

/**
 * 当前订阅响应
 */
export interface CurrentSubscriptionResponse {
  planId: PlanId;
  planName: string;
  startDate: string;
  expiryDate: string;
  isActive: boolean;
  autoRenew: boolean;
}

/**
 * 创建订单请求
 */
export interface CreateOrderRequest {
  planId: PlanId;
  paymentMethod: PaymentMethod;
}

/**
 * 订单响应
 */
export interface OrderResponse {
  orderId: string;
  amount: number;
  paymentInfo: Record<string, any>;
  expiresAt: string;
}

/**
 * 成功响应
 */
export interface SuccessResponse {
  success: boolean;
  message: string;
}

/**
 * 订阅服务
 */
export class SubscriptionService {
  private static instance: SubscriptionService;
  private apiClient: ApiClient = ApiClient.getInstance();

  private constructor() {}

  public static getInstance(): SubscriptionService {
    if (!SubscriptionService.instance) {
      SubscriptionService.instance = new SubscriptionService();
    }
    return SubscriptionService.instance;
  }

  /**
   * 获取订阅计划（无需认证）
   */
  async getPlans(): Promise<SubscriptionPlansResponse> {
    return this.apiClient.get<SubscriptionPlansResponse>('/subscription/plans', false);
  }

  /**
   * 获取当前订阅
   */
  async getCurrentSubscription(): Promise<CurrentSubscriptionResponse> {
    return this.apiClient.get<CurrentSubscriptionResponse>('/subscription/current');
  }

  /**
   * 创建订阅订单
   */
  async createOrder(request: CreateOrderRequest): Promise<OrderResponse> {
    return this.apiClient.post<OrderResponse>('/subscription/create-order', request);
  }
}

