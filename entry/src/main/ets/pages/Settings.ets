import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';
import { UserService, UserInfo } from '../common/services/UserService';
import { UserApiService } from '../common/services/UserApiService';
import { SettingsService, AppSettings, ImageFormat } from '../common/services/SettingsService';
import { AuthService } from '../common/services/AuthService';
import { TopNavBar } from '../common/components/TopNavBar';
import { ToastUtil } from '../common/utils/ToastUtil';

// 质量选项接口
interface QualityOption {
  label: string;
  value: number;
}

@Entry
@Component
struct Settings {
  @State userInfo: UserInfo | null = null;
  @State messageNotification: boolean = true; // 消息通知开关
  @State autoSave: boolean = true; // 自动保存开关
  @State defaultQuality: number = 85; // 默认输出质量（数值）
  @State defaultQualityDisplay: string = '高清'; // 默认输出质量（显示文本）
  @State defaultFormat: ImageFormat = 'jpg'; // 默认图片格式
  @State storageUsed: number = 0; // 已用存储空间（GB）
  @State storageTotal: number = 1.0; // 总存储空间（GB）
  @State storageProgress: number = 0; // 存储进度百分比
  @State showQualityPicker: boolean = false; // 是否显示质量选择器
  @State isLoading: boolean = false; // 是否正在加载
  
  private userService: UserService = UserService.getInstance();
  private userApiService: UserApiService = UserApiService.getInstance();
  private settingsService: SettingsService = SettingsService.getInstance();
  private authService: AuthService = AuthService.getInstance();
  
  // 输出质量选项（映射到数值）
  private qualityOptions: QualityOption[] = [
    { label: '高清', value: 90 },
    { label: '标清', value: 75 },
    { label: '压缩', value: 60 }
  ];
  
  // 根据质量选项获取对应的图标资源
  getQualityIcon(quality: string): Resource {
    switch (quality) {
      case '高清':
        return $r('app.media.high_quality');
      case '标清':
        return $r('app.media.standard_quality');
      case '压缩':
        return $r('app.media.archive');
      default:
        return $r('app.media.right');
    }
  }

  // 根据质量数值获取显示文本
  getQualityLabel(value: number): string {
    const option = this.qualityOptions.find(opt => opt.value === value);
    return option ? option.label : '高清';
  }

  aboutToAppear() {
    // 加载用户信息
    this.loadUserInfo();
    // 加载应用设置
    this.loadSettings();
    // 加载存储空间信息
    this.loadStorageInfo();
  }

  // 加载用户信息
  async loadUserInfo() {
    try {
      this.userInfo = await this.userService.getUserInfo();
    } catch (error) {
      console.error(`[Settings] 加载用户信息失败: ${error}`);
    }
  }

  // 加载应用设置
  async loadSettings() {
    try {
      this.isLoading = true;
      const settings = await this.settingsService.getSettings();
      
      // 更新设置状态
      this.messageNotification = settings.notifications;
      this.autoSave = settings.autoSave;
      this.defaultQuality = settings.defaultQuality;
      this.defaultFormat = settings.defaultFormat;
      this.defaultQualityDisplay = this.getQualityLabel(settings.defaultQuality);
      
      console.info(`[Settings] 成功加载应用设置`);
    } catch (error) {
      console.error(`[Settings] 加载应用设置失败: ${error}`);
      // 如果加载失败，使用默认值
      ToastUtil.showError('加载设置失败，使用默认设置');
    } finally {
      this.isLoading = false;
    }
  }

  // 加载存储空间信息
  async loadStorageInfo() {
    try {
      const stats = await this.userApiService.getUserStats();
      this.storageUsed = stats.storageUsed;
      this.storageTotal = stats.storageTotal;
      // 计算进度百分比
      this.storageProgress = this.storageTotal > 0 ? (this.storageUsed / this.storageTotal) * 100 : 0;
      console.info(`[Settings] 存储空间: ${this.storageUsed}GB / ${this.storageTotal}GB`);
    } catch (error) {
      console.error(`[Settings] 加载存储空间信息失败: ${error}`);
      // 如果加载失败，使用默认值
      this.storageUsed = 0;
      this.storageTotal = 1.0;
      this.storageProgress = 0;
    }
  }

