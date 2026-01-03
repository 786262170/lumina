import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';
import { UserService, UserInfo } from '../common/services/UserService';
import { UserApiService } from '../common/services/UserApiService';
import { AuthService } from '../common/services/AuthService';
import { TabBar } from '../common/components/TabBar';

@Entry
@Component
struct My {
  @State userInfo: UserInfo | null = null;
  @State processedCount: number = 0; // 已处理数量
  @State remainingQuota: number = 0; // 剩余额度
  @State membershipExpiry: string = ''; // 会员到期日期
  @State menuBadges: Record<string, boolean> = {
    '订单记录': true,
    '邀请有礼': false,
    '客服中心': false
  };
  
  private userService: UserService = UserService.getInstance();
  private userApiService: UserApiService = UserApiService.getInstance();
  private authService: AuthService = AuthService.getInstance();

  aboutToAppear() {
    // 加载用户信息
    this.loadUserInfo();
    // 加载统计数据
    this.loadStatistics();
  }

  // 加载用户信息
  async loadUserInfo() {
    try {
      // 先从本地获取
      this.userInfo = await this.userService.getUserInfo();
      
      // 然后从API获取最新信息
      const profile = await this.userApiService.getUserProfile();
      // 更新本地用户信息
      if (this.userInfo) {
        this.userInfo.nickname = profile.nickname;
        await this.userService.saveUserInfo(this.userInfo);
      }
    } catch (error) {
      console.error(`加载用户信息失败: ${error.message}`);
    }
  }

