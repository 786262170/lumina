/**
 * ============================================
 * LUMINA AI - ROUTER SERVICE
 * 统一路由管理服务
 * ============================================
 */

import router from '@ohos.router';

/**
 * 路由类型定义
 */
export type Route =
  | 'pages/Splash'
  | 'pages/Welcome'
  | 'pages/Login'
  | 'pages/AIQuestionnaire'
  | 'pages/AIRecommendation'
  | 'pages/Index'
  | 'pages/BackgroundTemplates'
  | 'pages/Workbench'
  | 'pages/BatchProcess'
  | 'pages/ProcessResult'
  | 'pages/MyWorks'
  | 'pages/My'
  | 'pages/MemberSubscription'
  | 'pages/Settings'
  | 'pages/ScenarioDetail'
  | 'pages/BackgroundTemplateDetail';

/**
 * Tab配置
 */
export interface TabConfig {
  id: number;
  route: Route;
  label: string;
}

/**
 * Tab配置列表
 */
export const TAB_CONFIG: TabConfig[] = [
  { id: 0, route: 'pages/Index', label: '首页' },
  { id: 1, route: 'pages/BackgroundTemplates', label: '场景' },
  { id: 2, route: 'pages/MyWorks', label: '作品' },
  { id: 3, route: 'pages/My', label: '我的' },
];

/**
 * 隐藏Tab栏的路由列表
 * 注意：Tab页面（Index, BackgroundTemplates, MyWorks, My）应该显示Tab栏
 */
const HIDE_TAB_BAR_ROUTES: Route[] = [
  'pages/Splash',
  'pages/Welcome',
  'pages/Login',
  'pages/AIQuestionnaire',
  'pages/AIRecommendation',
  'pages/Workbench',
  'pages/BatchProcess',
  'pages/ScenarioDetail',
  'pages/ProcessResult',
  'pages/MemberSubscription',
  'pages/Settings',
  'pages/BackgroundTemplateDetail',
];

/**
 * 显示顶部导航栏的路由列表
 */
const SHOW_TOP_NAV_ROUTES: Route[] = [
  'pages/MemberSubscription',
  'pages/Settings',
];

/**
 * 路由参数接口
 * 注意：ArkTS不支持索引签名，使用Record类型替代
 * 支持数组类型（会转换为逗号分隔的字符串）
 */
export type RouteParams = Record<string, string | number | boolean | string[] | undefined>;

/**
 * 路由服务类
 */
export class RouterService {
  private static instance: RouterService;
  private routeHistory: Route[] = [];
  private currentRoute: Route = 'pages/Splash';
  private activeTab: number = 0;

  private constructor() {
    // 初始化路由历史
    this.routeHistory = ['pages/Splash'];
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): RouterService {
    if (!RouterService.instance) {
      RouterService.instance = new RouterService();
    }
    return RouterService.instance;
  }

  /**
   * 获取当前路由
   */
  public getCurrentRoute(): Route {
    return this.currentRoute;
  }

  /**
   * 获取当前Tab索引
   */
  public getActiveTab(): number {
    return this.activeTab;
  }

  /**
   * 设置当前Tab索引（用于立即更新状态）
   * @param tabIndex Tab索引（0-3）
   */
  public setActiveTab(tabIndex: number): void {
    if (tabIndex >= 0 && tabIndex < TAB_CONFIG.length) {
      this.activeTab = tabIndex;
    }
  }

  /**
   * 获取路由历史
   */
  public getRouteHistory(): Route[] {
    return [...this.routeHistory];
  }