  // 保存设置
  async saveSettings() {
    try {
      // 将质量显示文本转换为数值
      const qualityOption = this.qualityOptions.find(opt => opt.label === this.defaultQualityDisplay);
      const qualityValue = qualityOption ? qualityOption.value : 85;
      
      await this.settingsService.updateSettings({
        notifications: this.messageNotification,
        autoSave: this.autoSave,
        defaultQuality: qualityValue,
        defaultFormat: this.defaultFormat
      });
      
      // 更新本地状态
      this.defaultQuality = qualityValue;
      console.info(`[Settings] 设置已保存`);
    } catch (error) {
      console.error(`[Settings] 保存设置失败: ${error}`);
      ToastUtil.showError('保存设置失败，请稍后重试');
    }
  }


  // 退出登录
  async handleLogout() {
    try {
      // 调用后端登出接口
      await this.authService.logout();
      // 清除本地用户信息
      await this.userService.logout();
      // 跳转到登录页面
      RouterService.getInstance().navigateTo('pages/Login', undefined, true)
        .catch((err: Error) => {
        console.error(`跳转失败: ${err.message}`);
      });
    } catch (error) {
      console.error(`登出失败: ${error.message}`);
      // 即使后端登出失败，也清除本地信息并跳转
      await this.userService.logout();
      RouterService.getInstance().navigateTo('pages/Login', undefined, true)
        .catch((err: Error) => {
        console.error(`跳转失败: ${err.message}`);
      });
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      TopNavBar({ title: '设置', showBack: true, goBackToIndex: false })

      Scroll() {
        Column() {
          // 用户资料和会员卡片
          Row() {
            // 头像
            Image($r('app.media.touxiang'))
              .width(60)
              .height(60)
              .borderRadius(30)
              .objectFit(ImageFit.Cover)
              .margin({ right: 16 })

            // 用户信息
            Column() {
              Text(this.userInfo?.nickname || this.userInfo?.phone || '游客')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1F2937')
                .margin({ bottom: 8 })

              // 会员标签
              Row() {
                Text('会员')
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              }
              .borderRadius(4)
              .backgroundColor('#6366F1')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // 右箭头
            Image($r('app.media.right'))
              .width(20)
              .height(20)
              .objectFit(ImageFit.Contain)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 20 })
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 12 })
          .onClick(() => {
            // 跳转到会员订阅页面（后续实现）
            console.info('跳转到会员订阅页面');
          })

          // 通用设置卡片
          Column() {
            // 消息通知
            Row() {
              Text('消息通知')
                .fontSize(16)
                .fontColor('#1F2937')
                .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.messageNotification })
                .selectedColor('#6366F1')
                .switchPointColor('#FFFFFF')
                .onChange(async (isOn: boolean) => {
                  this.messageNotification = isOn;
                  // 立即保存到服务器
                  await this.saveSettings();
                })
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .alignItems(VerticalAlign.Center)

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 自动保存
            Row() {
              Text('自动保存')
                .fontSize(16)
                .fontColor('#1F2937')
                .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.autoSave })
                .selectedColor('#6366F1')
                .switchPointColor('#FFFFFF')
                .onChange(async (isOn: boolean) => {
                  this.autoSave = isOn;
                  // 立即保存到服务器
                  await this.saveSettings();
                })
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .alignItems(VerticalAlign.Center)

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 默认输出质量
            Row() {
              Column() {
              Text('默认输出质量')
                .fontSize(16)
                .fontColor('#1F2937')
                  .margin({ bottom: 2 })

                Text('选择图片处理后的默认质量')
                  .fontSize(12)
                  .fontColor('#6B7280')
              }
              .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

              Row() {
              Text(this.defaultQualityDisplay)
                .fontSize(14)
                  .fontColor('#667eea')
                  .fontWeight(FontWeight.Medium)
                .margin({ right: 8 })

              Image(this.getQualityIcon(this.defaultQualityDisplay))
                .width(20)
                .height(20)
                .objectFit(ImageFit.Contain)
              }
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.showQualityPicker = !this.showQualityPicker;
            })

