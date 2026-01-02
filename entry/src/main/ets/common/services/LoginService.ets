import { UserService, UserInfo } from './UserService';

// 验证码响应接口
export interface VerificationCodeResponse {
  success: boolean;
  message?: string;
  code?: string;
}

// 用户信息响应接口
export interface UserInfoResponse {
  id: string;
  phone: string;
  nickname?: string;
}

// 登录响应接口
export interface LoginResponse {
  success: boolean;
  message?: string;
  token?: string;
  userInfo?: UserInfoResponse;
}

// Mock API服务
export class LoginService {
  private baseUrl: string = 'https://mock.api.com'; // Mock地址
  private userService: UserService = UserService.getInstance();

  // 发送验证码
  async sendVerificationCode(phone: string): Promise<VerificationCodeResponse> {
    // Mock实现：模拟网络请求延迟
    return new Promise((resolve) => {
      setTimeout(() => {
        // 模拟验证码发送成功，返回验证码用于调试
        const mockCode = '123456';
        console.log(`[Mock] 验证码已发送到 ${phone}，验证码：${mockCode}`);
        const result: VerificationCodeResponse = {
          success: true,
          message: '验证码已发送',
          code: mockCode // 调试模式下返回验证码
        };
        resolve(result);
      }, 500); // 缩短延迟时间，便于调试
    });
  }

  // 手机号验证码登录
  async login(phone: string, code: string): Promise<LoginResponse> {
    // Mock实现：模拟网络请求延迟
    return new Promise(async (resolve) => {
      setTimeout(async () => {
        // 模拟登录验证 - 接受多种测试验证码
        if (code === '123456' || code === '000000' || code === '111111') {
          const userInfo: UserInfo = {
            id: 'user_001',
            phone: phone,
            nickname: '用户' + phone.substring(7),
            token: 'mock_token_' + Date.now()
          };
          
          // 保存用户信息
          await this.userService.saveUserInfo(userInfo);
          
          const response: LoginResponse = {
            success: true,
            message: '登录成功',
            token: userInfo.token,
            userInfo: {
              id: userInfo.id,
              phone: userInfo.phone,
              nickname: userInfo.nickname
            }
          };
          resolve(response);
        } else {
          const response: LoginResponse = {
            success: false,
            message: '验证码错误，测试验证码：123456'
          };
          resolve(response);
        }
      }, 800); // 缩短延迟时间，便于调试
    });
  }

  // 微信快捷登录
  async weChatLogin(): Promise<LoginResponse> {
    // Mock实现：模拟微信登录
    return new Promise(async (resolve) => {
      setTimeout(async () => {
        const userInfo: UserInfo = {
          id: 'wechat_user_001',
          phone: '138****8888',
          nickname: '微信用户',
          token: 'mock_wechat_token_' + Date.now()
        };
        
        // 保存用户信息
        await this.userService.saveUserInfo(userInfo);
        
        const response: LoginResponse = {
          success: true,
          message: '微信登录成功',
          token: userInfo.token,
          userInfo: {
            id: userInfo.id,
            phone: userInfo.phone,
            nickname: userInfo.nickname
          }
        };
        resolve(response);
      }, 800); // 缩短延迟时间，便于调试
    });
  }

  // 快速登录（调试用，跳过验证码）
  async quickLogin(phone: string = '13800138000'): Promise<LoginResponse> {
    return this.login(phone, '123456');
  }
}

