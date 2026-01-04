/**
 * API 接口测试工具
 * 用于测试和调试所有 API 接口
 */

import { AuthService } from '../services/AuthService';
import { UserApiService } from '../services/UserApiService';
import { ImageService } from '../services/ImageService';
import { WorkService } from '../services/WorkService';
import { SceneService } from '../services/SceneService';
import { AIService } from '../services/AIService';
import { SubscriptionService } from '../services/SubscriptionService';
import { SettingsService } from '../services/SettingsService';
import { ToastUtil } from './ToastUtil';

/**
 * 测试结果
 */
export interface TestResult {
  apiName: string;
  success: boolean;
  message: string;
  data?: ESObject;
  error?: string;
  timestamp: string;
}

/**
 * API 测试工具类
 */
export class ApiTestUtil {
  private static testResults: TestResult[] = [];

  /**
   * 获取所有测试结果
   */
  static getTestResults(): TestResult[] {
    return this.testResults;
  }

  /**
   * 清空测试结果
   */
  static clearTestResults(): void {
    this.testResults = [];
  }

  /**
   * 添加测试结果
   */
  private static addResult(result: TestResult): void {
    this.testResults.push(result);
    console.info(`[ApiTest] ${result.apiName}: ${result.success ? '成功' : '失败'} - ${result.message}`);
  }

