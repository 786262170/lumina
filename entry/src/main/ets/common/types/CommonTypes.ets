// 通用类型定义

// 场景项接口
export interface ScenarioItem {
  id: string;
  title: string;
  icon: Resource;
  route: string;
}

// 产品选项接口
export interface ProductOption {
  id: string;
  name: string;
  icon: string;
}

// 问题接口
export interface Question {
  title: string;
  subtitle: string;
  options: ProductOption[];
}

// 推荐项接口
export interface RecommendationItem {
  id: string;
  title: string;
  description: string;
  icon: string;
  category: string;
}

// 工具项接口
export interface ToolItem {
  id: number;
  name: string;
  icon: string;
}

// 作品项接口
export interface WorkItem {
  id: string;
  title: string;
  thumbnail: string;
  createdAt: string;
  category: string;
}

// 会员套餐接口
export interface SubscriptionPlan {
  id: string;
  name: string;
  price: number;
  originalPrice: number;
  features: string[];
  duration: string;
}

// 背景模板接口
export interface BackgroundTemplate {
  id: string;
  title: string;
  category: string;
  rating: number;
  thumbnail: string;
  isSelected: boolean;
}

// 标签项接口
export interface TabItem {
  id: string;
  title: string;
}

// 会员特权接口
export interface PrivilegeItem {
  icon: string;
  title: string;
  description: string;
}

// 批量处理背景模板接口
export interface BatchBackgroundTemplate {
  id: number;
  name: string;
  color: string;
  isGradient: boolean;
  gradientColors?: string[];
}

// 最近作品接口
export interface RecentWork {
  id: string;
  filename: string;
  thumbnail: string;
  createdAt?: string;
}