  // 加载统计数据
  async loadStatistics() {
    try {
      const stats = await this.userApiService.getUserStats();
      this.processedCount = stats.processedCount;
      this.remainingQuota = stats.remainingQuota;
      
      // 格式化会员到期日期
      if (stats.membershipDaysLeft !== undefined && stats.membershipDaysLeft > 0) {
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + stats.membershipDaysLeft);
        this.membershipExpiry = expiryDate.toISOString().split('T')[0];
      } else {
        this.membershipExpiry = '';
      }
    } catch (error) {
      console.error(`加载统计数据失败: ${error.message}`);
      // 使用默认值
      this.processedCount = 0;
      this.remainingQuota = 10;
      this.membershipExpiry = '';
    }
  }

  // 返回上一页
  async handleBack() {
    console.info('[My] handleBack 被调用');
    const routerService = RouterService.getInstance();
    const routeHistory = routerService.getRouteHistory();
    
    // 检查路由历史，判断是否应该返回到首页
    // 如果是 Tab 页面（通过 replace 进入），历史栈可能只有当前页面
    // 此时应该返回到首页
    if (routeHistory.length <= 1) {
      // 历史栈只有一页或为空，返回到首页
      console.info('[My] 路由历史栈为空，返回到首页');
      try {
        await routerService.navigateTo('pages/Index', undefined, true);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        console.error(`[My] 跳转首页失败: ${errorMsg}`);
      }
    } else {
      // 尝试返回上一页
      try {
        await routerService.goBack();
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : String(err);
        console.error(`[My] 返回失败: ${errorMsg}`);
        // 如果返回失败，则返回到首页
        try {
          await routerService.navigateTo('pages/Index', undefined, true);
        } catch (error) {
          const navErrorMsg = error instanceof Error ? error.message : String(error);
          console.error(`[My] 跳转首页失败: ${navErrorMsg}`);
        }
      }
    }
  }

  // 构建菜单项
  @Builder
  buildMenuItem(title: string, iconName: string, showBadge: boolean, onClick: () => void) {
    Row() {
      // 左侧图标
      Stack() {
        Image($r('app.media.startIcon'))
          .width(20)
          .height(20)
          .fillColor('#6B7280')

        // 红点通知
        if (showBadge) {
          Stack() {
            Circle({ width: 8, height: 8 })
              .fill('#EF4444')
          }
          .width(8)
          .height(8)
          .position({ x: 12, y: -2 })
        }
      }
      .width(24)
      .height(24)
      .margin({ right: 12 })

      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
        .fontColor('#1A1F36')
        .layoutWeight(1)

      // 右侧箭头
      Image($r('app.media.startIcon'))
        .width(20)
        .height(20)
        .fillColor('#6B7280')
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .alignItems(VerticalAlign.Center)
    .onClick(onClick)
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        // 返回按钮
        Button() {
          Text('<')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1F36')
        }
        .type(ButtonType.Normal)
        .width(40)
        .height(40)
        .backgroundColor('#F8F9FC')
        .borderRadius(8)
        .onClick(async () => {
          console.info('[My] 返回按钮被点击');
          await this.handleBack();
        })

        // 标题
        Text('我的')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1F36')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: -40 })

        // 占位，保持标题居中
        Blank()
          .width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })

      Scroll() {
        Column() {
          // 用户信息卡片
          Row() {
            // 头像
            Stack() {
              Circle({ width: 60, height: 60 })
                .fill('#E5E7EB')

              Image($r('app.media.startIcon'))
                .width(40)
                .height(40)
                .fillColor('#6B7280')
            }
            .width(60)
            .height(60)
            .margin({ right: 16 })

            // 用户信息
            Column() {
              Text(this.userInfo?.nickname || this.userInfo?.phone || '游客')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1F36')
                .margin({ bottom: 8 })

              // 会员标签
              Row() {
                Text('会员')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              }
              .borderRadius(4)
              .backgroundColor('#667eea')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 20 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 统计卡片
          Row() {
            // 已处理
            Column() {
              Text(this.processedCount.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1F36')
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
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1F36')
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
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1F36')
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
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 升级按钮
          Row() {
            // 左侧图标
            Stack() {
              Circle({ width: 32, height: 32 })
                .fill('#FFFFFF')
                .opacity(0.2)
            }
            .width(32)
            .height(32)
            .margin({ right: 12 })

            Image($r('app.media.startIcon'))
              .width(24)
              .height(24)
              .fillColor('#FFFFFF')
              .position({ x: 4, y: 4 })

            // 中间文字
            Column() {
              Text($r('app.string.upgrade_pro'))
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .margin({ bottom: 2 })

              Text($r('app.string.unlimited_use'))
                .fontSize(14)
                .fontColor('#FFFFFF')
                .opacity(0.9)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // 右侧箭头
            Image($r('app.media.startIcon'))
              .width(24)
              .height(24)
              .fillColor('#FFFFFF')
          }
          .width('100%')
          .height(80)
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })
          .borderRadius(16)
          .linearGradient({
            angle: 135,
            colors: [
              ['#667eea', 0.0],
              ['#764ba2', 1.0]
            ]
          })
          .shadow({
            radius: 12,
            color: '#667eea',
            offsetX: 0,
            offsetY: 4
          })
          .margin({ bottom: 12 })
          .onClick(() => {
            // 跳转到升级页面
            RouterService.getInstance().navigateTo('pages/MemberSubscription')
              .catch((err: Error) => {
                console.error(`跳转失败: ${err.message}`);
              });
          })

          // 菜单列表
          Column() {
            // 我的作品
            this.buildMenuItem('我的作品', 'Image', false, async () => {
              // 切换到Tab 2 (作品页)
              await RouterService.getInstance().switchTab(2)
                .catch((err: Error) => {
                  console.error(`切换Tab失败: ${err.message}`);
                });
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 订单记录
            this.buildMenuItem('订单记录', 'FileText', this.menuBadges['订单记录'], () => {
              console.info('跳转到订单记录页面');
              // 点击后清除红点
              this.menuBadges['订单记录'] = false;
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 邀请有礼
            this.buildMenuItem('邀请有礼', 'Gift', this.menuBadges['邀请有礼'], () => {
              console.info('跳转到邀请有礼页面');
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 客服中心
            this.buildMenuItem('客服中心', 'Headphones', this.menuBadges['客服中心'], () => {
              console.info('跳转到客服中心页面');
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 设置
            this.buildMenuItem('设置', 'Settings', false, () => {
              RouterService.getInstance().navigateTo('pages/Settings')
                .catch((err: Error) => {
                  console.error(`跳转失败: ${err.message}`);
                });
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 关于我们
            this.buildMenuItem('关于我们', 'Info', false, () => {
              console.info('跳转到关于我们页面');
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 12 })
          .shadow({
            radius: 2,
            color: '#000000',
            offsetX: 0,
            offsetY: 1
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 20 })
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F9FAFB')

      // 底部导航栏
      TabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FC')
  }
}

