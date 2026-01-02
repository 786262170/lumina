import router from '@ohos.router';
import { UserService, UserInfo } from '../common/services/UserService';
import { promptAction } from '@kit.ArkUI';
import { ScenarioItem } from '../common/types/CommonTypes';

@Entry
@Component
struct Index {
  // 快速场景数据
  private scenarios: ScenarioItem[] = [
    {
      id: 'taobao',
      title: '淘宝白底图',
      icon: $r('app.media.startIcon'), // 使用购物袋图标，后续可替换
      route: 'pages/ScenarioDetail'
    },
    {
      id: 'douyin',
      title: '抖音商品图',
      icon: $r('app.media.startIcon'), // 使用视频图标，后续可替换
      route: 'pages/ScenarioDetail'
    },
    {
      id: 'xiaohongshu',
      title: '小红书封面',
      icon: $r('app.media.startIcon'), // 使用图片图标，后续可替换
      route: 'pages/ScenarioDetail'
    },
    {
      id: 'batch',
      title: '批量处理',
      icon: $r('app.media.startIcon'), // 使用批量图标，后续可替换
      route: 'pages/BatchProcess'
    },
    {
      id: 'amazon',
      title: '亚马逊产品图',
      icon: $r('app.media.startIcon'), // 使用3D图标，后续可替换
      route: 'pages/ScenarioDetail'
    },
    {
      id: 'custom',
      title: '自定义制作',
      icon: $r('app.media.startIcon'), // 使用魔法棒图标，后续可替换
      route: 'pages/ScenarioDetail'
    }
  ];

  // 当前选中的底部导航
  @State currentTab: number = 0;
  @State userInfo: UserInfo | null = null;

  private userService: UserService = UserService.getInstance();

  aboutToAppear() {
    // 加载用户信息
    this.loadUserInfo();
  }

  // 加载用户信息
  async loadUserInfo() {
    this.userInfo = await this.userService.getUserInfo();
  }

  // 退出登录
  async handleLogout() {
    await this.userService.logout();
    this.userInfo = null;
    // 跳转到登录页
    router.replaceUrl({ url: 'pages/Login' });
  }

