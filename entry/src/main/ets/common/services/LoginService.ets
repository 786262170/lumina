import { AuthService, SendCodeResponse, LoginResponse } from './AuthService';
import { ToastUtil } from '../utils/ToastUtil';

/**
 * 登录服务
 * 封装认证相关的业务逻辑，使用 AuthService 调用真实 API
 */
export class LoginService {
  private authService: AuthService = AuthService.getInstance();

  /**
   * 发送验证码
   * @param phone 手机号
   * @returns 验证码响应
   */
  async sendVerificationCode(phone: string): Promise<SendCodeResponse> {
    try {
      const response = await this.authService.sendCode(phone);
      // 显示成功提示
      ToastUtil.showSuccess(response.message || '验证码已发送');
      return response;
    } catch (error) {
      // 错误提示已在 ApiClient 中显示
      throw error;
    }
  }

  /**
   * 手机号验证码登录
   * @param phone 手机号
   * @param code 验证码
   * @returns 登录响应
   */
  async login(phone: string, code: string): Promise<LoginResponse> {
    try {
      const response = await this.authService.login(phone, code);
      // 显示成功提示
      ToastUtil.showSuccess('登录成功');
      return response;
    } catch (error) {
      // 错误提示已在 ApiClient 中显示
      throw error;
    }
  }

  /**
   * 游客模式登录
   * @returns 登录响应
   */
  async guestMode(): Promise<LoginResponse> {
    try {
      const response = await this.authService.guestMode();
      // 显示成功提示
      ToastUtil.showSuccess('游客模式已启用');
      return response;
    } catch (error) {
      // 错误提示已在 ApiClient 中显示
      throw error;
    }
  }
}