  /**
   * 导航到指定路由
   * @param route 目标路由
   * @param params 路由参数
   * @param replace 是否替换当前路由（默认false，使用pushUrl）
   */
  public async navigateTo(
    route: Route,
    params?: RouteParams,
    replace: boolean = false
  ): Promise<void> {
    try {
      // HarmonyOS router API 需要使用 params 对象，而不是 URL 查询字符串
      const routerParams: Record<string, Object> = {};
      if (params) {
        const paramKeys = Object.keys(params);
        for (let i = 0; i < paramKeys.length; i++) {
          const key = paramKeys[i];
          const value = params[key];
          if (value !== undefined && value !== null) {
            // 将参数值转换为 Object 类型（HarmonyOS router 要求）
            if (Array.isArray(value)) {
              routerParams[key] = value;
            } else if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
              routerParams[key] = value;
            } else {
              routerParams[key] = String(value);
            }
          }
        }
      }
      
      console.info(`[RouterService] 准备导航: route=${route}, params=`, routerParams, `replace=${replace}`);
      
      if (replace) {
        await router.replaceUrl({ 
          url: route,
          params: routerParams
        });
        // 替换路由时，更新历史栈的最后一个元素（不增加栈深度）
        if (this.routeHistory.length > 0) {
          this.routeHistory[this.routeHistory.length - 1] = route;
        } else {
          // 如果历史栈为空，添加当前路由
          this.routeHistory.push(route);
        }
      } else {
        await router.pushUrl({ 
          url: route,
          params: routerParams
        });
        // 推入新路由时，检查是否与当前路由相同（避免重复）
        if (this.currentRoute !== route) {
        this.routeHistory.push(route);
        }
      }

      this.currentRoute = route;
      
      // 更新Tab状态
      const tabIndex = this.getTabIndexByRoute(route);
      if (tabIndex !== -1) {
        this.activeTab = tabIndex;
      }

      console.info(`[RouterService] 导航完成: ${route}`);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[RouterService] 导航失败: ${errorMsg}, route=${route}`);
      throw new Error(errorMsg);
    }
  }

  /**
   * 返回上一页
   */
  public async goBack(): Promise<void> {
    try {
      // 检查历史栈
      if (this.routeHistory.length <= 1) {
        // 如果历史栈只有一页或为空，直接跳转到首页
        console.warn('[RouterService] 路由历史栈为空或只有一页，跳转到首页');
        await this.navigateTo('pages/Index', undefined, true);
        return;
      }

      // 先更新路由历史栈（在调用 router.back() 之前）
      this.routeHistory.pop();
      const previousRoute = this.routeHistory[this.routeHistory.length - 1];
      
      // 使用系统路由的返回功能
      // HarmonyOS 的路由系统会自动管理路由栈
      await router.back();
      
      // 更新当前路由和Tab状态
      this.currentRoute = previousRoute;
      const tabIndex = this.getTabIndexByRoute(previousRoute);
      if (tabIndex !== -1) {
        this.activeTab = tabIndex;
      }

      console.info(`[RouterService] 返回上一页: ${previousRoute}`);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[RouterService] 返回失败: ${errorMsg}`);
      
