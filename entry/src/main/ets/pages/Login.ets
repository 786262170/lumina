import { router } from '@kit.ArkUI';
import { AuthService } from '../common/services/AuthService';
import { UserService } from '../common/services/UserService';
import { RouterService } from '../common/services/RouterService';

@Entry
@Component
struct Login {
  @State phoneNumber: string = '';
  @State verificationCode: string = '';
  @State countdown: number = 0;
  @State isCodeButtonDisabled: boolean = false;
  @State isLoading: boolean = false;
  @State showCodeHint: boolean = false; // 显示验证码提示
  @State codeHint: string = ''; // 验证码提示内容
  @State errorMessage: string = ''; // 错误提示
  @State phoneError: string = ''; // 手机号错误提示
  @State codeError: string = ''; // 验证码错误提示
  @State isFormValid: boolean = false; // 表单是否有效

  private authService: AuthService = AuthService.getInstance();
  private userService: UserService = UserService.getInstance();
  private routerService: RouterService = RouterService.getInstance();
  private timer: number | null = null;

  aboutToAppear() {
    // 检查是否已登录
    this.checkLoginStatus();
  }

  aboutToDisappear(): void {
    if (this.timer !== null) {
      clearInterval(this.timer);
    }
  }

  // 检查登录状态
  async checkLoginStatus() {
    const isLoggedIn = await this.userService.isLoggedIn();
    if (isLoggedIn) {
      // 已登录，直接跳转到主页
      await this.routerService.navigateTo('pages/Index', undefined, true);
    }
  }

  // 验证手机号
  validatePhoneNumber(): boolean {
    if (!this.phoneNumber) {
      this.phoneError = '请输入手机号';
      return false;
    }
    if (this.phoneNumber.length !== 11) {
      this.phoneError = '手机号必须为11位';
      return false;
    }
    if (!/^1[3-9]\d{9}$/.test(this.phoneNumber)) {
      this.phoneError = '请输入正确的手机号';
      return false;
    }
    this.phoneError = '';
    return true;
  }

  // 验证验证码
  validateVerificationCode(): boolean {
    if (!this.verificationCode) {
      this.codeError = '请输入验证码';
      return false;
    }
    if (this.verificationCode.length !== 6) {
      this.codeError = '验证码必须为6位';
      return false;
    }
    if (!/^\d{6}$/.test(this.verificationCode)) {
      this.codeError = '验证码必须为数字';
      return false;
    }
    this.codeError = '';
    return true;
  }

  // 验证整个表单
  validateForm(): boolean {
    const phoneValid = this.validatePhoneNumber();
    const codeValid = this.validateVerificationCode();
    this.isFormValid = phoneValid && codeValid;
    return this.isFormValid;
  }

  // 获取验证码
  async getVerificationCode() {
    if (!this.validatePhoneNumber()) {
      return;
    }
    
    this.isCodeButtonDisabled = true;
    this.countdown = 60;
    this.errorMessage = '';
    
    try {
      const result = await this.authService.sendCode(this.phoneNumber);
      if (result.success) {
        // 开始倒计时
        this.timer = setInterval(() => {
          if (this.countdown > 0) {
            this.countdown--;
          } else {
            this.isCodeButtonDisabled = false;
            if (this.timer !== null) {
              clearInterval(this.timer);
              this.timer = null;
            }
          }
        }, 1000);
      }
    } catch (error) {
      this.isCodeButtonDisabled = false;
      this.countdown = 0;
      // 错误提示已在 ApiClient 中显示，这里只更新UI状态
      // this.errorMessage = '获取验证码失败';
    }
  }

  // 快速填充测试账号
  fillTestAccount() {
    this.phoneNumber = '13800138000';
    this.verificationCode = '123456';
    this.showCodeHint = true;
    this.codeHint = '123456';
  }