  build() {
    Column() {
      // 顶部内容区域
      Column() {
        // 顶部栏（问候语 + 用户信息/退出按钮）
        Row() {
          Column() {
            // 问候语
            Text($r('app.string.greeting'))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2937')
              .margin({ bottom: 4 })

            // 用户信息显示
            if (this.userInfo) {
              Text(this.userInfo.nickname || this.userInfo.phone)
                .fontSize(14)
                .fontColor('#6B7280')
            } else {
              Text('游客模式')
                .fontSize(14)
                .fontColor('#6B7280')
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          // 退出登录按钮（调试用）
          if (this.userInfo) {
            Button('退出')
              .type(ButtonType.Normal)
              .fontSize(12)
              .fontColor('#EF4444')
              .backgroundColor('#FEE2E2')
              .border({ width: 1, color: '#EF4444' })
              .borderRadius(6)
              .height(32)
              .width(60)
              .onClick(() => {
                promptAction.showDialog({
                  title: '确认退出',
                  message: '确定要退出登录吗？',
                  buttons: [
                    {
                      text: '取消',
                      color: '#000000'
                    },
                    {
                      text: '确定',
                      color: '#007DFF'
                    }
                  ]
                }).then((result: promptAction.ShowDialogSuccessResponse) => {
                  if (result.index === 1) {
                    this.handleLogout();
                  }
                }).catch((err: Error) => {
                  console.error(`显示对话框失败: ${err.message}`);
                });
              })
          } else {
            // 跳转登录按钮
            Button('登录')
              .type(ButtonType.Normal)
              .fontSize(12)
              .fontColor('#3B82F6')
              .backgroundColor('#EFF6FF')
              .border({ width: 1, color: '#3B82F6' })
              .borderRadius(6)
              .height(32)
              .width(60)
              .onClick(() => {
                router.pushUrl({ url: 'pages/Login' });
              })
          }
        }
        .width('100%')
        .margin({ bottom: 8 })

        // 问题提示
        Text($r('app.string.scenario_question'))
          .fontSize(16)
          .fontColor('#6B7280')
          .margin({ bottom: 24 })
          .width('100%')

        // 快速场景标题
        Text($r('app.string.quick_scenarios'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ bottom: 16 })
          .width('100%')

        // 场景网格
        Grid() {
          ForEach(this.scenarios, (item: ScenarioItem) => {
            GridItem() {
              Column() {
                Image(item.icon)
                  .width(40)
                  .height(40)
                  .margin({ bottom: 12 })

                Text(item.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1F2937')
                  .margin({ bottom: 4 })

                Text($r('app.string.one_click_generate'))
                  .fontSize(12)
                  .fontColor('#6B7280')
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .padding(16)
              .borderRadius(12)
              .border({ width: 1, color: '#E5E7EB' })
              .backgroundColor('#FFFFFF')
              .onClick(() => {
                // 跳转到场景详情页
                router.pushUrl({
                  url: item.route,
                  params: {
                    scenarioId: item.id,
                    scenarioTitle: item.title
                  }
                }).catch((err: Error) => {
                  console.error(`跳转失败: ${err.message}`);
                });
              })
            }
          }, (item: ScenarioItem) => item.id)
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
        .height(420)
        .margin({ bottom: 24 })

        // 升级专业版按钮
        Row() {
          Image($r('app.media.startIcon'))
            .width(24)
            .height(24)
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
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .borderRadius(12)
        .backgroundColor('#6366F1')
        .onClick(() => {
          // 跳转到升级页面（后续实现）
          console.info('跳转到升级页面');
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20 })
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 底部导航栏
      Row() {
        // 首页
        Column() {
          Image($r('app.media.startIcon'))
            .width(24)
            .height(24)
            .fillColor(this.currentTab === 0 ? '#3B82F6' : '#9CA3AF')

          Text($r('app.string.homepage'))
            .fontSize(12)
            .fontColor(this.currentTab === 0 ? '#3B82F6' : '#9CA3AF')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 0;
        })

        // 场景
        Column() {
          Image($r('app.media.startIcon'))
            .width(24)
            .height(24)
            .fillColor(this.currentTab === 1 ? '#3B82F6' : '#9CA3AF')

          Text($r('app.string.scenarios'))
            .fontSize(12)
            .fontColor(this.currentTab === 1 ? '#3B82F6' : '#9CA3AF')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 1;
          // 跳转到场景页面（后续实现）
          console.info('跳转到场景页面');
        })

        // 作品
        Column() {
          Image($r('app.media.startIcon'))
            .width(24)
            .height(24)
            .fillColor(this.currentTab === 2 ? '#3B82F6' : '#9CA3AF')

          Text($r('app.string.works'))
            .fontSize(12)
            .fontColor(this.currentTab === 2 ? '#3B82F6' : '#9CA3AF')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 2;
          // 跳转到作品页面
          router.pushUrl({ url: 'pages/MyWorks' }).catch((err: Error) => {
            console.error(`跳转失败: ${err.message}`);
          });
        })

        // 我的
        Column() {
          Image($r('app.media.startIcon'))
            .width(24)
            .height(24)
            .fillColor(this.currentTab === 3 ? '#3B82F6' : '#9CA3AF')

          Text($r('app.string.my'))
            .fontSize(12)
            .fontColor(this.currentTab === 3 ? '#3B82F6' : '#9CA3AF')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 3;
          // 跳转到我的页面
          router.pushUrl({ url: 'pages/My' }).catch((err: Error) => {
            console.error(`跳转失败: ${err.message}`);
          });
        })
      }
      .width('100%')
      .height(60)
      .padding({ top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 1 }, color: '#E5E7EB' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }
}