  /**
   * 测试发送验证码
   */
  static async testSendCode(phoneNumber: string = '13800138000'): Promise<TestResult> {
    const apiName = '发送验证码';
    try {
      const authService = AuthService.getInstance();
      const response = await authService.sendCode(phoneNumber);
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `验证码已发送，有效期 ${response.expiresIn} 秒`,
        data: response as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '发送失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试手机号登录
   */
  static async testLogin(phoneNumber: string = '13800138000', code: string = '123456'): Promise<TestResult> {
    const apiName = '手机号登录';
    try {
      const authService = AuthService.getInstance();
      const response = await authService.login(phoneNumber, code);
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `登录成功，用户: ${response.user.nickname || response.user.id}`,
        data: {
          token: response.token.substring(0, 20) + '...',
          userId: response.user.id,
          isNewUser: response.isNewUser
        } as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '登录失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试游客模式
   */
  static async testGuestMode(): Promise<TestResult> {
    const apiName = '游客模式';
    try {
      const authService = AuthService.getInstance();
      const response = await authService.guestMode();
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `游客账号创建成功，用户ID: ${response.user.id}`,
        data: {
          userId: response.user.id,
          isNewUser: response.isNewUser
        } as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '创建游客账号失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试登出
   */
  static async testLogout(): Promise<TestResult> {
    const apiName = '登出';
    try {
      const authService = AuthService.getInstance();
      const response = await authService.logout();
      
      const result: TestResult = {
        apiName,
        success: true,
        message: response.message,
        data: response as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '登出失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试获取用户信息
   */
  static async testGetUserProfile(): Promise<TestResult> {
    const apiName = '获取用户信息';
    try {
      const userApiService = UserApiService.getInstance();
      const profile = await userApiService.getUserProfile();
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `获取成功，昵称: ${profile.nickname || '未设置'}`,
        data: profile as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '获取失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试更新用户信息
   */
  static async testUpdateUserProfile(nickname?: string): Promise<TestResult> {
    const apiName = '更新用户信息';
    try {
      const userApiService = UserApiService.getInstance();
      const profile = await userApiService.updateUserProfile({
        nickname: nickname || `测试昵称_${Date.now()}`
      });
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `更新成功，新昵称: ${profile.nickname}`,
        data: profile as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '更新失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试获取用户统计信息
   */
  static async testGetUserStats(): Promise<TestResult> {
    const apiName = '获取用户统计信息';
    try {
      const userApiService = UserApiService.getInstance();
      const stats = await userApiService.getUserStats();
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `已处理 ${stats.processedCount} 张图片，剩余配额: ${stats.remainingQuota === -1 ? '无限' : stats.remainingQuota}`,
        data: stats as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '获取失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试获取场景列表
   */
  static async testGetScenes(): Promise<TestResult> {
    const apiName = '获取场景列表';
    try {
      const sceneService = SceneService.getInstance();
      const response = await sceneService.getScenes();
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `获取成功，共 ${response.scenes.length} 个场景`,
        data: response as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '获取失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试获取场景详情
   */
  static async testGetSceneDetail(sceneType: string = 'taobao'): Promise<TestResult> {
    const apiName = '获取场景详情';
    try {
      const sceneService = SceneService.getInstance();
      const sceneDetail = await sceneService.getSceneDetail(sceneType as any);
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `获取成功，场景: ${sceneDetail.title}`,
        data: sceneDetail as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '获取失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试获取作品列表
   */
  static async testGetWorks(page: number = 1, pageSize: number = 20): Promise<TestResult> {
    const apiName = '获取作品列表';
    try {
      const workService = WorkService.getInstance();
      const response = await workService.getWorks(page, pageSize);
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `获取成功，共 ${response.pagination.total} 个作品，当前页 ${response.works.length} 个`,
        data: {
          worksCount: response.works.length,
          total: response.pagination.total,
          page: response.pagination.page
        } as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '获取失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试获取订阅计划
   */
  static async testGetSubscriptionPlans(): Promise<TestResult> {
    const apiName = '获取订阅计划';
    try {
      const subscriptionService = SubscriptionService.getInstance();
      const response = await subscriptionService.getPlans();
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `获取成功，共 ${response.plans.length} 个计划`,
        data: response as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '获取失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试获取当前订阅
   */
  static async testGetCurrentSubscription(): Promise<TestResult> {
    const apiName = '获取当前订阅';
    try {
      const subscriptionService = SubscriptionService.getInstance();
      const subscription = await subscriptionService.getCurrentSubscription();
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `获取成功，计划: ${subscription.planName}，状态: ${subscription.isActive ? '有效' : '已过期'}`,
        data: subscription as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '获取失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试获取应用设置
   */
  static async testGetSettings(): Promise<TestResult> {
    const apiName = '获取应用设置';
    try {
      const settingsService = SettingsService.getInstance();
      const settings = await settingsService.getSettings();
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `获取成功，默认质量: ${settings.defaultQuality}，格式: ${settings.defaultFormat}`,
        data: settings as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '获取失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试更新应用设置
   */
  static async testUpdateSettings(): Promise<TestResult> {
    const apiName = '更新应用设置';
    try {
      const settingsService = SettingsService.getInstance();
      const settings = await settingsService.updateSettings({
        defaultQuality: 90,
        defaultFormat: 'png'
      });
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `更新成功，新质量: ${settings.defaultQuality}，新格式: ${settings.defaultFormat}`,
        data: settings as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '更新失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试提交 AI 问答
   */
  static async testSubmitQuiz(): Promise<TestResult> {
    const apiName = '提交 AI 问答';
    try {
      const aiService = AIService.getInstance();
      const response = await aiService.submitQuiz({
        '1': 'clothing',
        '2': 'taobao',
        '3': 'minimal'
      });
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `提交成功，会话ID: ${response.sessionId}`,
        data: response as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '提交失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 测试获取 AI 推荐
   */
  static async testGetRecommendations(quizSessionId?: string): Promise<TestResult> {
    const apiName = '获取 AI 推荐';
    try {
      const aiService = AIService.getInstance();
      const recommendations = await aiService.getRecommendations(quizSessionId);
      
      const result: TestResult = {
        apiName,
        success: true,
        message: `获取成功，主推荐: ${recommendations.primaryRecommendation.sceneName}，匹配度: ${recommendations.primaryRecommendation.matchPercentage}%`,
        data: {
          primaryRecommendation: recommendations.primaryRecommendation,
          alternativesCount: recommendations.alternatives.length,
          featuresCount: recommendations.recommendedFeatures.length
        } as ESObject,
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showSuccess(`${apiName}测试成功`);
      return result;
    } catch (error) {
      const result: TestResult = {
        apiName,
        success: false,
        message: '获取失败',
        error: error instanceof Error ? error.message : String(error),
        timestamp: new Date().toISOString()
      };
      
      this.addResult(result);
      ToastUtil.showError(`${apiName}测试失败: ${result.error}`);
      return result;
    }
  }

  /**
   * 生成测试报告
   */
  static generateTestReport(): string {
    const results = this.testResults;
    const total = results.length;
    const success = results.filter(r => r.success).length;
    const failed = results.filter(r => !r.success).length;
    const successRate = total > 0 ? ((success / total) * 100).toFixed(2) : '0.00';

    let report = `\n========== API 测试报告 ==========\n`;
    report += `测试时间: ${new Date().toLocaleString('zh-CN')}\n`;
    report += `总测试数: ${total}\n`;
    report += `成功: ${success}\n`;
    report += `失败: ${failed}\n`;
    report += `成功率: ${successRate}%\n`;
    report += `\n详细结果:\n`;

    for (let i = 0; i < results.length; i++) {
      const result = results[i];
      report += `\n${i + 1}. ${result.apiName}\n`;
      report += `   状态: ${result.success ? '✅ 成功' : '❌ 失败'}\n`;
      report += `   消息: ${result.message}\n`;
      if (result.error) {
        report += `   错误: ${result.error}\n`;
      }
      report += `   时间: ${result.timestamp}\n`;
    }

    report += `\n===================================\n`;
    return report;
  }

  /**
   * 打印测试报告到控制台
   */
  static printTestReport(): void {
    const report = this.generateTestReport();
    console.info(report);
  }
}

