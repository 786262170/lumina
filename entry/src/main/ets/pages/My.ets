import router from '@ohos.router';
import { UserService, UserInfo } from '../common/services/UserService';

@Entry
@Component
struct My {
  @State userInfo: UserInfo | null = null;
  @State processedCount: number = 0; // 已处理数量
  @State remainingQuota: number = 0; // 剩余额度
  @State membershipExpiry: string = ''; // 会员到期日期
  
  private userService: UserService = UserService.getInstance();

  aboutToAppear() {
    // 加载用户信息
    this.loadUserInfo();
    // 加载统计数据（模拟数据，后续可接入真实API）
    this.loadStatistics();
  }

  // 加载用户信息
  async loadUserInfo() {
    this.userInfo = await this.userService.getUserInfo();
  }

  // 加载统计数据
  loadStatistics() {
    // 模拟数据，后续可接入真实API
    this.processedCount = 0;
    this.remainingQuota = 10;
    this.membershipExpiry = '2025-12-31';
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('我的')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          // 用户信息卡片
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
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 20 })
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 12 })

          // 统计卡片
          Row() {
            // 已处理
            Column() {
              Text(this.processedCount.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
                .margin({ bottom: 4 })
              
              Text('已处理')
                .fontSize(12)
                .fontColor('#6B7280')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Divider()
              .vertical(true)
              .height(40)
              .color('#E5E7EB')

            // 剩余额度
            Column() {
              Text(this.remainingQuota.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
                .margin({ bottom: 4 })
              
              Text('剩余额度')
                .fontSize(12)
                .fontColor('#6B7280')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Divider()
              .vertical(true)
              .height(40)
              .color('#E5E7EB')

            // 会员到期
            Column() {
              Text(this.membershipExpiry || '--')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
                .margin({ bottom: 4 })
              
              Text('会员到期')
                .fontSize(12)
                .fontColor('#6B7280')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ top: 20, bottom: 20 })
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 12 })

          // 升级按钮
          Row() {
            Image($r('app.media.startIcon'))
              .width(24)
              .height(24)
              .fillColor('#FFFFFF')
              .margin({ right: 12 })

            Column() {
              Text($r('app.string.upgrade_pro'))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .margin({ bottom: 4 })

              Text($r('app.string.unlimited_use'))
                .fontSize(12)
                .fontColor('#FFFFFF')
                .opacity(0.9)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Image($r('app.media.startIcon'))
              .width(20)
              .height(20)
              .fillColor('#FFFFFF')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })
          .borderRadius(12)
          .linearGradient({
            angle: 0,
            colors: [
              ['#6366F1', 0],
              ['#8B5CF6', 1]
            ]
          })
          .margin({ bottom: 12 })
          .onClick(() => {
            // 跳转到升级页面（后续实现）
            console.info('跳转到升级页面');
          })

          // 菜单列表
          Column() {
            // 我的作品
            this.buildMenuItem('我的作品', () => {
              router.pushUrl({ url: 'pages/MyWorks' }).catch((err: Error) => {
                console.error(`跳转失败: ${err.message}`);
              });
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 订单记录
            this.buildMenuItem('订单记录', () => {
              console.info('跳转到订单记录页面');
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 邀请有礼
            this.buildMenuItem('邀请有礼', () => {
              console.info('跳转到邀请有礼页面');
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 客服中心
            this.buildMenuItem('客服中心', () => {
              console.info('跳转到客服中心页面');
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 设置
            this.buildMenuItem('设置', () => {
              router.pushUrl({ url: 'pages/Settings' }).catch((err: Error) => {
                console.error(`跳转失败: ${err.message}`);
              });
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 关于我们
            this.buildMenuItem('关于我们', () => {
              console.info('跳转到关于我们页面');
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 12 })
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

  // 构建菜单项
  @Builder
  buildMenuItem(title: string, onClick: () => void) {
    Row() {
      Text(title)
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
    .onClick(onClick)
  }
}