      // 如果返回失败，根据历史栈决定备用方案
      if (this.routeHistory.length > 1) {
        // 有历史记录，尝试手动返回
        this.routeHistory.pop();
        const previousRoute = this.routeHistory[this.routeHistory.length - 1];
        try {
          await this.navigateTo(previousRoute, undefined, true);
          this.currentRoute = previousRoute;
          console.info(`[RouterService] 使用备用方案返回: ${previousRoute}`);
        } catch (navError) {
          // 如果备用方案也失败，跳转到首页
          console.error(`[RouterService] 备用返回方案失败，跳转到首页`);
          await this.navigateTo('pages/Index', undefined, true);
        }
      } else {
        // 没有历史记录，直接跳转到首页
        await this.navigateTo('pages/Index', undefined, true);
      }
    }
  }

  /**
   * 切换到指定Tab
   * @param tabIndex Tab索引（0-3）
   */
  public async switchTab(tabIndex: number): Promise<void> {
    if (tabIndex < 0 || tabIndex >= TAB_CONFIG.length) {
      console.error(`[RouterService] 无效的Tab索引: ${tabIndex}`);
      return;
    }

    const targetRoute = TAB_CONFIG[tabIndex].route;
    
    // 检查当前路由是否是 Tab 页面
    const isCurrentTabPage = TAB_CONFIG.some(tab => tab.route === this.currentRoute);
    
    if (isCurrentTabPage) {
      // 如果当前已经在 Tab 页面，使用 replace 替换（Tab 切换）
      // 但是要确保历史栈中有 Index，以便返回时能回到首页
      if (this.routeHistory.length === 1 && this.routeHistory[0] !== 'pages/Index') {
        // 如果历史栈只有当前 Tab 页面，先添加 Index 到历史栈
        this.routeHistory.unshift('pages/Index');
      }
    await this.navigateTo(targetRoute, undefined, true);
    } else {
      // 如果当前不在 Tab 页面（比如从其他页面进入），先确保 Index 在历史栈中
      // 然后 push 新的 Tab 页面
      if (this.currentRoute !== 'pages/Index') {
        // 如果当前不是 Index，先 push Index（如果历史栈中没有）
        if (!this.routeHistory.includes('pages/Index')) {
          this.routeHistory.push('pages/Index');
        }
      }
      // 然后 push 目标 Tab 页面
      await this.navigateTo(targetRoute, undefined, false);
    }
    
    this.activeTab = tabIndex;

    console.info(`[RouterService] 切换到Tab ${tabIndex}: ${targetRoute} (当前路由: ${this.currentRoute}, 历史栈: ${this.routeHistory.length})`);
  }

  /**
   * 判断是否应该显示Tab栏
   */
  public shouldShowTabBar(): boolean {
    return !HIDE_TAB_BAR_ROUTES.includes(this.currentRoute);
  }

  /**
   * 判断是否应该显示顶部导航栏
   */
  public shouldShowTopNav(): boolean {
    return SHOW_TOP_NAV_ROUTES.includes(this.currentRoute);
  }

  /**
   * 根据路由获取Tab索引
   */
  private getTabIndexByRoute(route: Route): number {
    const tab = TAB_CONFIG.find(t => t.route === route);
    return tab ? tab.id : -1;
  }

  /**
   * 构建路由URL（包含参数）
   */
  private buildRouteUrl(route: Route, params?: RouteParams): string {
    if (!params || Object.keys(params).length === 0) {
      return route;
    }

    const paramEntries: string[] = [];
    const paramKeys = Object.keys(params);
    for (let i = 0; i < paramKeys.length; i++) {
      const key = paramKeys[i];
      const value = params[key];
      if (value !== undefined && value !== null) {
        // 如果是数组，转换为逗号分隔的字符串
        let paramValue: string;
        if (Array.isArray(value)) {
          paramValue = value.join(',');
        } else {
          paramValue = String(value);
        }
        paramEntries.push(`${key}=${encodeURIComponent(paramValue)}`);
      }
    }

    const paramString = paramEntries.join('&');
    return paramString ? `${route}?${paramString}` : route;
  }

  /**
   * 重置路由历史（用于登录/登出）
   */
  public resetHistory(targetRoute: Route = 'pages/Login'): void {
    this.routeHistory = [targetRoute];
    this.currentRoute = targetRoute;
    this.activeTab = 0;
    console.info(`[RouterService] 重置路由历史: ${targetRoute}`);
  }

  /**
   * 获取页面标题（用于顶部导航栏）
   */
  public getPageTitle(): string {
    switch (this.currentRoute) {
      case 'pages/MemberSubscription':
        return '会员订阅';
      case 'pages/Settings':
        return '设置';
      case 'pages/ScenarioDetail':
        return '场景详情';
      case 'pages/BackgroundTemplates':
        return '背景模板';
      case 'pages/BackgroundTemplateDetail':
        return '模板详情';
      case 'pages/Workbench':
        return '工作台';
      case 'pages/BatchProcess':
        return '批量处理';
      case 'pages/ProcessResult':
        return '处理结果';
      case 'pages/MyWorks':
        return '我的作品';
      default:
        return '';
    }
  }
}