  // 快速登录（跳过验证码）- 使用游客模式
  async quickLogin() {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const result = await this.authService.guestMode();
      // 登录成功，根据是否新用户决定跳转
      await this.handleLoginSuccess(result.isNewUser);
    } catch (error) {
      this.errorMessage = error.message || '登录失败，请重试';
      setTimeout(() => {
        this.errorMessage = '';
      }, 3000);
    } finally {
      this.isLoading = false;
    }
  }

  // 登录
  async handleLogin() {
    // 再次验证表单
    if (!this.validateForm()) {
      this.errorMessage = '请检查输入信息';
      setTimeout(() => {
        this.errorMessage = '';
      }, 2000);
      return;
    }
    
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const result = await this.authService.login(this.phoneNumber, this.verificationCode);
      // 登录成功，根据是否新用户决定跳转
      await this.handleLoginSuccess(result.isNewUser);
    } catch (error) {
      // 错误提示已在 ApiClient 中显示，这里只更新UI状态
    } finally {
      this.isLoading = false;
    }
  }

  // 微信登录
  async handleWeChatLogin() {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      // TODO: 获取微信授权码
      // 在HarmonyOS中，需要使用微信SDK获取授权码
      // 这里先使用模拟的授权码，实际需要调用微信SDK
      const wechatCode = 'mock_wechat_code'; // 实际应该从微信SDK获取
      
      const result = await this.authService.wechatLogin(wechatCode);
      // 微信登录通常不是新用户，直接跳转到主页
      await this.handleLoginSuccess(false);
    } catch (error) {
      // 错误提示已在 ApiClient 中显示，这里只更新UI状态
      // this.errorMessage = error.message || '微信登录失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  // 处理登录成功后的路由跳转
  async handleLoginSuccess(isNewUser: boolean) {
    if (isNewUser) {
      // 新用户：跳转到AI问卷页
      await this.routerService.navigateTo('pages/AIQuestionnaire', undefined, true);
    } else {
      // 老用户：直接跳转到主页
      await this.routerService.navigateTo('pages/Index', undefined, true);
    }
  }

  build() {
    Column() {
      // Logo和品牌区域
      Column() {
        // Logo图标（使用PNG图片）
        Stack() {
          // 使用带圆角的容器作为圆形背景
          Column()
            .width(80)
            .height(80)
            .borderRadius(40)
            .linearGradient({
              angle: 135,
              colors: [
                ['#667eea', 0.0],
                ['#764ba2', 1.0]
              ]
            })
          
          // 使用PNG图片作为logo
          Image($r('app.media.lumina_logo'))
            .width(50)
            .height(50)
            .objectFit(ImageFit.Contain)
        }
        .width(80)
        .height(80)
        .margin({ bottom: 16 })

        // 品牌名
        Text($r('app.string.app_name'))
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ bottom: 8 })

        // 标语
        Text($r('app.string.app_tagline'))
          .fontSize(14)
          .fontColor('#9CA3AF')
          .margin({ bottom: 60 })
      }
      .width('100%')
      .margin({ top: 80 })

      // 欢迎文字
      Column() {
        Text($r('app.string.welcome_back'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ bottom: 8 })

        Text($r('app.string.login_to_continue'))
          .fontSize(14)
          .fontColor('#9CA3AF')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 24, right: 24 })
      .margin({ bottom: 40 })

      // 调试功能区域（开发环境显示）
      Column() {
        Row() {
          Button('快速填充测试账号')
            .type(ButtonType.Normal)
            .fontSize(12)
            .fontColor('#3B82F6')
            .backgroundColor('#EFF6FF')
            .border({ width: 1, color: '#3B82F6' })
            .borderRadius(6)
            .height(32)
            .onClick(() => {
              this.fillTestAccount();
            })

          Button('快速登录')
            .type(ButtonType.Normal)
            .fontSize(12)
            .fontColor('#10B981')
            .backgroundColor('#ECFDF5')
            .border({ width: 1, color: '#10B981' })
            .borderRadius(6)
            .height(32)
            .onClick(() => {
              this.quickLogin();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .margin({ bottom: 16 })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      // 错误提示
      if (this.errorMessage !== '') {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#EF4444')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 8, bottom: 8 })
          .backgroundColor('#FEE2E2')
          .borderRadius(8)
          .margin({ bottom: 16, left: 24, right: 24 })
      }

      // 输入区域
      Column() {
        // 手机号输入
        Column() {
          Text($r('app.string.phone_number'))
            .fontSize(14)
            .fontColor('#374151')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          Row() {
            // 国家代码
            Text('+86')
              .fontSize(16)
              .fontColor('#6B7280')
              .padding({ left: 16, right: 16 })
              .border({ width: { right: 1 }, color: '#E5E7EB' })

            // 手机号输入框
            TextInput({ placeholder: $r('app.string.enter_phone_number'), text: this.phoneNumber })
              .layoutWeight(1)
              .type(InputType.PhoneNumber)
              .maxLength(11)
              .backgroundColor(Color.Transparent)
              .fontSize(16)
              .fontColor('#1F2937')
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.phoneNumber = value;
                this.validatePhoneNumber();
                this.validateForm();
              })
          }
          .width('100%')
          .height(48)
          .borderRadius(8)
          .border({ width: 1, color: '#E5E7EB' })
          .backgroundColor('#FFFFFF')
        }
        .width('100%')
        .margin({ bottom: 24 })

        // 验证码输入
        Column() {
          Row() {
            Text($r('app.string.verification_code'))
              .fontSize(14)
              .fontColor('#374151')
              .layoutWeight(1)

            // 验证码提示（调试用）
            if (this.showCodeHint) {
              Text(`验证码: ${this.codeHint}`)
                .fontSize(12)
                .fontColor('#10B981')
                .backgroundColor('#ECFDF5')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(4)
            }
          }
          .width('100%')
          .margin({ bottom: 8 })

          Row() {
            TextInput({ placeholder: $r('app.string.enter_verification_code'), text: this.verificationCode })
              .layoutWeight(1)
              .type(InputType.Normal)
              .maxLength(6)
              .backgroundColor(Color.Transparent)
              .fontSize(16)
              .fontColor('#1F2937')
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.verificationCode = value;
                this.validateVerificationCode();
                this.validateForm();
              })

            Button(this.countdown > 0 ? `${this.countdown}s` : $r('app.string.get_verification_code'))
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontColor(this.countdown > 0 ? '#9CA3AF' : '#3B82F6')
              .backgroundColor('#FFFFFF')
              .enabled(this.countdown === 0 && this.phoneNumber.length === 11)
              .opacity(this.countdown > 0 || this.phoneNumber.length !== 11 ? 0.5 : 1)
              .border({ width: 1, color: '#3B82F6' })
              .borderRadius(8)
              .width(100)
              .height(36)
              .enabled(!this.isCodeButtonDisabled)
              .onClick(() => {
                this.getVerificationCode();
              })
          }
          .width('100%')
          .height(48)
          .borderRadius(8)
          .border({ 
            width: 1, 
            color: this.codeError ? '#EF4444' : '#E5E7EB' 
          })
          .backgroundColor('#FFFFFF')

          // 验证码错误提示
          if (this.codeError) {
            Text(this.codeError)
              .fontSize(12)
              .fontColor('#EF4444')
              .margin({ top: 4 })
              .width('100%')
          }
        }
        .width('100%')
        .margin({ bottom: 32 })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      // 登录按钮
      Button() {
        if (this.isLoading) {
          LoadingProgress()
            .color('#FFFFFF')
            .width(20)
            .height(20)
        } else {
          Text($r('app.string.login'))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
      }
      .type(ButtonType.Normal)
      .width('100%')
      .height(50)
      .backgroundColor(this.isLoading || !this.isFormValid ? '#9CA3AF' : '#3B82F6')
      .borderRadius(8)
      .enabled(!this.isLoading && this.isFormValid)
      .opacity(this.isLoading || !this.isFormValid ? 0.5 : 1)
      .onClick(() => {
        if (this.isFormValid) {
          this.handleLogin();
        }
      })
      .margin({ bottom: 24 })

      // 分隔符
      Text($r('app.string.or'))
        .fontSize(14)
        .fontColor('#6B7280')
        .margin({ bottom: 24 })

      // 微信登录按钮
      Button() {
        Row() {
          // 微信图标（使用文字符号，实际应该使用微信官方图标）
          Text('💬')
            .fontSize(20)
            .margin({ right: 12 })
          Text($r('app.string.wechat_quick_login'))
            .fontSize(16)
            .fontColor('#FFFFFF')
        }
        .justifyContent(FlexAlign.Center)
      }
      .type(ButtonType.Normal)
      .width('100%')
      .height(50)
      .backgroundColor('#07C160')
      .borderRadius(8)
      .onClick(() => {
        this.handleWeChatLogin();
      })
      .margin({ bottom: 40 })

      // 底部链接
      Row() {
        Text($r('app.string.no_account'))
          .fontSize(14)
          .fontColor('#6B7280')
          .margin({ right: 8 })

        Text($r('app.string.guest_mode'))
          .fontSize(14)
          .fontColor('#3B82F6')
          .onClick(() => {
            // 游客模式
            this.quickLogin();
          })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
    .padding({ left: 24, right: 24 })
  }
}