            // 质量选择器（展开时显示）
            if (this.showQualityPicker) {
              Column() {
                Divider()
                  .color('#E5E7EB')
                  .margin({ left: 20, right: 20, bottom: 12 })

                ForEach(this.qualityOptions, (option: QualityOption) => {
                  Row() {
                    Text(option.label)
                      .fontSize(14)
                      .fontColor(this.defaultQualityDisplay === option.label ? '#667eea' : '#1F2937')
                      .fontWeight(this.defaultQualityDisplay === option.label ? FontWeight.Medium : FontWeight.Regular)
                      .layoutWeight(1)

                    if (this.defaultQualityDisplay === option.label) {
                      Stack() {
                        Circle({ width: 20, height: 20 })
                          .fill('#667eea')
                        Text('✓')
                          .fontSize(12)
                          .fontColor('#FFFFFF')
                          .fontWeight(FontWeight.Medium)
                      }
                      .width(20)
                      .height(20)
                    }
                  }
                  .width('100%')
                  .height(44)
                  .padding({ left: 20, right: 20 })
                  .alignItems(VerticalAlign.Center)
                  .onClick(async () => {
                    this.defaultQualityDisplay = option.label;
                    this.defaultQuality = option.value;
                    this.showQualityPicker = false;
                    // 立即保存到服务器
                    await this.saveSettings();
                  })
                }, (option: QualityOption) => option.label)
              }
              .width('100%')
              .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
            }
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 存储空间卡片
          Column() {
            Row() {
              Text('存储空间')
                .fontSize(16)
                .fontColor('#1F2937')
                .layoutWeight(1)

              Text(`${this.storageUsed.toFixed(2)} GB / ${this.storageTotal > 0 ? this.storageTotal.toFixed(2) : '∞'} GB`)
                .fontSize(14)
                .fontColor('#6B7280')
                .margin({ right: 8 })

              Image($r('app.media.storage'))
                .width(20)
                .height(20)
                .objectFit(ImageFit.Contain)
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              // 跳转到存储空间详情（后续实现）
              console.info('跳转到存储空间详情');
            })

            // 存储进度条
            Column() {
            Row() {
                Text('已使用')
                  .fontSize(12)
                  .fontColor('#6B7280')
                Blank()
                Text(`${this.storageProgress.toFixed(1)}%`)
                  .fontSize(12)
                  .fontColor('#6B7280')
              }
              .width('100%')
              .margin({ bottom: 8 })

              // 进度条
              Stack() {
                // 背景
                Column()
                  .width('100%')
                  .height(8)
                  .backgroundColor('#E5E7EB')
                  .borderRadius(4)

                // 进度条（渐变）
                Column()
                  .width(`${this.storageProgress}%`)
                  .height(8)
                  .borderRadius(4)
                  .linearGradient({
                    angle: 90,
                    colors: [
                      ['#667eea', 0.0],
                      ['#764ba2', 1.0]
                    ]
                  })
              }
              .width('100%')
              .height(8)
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 16 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 帮助和关于卡片
          Column() {
            // 帮助
            Row() {
              Text('帮助')
                .fontSize(16)
                .fontColor('#1F2937')
                .layoutWeight(1)

              Image($r('app.media.help'))
                .width(20)
                .height(20)
                .objectFit(ImageFit.Contain)
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              // 跳转到帮助页面（后续实现）
              console.info('跳转到帮助页面');
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 关于
            Row() {
              Text('关于')
                .fontSize(16)
                .fontColor('#1F2937')
                .layoutWeight(1)

              Image($r('app.media.about'))
                .width(20)
                .height(20)
                .objectFit(ImageFit.Contain)
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              // 跳转到关于页面（后续实现）
              console.info('跳转到关于页面');
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 退出登录按钮
          Text('退出登录')
            .fontSize(16)
            .fontColor('#EF4444')
            .width('100%')
            .height(56)
            .textAlign(TextAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .onClick(() => {
              this.handleLogout();
            })
            .margin({ bottom: 20 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 20 })
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F9FAFB')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }
}

