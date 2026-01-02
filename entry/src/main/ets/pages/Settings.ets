import router from '@ohos.router';
import { UserService, UserInfo } from '../common/services/UserService';

@Entry
@Component
struct Settings {
  @State userInfo: UserInfo | null = null;
  @State messageNotification: boolean = true; // 消息通知开关
  @State autoSave: boolean = true; // 自动保存开关
  @State defaultQuality: string = '高清'; // 默认输出质量
  @State storageUsed: string = '0 MB'; // 已用存储空间
  @State storageTotal: string = '100 MB'; // 总存储空间
  @State storageProgress: number = 0; // 存储进度百分比
  
  private userService: UserService = UserService.getInstance();
  
  // 输出质量选项
  private qualityOptions: string[] = ['高清', '标准', '压缩'];

  aboutToAppear() {
    // 加载用户信息
    this.loadUserInfo();
    // 加载存储空间信息（模拟数据，后续可接入真实API）
    this.loadStorageInfo();
  }

  // 加载用户信息
  async loadUserInfo() {
    this.userInfo = await this.userService.getUserInfo();
  }

  // 加载存储空间信息
  loadStorageInfo() {
    // 模拟数据，后续可接入真实API
    this.storageUsed = '45.2 MB';
    this.storageTotal = '100 MB';
    // 计算进度百分比（简化处理，假设单位都是MB）
    const used = parseFloat(this.storageUsed);
    const total = parseFloat(this.storageTotal);
    this.storageProgress = total > 0 ? (used / total) * 100 : 0;
  }

  // 退出登录
  async handleLogout() {
    await this.userService.logout();
    // 跳转到登录页面
    router.replaceUrl({ url: 'pages/Login' }).catch((err: Error) => {
      console.error(`跳转失败: ${err.message}`);
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 返回按钮
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor('#1F2937')
          .onClick(() => {
            router.back();
          })

        // 标题
        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: -24 })

        // 占位，保持标题居中
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .opacity(0)
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })

      Scroll() {
        Column() {
          // 用户资料和会员卡片
          Row() {
            // 头像
            Image($r('app.media.startIcon'))
              .width(60)
              .height(60)
              .borderRadius(30)
              .backgroundColor('#E5E7EB')
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
            Image($r('app.media.startIcon'))
              .width(20)
              .height(20)
              .fillColor('#9CA3AF')
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
                .onChange((isOn: boolean) => {
                  this.messageNotification = isOn;
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
                .onChange((isOn: boolean) => {
                  this.autoSave = isOn;
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
              Text('默认输出质量')
                .fontSize(16)
                .fontColor('#1F2937')
                .layoutWeight(1)

              Text(this.defaultQuality)
                .fontSize(14)
                .fontColor('#6B7280')
                .margin({ right: 8 })

              Image($r('app.media.startIcon'))
                .width(20)
                .height(20)
                .fillColor('#9CA3AF')
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              // 显示质量选择器（后续实现）
              console.info('显示质量选择器');
            })
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

              Text(`${this.storageUsed} / ${this.storageTotal}`)
                .fontSize(14)
                .fontColor('#6B7280')
                .margin({ right: 8 })

              Image($r('app.media.startIcon'))
                .width(20)
                .height(20)
                .fillColor('#9CA3AF')
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
            Row() {
              // 进度条背景
              Row() {
                // 已用部分（紫色）
                Row()
                  .width(`${this.storageProgress}%`)
                  .height(4)
                  .backgroundColor('#6366F1')
                  .borderRadius(2)
              }
              .width('100%')
              .height(4)
              .backgroundColor('#E5E7EB')
              .borderRadius(2)
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

              Image($r('app.media.startIcon'))
                .width(20)
                .height(20)
                .fillColor('#9CA3AF')
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

              Image($r('app.media.startIcon'))
                .width(20)
                .height(20)
                .fillColor('#9CA3AF')
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

