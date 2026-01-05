import { router } from '@kit.ArkUI';
import { AuthService } from '../common/services/AuthService';
import { UserService } from '../common/services/UserService';
import { RouterService } from '../common/services/RouterService';
import { LuminaColors, LuminaSpacing, LuminaRadius, LuminaTypography, LuminaLayout, LuminaSizes } from '../common/DesignSystem';

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
            .width(LuminaSizes.AVATAR_XL)
            .height(LuminaSizes.AVATAR_XL)
            .borderRadius(LuminaSizes.AVATAR_XL / 2)
            .linearGradient({
              angle: 135,
              colors: [
                [LuminaColors.PRIMARY_BLUE, 0.0],
                [LuminaColors.SECONDARY_PURPLE, 1.0]
              ]
            })
          
          // 使用PNG图片作为logo
          Image($r('app.media.lumina_logo'))
            .width(50)
            .height(50)
            .objectFit(ImageFit.Contain)
        }
        .width(LuminaSizes.AVATAR_XL)
        .height(LuminaSizes.AVATAR_XL)
        .margin({ bottom: LuminaSpacing.MD })

        // 品牌名
        Text($r('app.string.app_name'))
          .fontSize(LuminaTypography.DISPLAY_MD)
          .fontWeight(LuminaTypography.WEIGHT_BOLD)
          .fontColor(LuminaColors.TEXT_PRIMARY)
          .margin({ bottom: LuminaSpacing.SM })

        // 标语
        Text($r('app.string.app_tagline'))
          .fontSize(LuminaTypography.CAPTION)
          .fontColor(LuminaColors.TEXT_SECONDARY)
          .margin({ bottom: 60 })
      }
      .width('100%')
      .margin({ top: 80 })
      .alignItems(LuminaLayout.ALIGN_CENTER)

      // 欢迎文字
      Column() {
        Text($r('app.string.welcome_back'))
          .fontSize(LuminaTypography.HEADLINE)
          .fontWeight(LuminaTypography.WEIGHT_BOLD)
          .fontColor(LuminaColors.TEXT_PRIMARY)
          .margin({ bottom: LuminaSpacing.SM })

        Text($r('app.string.login_to_continue'))
          .fontSize(LuminaTypography.CAPTION)
          .fontColor(LuminaColors.TEXT_SECONDARY)
      }
      .width('100%')
      .alignItems(LuminaLayout.ALIGN_START)
      .padding({ left: LuminaLayout.PAGE_PADDING_H_LARGE, right: LuminaLayout.PAGE_PADDING_H_LARGE })
      .margin({ bottom: 40 })

      // 调试功能区域（开发环境显示）
      Column() {
        Row() {
          Button('快速填充测试账号')
            .type(ButtonType.Normal)
            .fontSize(LuminaTypography.LABEL)
            .fontColor('#3B82F6')
            .backgroundColor('#EFF6FF')
            .border({ width: 1, color: '#3B82F6' })
            .borderRadius(LuminaRadius.SM)
            .height(LuminaSizes.BUTTON_HEIGHT_SM)
            .onClick(() => {
              this.fillTestAccount();
            })

          Button('快速登录')
            .type(ButtonType.Normal)
            .fontSize(LuminaTypography.LABEL)
            .fontColor(LuminaColors.SUCCESS)
            .backgroundColor('#ECFDF5')
            .border({ width: 1, color: LuminaColors.SUCCESS })
            .borderRadius(LuminaRadius.SM)
            .height(LuminaSizes.BUTTON_HEIGHT_SM)
            .onClick(() => {
              this.quickLogin();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .margin({ bottom: LuminaSpacing.MD })
      }
      .width('100%')
      .padding({ left: LuminaLayout.PAGE_PADDING_H_LARGE, right: LuminaLayout.PAGE_PADDING_H_LARGE })

      // 错误提示
      if (this.errorMessage !== '') {
        Text(this.errorMessage)
          .fontSize(LuminaTypography.CAPTION)
          .fontColor(LuminaColors.ERROR)
          .width('100%')
          .textAlign(LuminaLayout.TEXT_ALIGN_CENTER)
          .padding({ top: LuminaSpacing.SM, bottom: LuminaSpacing.SM })
          .backgroundColor('#FEE2E2')
          .borderRadius(LuminaRadius.MD)
          .margin({ bottom: LuminaSpacing.MD, left: LuminaLayout.PAGE_PADDING_H_LARGE, right: LuminaLayout.PAGE_PADDING_H_LARGE })
      }

      // 输入区域
      Column() {
        // 手机号输入
        Column() {
          Text($r('app.string.phone_number'))
            .fontSize(LuminaTypography.CAPTION)
            .fontColor(LuminaColors.TEXT_PRIMARY)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: LuminaSpacing.SM })

          Row() {
            // 国家代码
            Text('+86')
              .fontSize(LuminaTypography.BODY)
              .fontColor(LuminaColors.TEXT_SECONDARY)
              .padding({ left: LuminaSizes.INPUT_PADDING_H, right: LuminaSizes.INPUT_PADDING_H })
              .border({ width: { right: 1 }, color: LuminaColors.BORDER })

            // 手机号输入框
            TextInput({ placeholder: $r('app.string.enter_phone_number'), text: this.phoneNumber })
              .layoutWeight(1)
              .type(InputType.PhoneNumber)
              .maxLength(11)
              .backgroundColor(Color.Transparent)
              .fontSize(LuminaTypography.BODY)
              .fontColor(LuminaColors.TEXT_PRIMARY)
              .padding({ left: LuminaSpacing.SM, right: LuminaSpacing.SM })
              .onChange((value: string) => {
                this.phoneNumber = value;
                this.validatePhoneNumber();
                this.validateForm();
              })
          }
          .width('100%')
          .height(LuminaSizes.INPUT_HEIGHT)
          .borderRadius(LuminaRadius.MD)
          .border({ width: 1, color: this.phoneError ? LuminaColors.ERROR : LuminaColors.BORDER })
          .backgroundColor(LuminaColors.BG_SURFACE)
        }
        .width('100%')
        .margin({ bottom: LuminaLayout.SECTION_SPACING })

        // 验证码输入
        Column() {
          Row() {
            Text($r('app.string.verification_code'))
              .fontSize(LuminaTypography.CAPTION)
              .fontColor(LuminaColors.TEXT_PRIMARY)
              .layoutWeight(1)

            // 验证码提示（调试用）
            if (this.showCodeHint) {
              Text(`验证码: ${this.codeHint}`)
                .fontSize(LuminaTypography.LABEL)
                .fontColor(LuminaColors.SUCCESS)
                .backgroundColor('#ECFDF5')
                .padding({ left: LuminaSpacing.SM, right: LuminaSpacing.SM, top: LuminaSpacing.XS, bottom: LuminaSpacing.XS })
                .borderRadius(LuminaRadius.SM)
            }
          }
          .width('100%')
          .margin({ bottom: LuminaSpacing.SM })

          Row() {
            TextInput({ placeholder: $r('app.string.enter_verification_code'), text: this.verificationCode })
              .layoutWeight(1)
              .type(InputType.Normal)
              .maxLength(6)
              .backgroundColor(Color.Transparent)
              .fontSize(LuminaTypography.BODY)
              .fontColor(LuminaColors.TEXT_PRIMARY)
              .padding({ left: LuminaSizes.INPUT_PADDING_H, right: LuminaSizes.INPUT_PADDING_H })
              .onChange((value: string) => {
                this.verificationCode = value;
                this.validateVerificationCode();
                this.validateForm();
              })

            Button(this.countdown > 0 ? `${this.countdown}s` : $r('app.string.get_verification_code'))
              .type(ButtonType.Normal)
              .fontSize(LuminaTypography.CAPTION)
              .fontColor(this.countdown > 0 ? LuminaColors.TEXT_SECONDARY : '#3B82F6')
              .backgroundColor(LuminaColors.BG_SURFACE)
              .enabled(this.countdown === 0 && this.phoneNumber.length === 11)
              .opacity(this.countdown > 0 || this.phoneNumber.length !== 11 ? 0.5 : 1)
              .border({ width: 1, color: '#3B82F6' })
              .borderRadius(LuminaRadius.MD)
              .width(100)
              .height(36)
              .enabled(!this.isCodeButtonDisabled)
              .onClick(() => {
                this.getVerificationCode();
              })
          }
          .width('100%')
          .height(LuminaSizes.INPUT_HEIGHT)
          .borderRadius(LuminaRadius.MD)
          .border({ 
            width: 1, 
            color: this.codeError ? LuminaColors.ERROR : LuminaColors.BORDER 
          })
          .backgroundColor(LuminaColors.BG_SURFACE)

          // 验证码错误提示
          if (this.codeError) {
            Text(this.codeError)
              .fontSize(LuminaTypography.LABEL)
              .fontColor(LuminaColors.ERROR)
              .margin({ top: LuminaSpacing.XS })
              .width('100%')
          }
        }
        .width('100%')
        .margin({ bottom: LuminaSpacing.XL })
      }
      .width('100%')
      .padding({ left: LuminaLayout.PAGE_PADDING_H_LARGE, right: LuminaLayout.PAGE_PADDING_H_LARGE })

      // 登录按钮
      Button() {
        if (this.isLoading) {
          LoadingProgress()
            .color('#FFFFFF')
            .width(20)
            .height(20)
        } else {
          Text($r('app.string.login'))
            .fontSize(LuminaTypography.TITLE)
            .fontWeight(LuminaTypography.WEIGHT_MEDIUM)
            .fontColor('#FFFFFF')
        }
      }
      .type(ButtonType.Normal)
      .width('100%')
      .height(LuminaSizes.BUTTON_HEIGHT_LG)
      .backgroundColor(this.isLoading || !this.isFormValid ? LuminaColors.TEXT_SECONDARY : '#3B82F6')
      .borderRadius(LuminaRadius.MD)
      .enabled(!this.isLoading && this.isFormValid)
      .opacity(this.isLoading || !this.isFormValid ? 0.5 : 1)
      .onClick(() => {
        if (this.isFormValid) {
          this.handleLogin();
        }
      })
      .margin({ bottom: LuminaLayout.SECTION_SPACING })
      .padding({ left: LuminaLayout.PAGE_PADDING_H_LARGE, right: LuminaLayout.PAGE_PADDING_H_LARGE })

      // 底部链接
      Row() {
        Text($r('app.string.no_account'))
          .fontSize(LuminaTypography.CAPTION)
          .fontColor(LuminaColors.TEXT_SECONDARY)
          .margin({ right: LuminaSpacing.SM })

        Text($r('app.string.guest_mode'))
          .fontSize(LuminaTypography.CAPTION)
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
    .padding({ left: LuminaLayout.PAGE_PADDING_H_LARGE, right: LuminaLayout.PAGE_PADDING_H_LARGE })
  }
}

