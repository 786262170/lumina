import router from '@ohos.router';
import { UserService, UserInfo } from '../common/services/UserService';
import { AuthService } from '../common/services/AuthService';
import { WorkService } from '../common/services/WorkService';
import { RouterService } from '../common/services/RouterService';
import { SceneService } from '../common/services/SceneService';
import { promptAction } from '@kit.ArkUI';
import { ScenarioItem, RecentWork } from '../common/types/CommonTypes';
import { TabBar } from '../common/components/TabBar';

@Entry
@Component
struct Index {
  // 快速场景数据（从API获取）
  @State scenarios: ScenarioItem[] = [];

  @State userInfo: UserInfo | null = null;
  // 最近作品列表
  @State recentWorks: RecentWork[] = [];
  // 当前选中的场景
  @State selectedSceneId: string | null = null;
  // 场景加载状态
  @State isLoadingScenes: boolean = false;

  private userService: UserService = UserService.getInstance();
  private authService: AuthService = AuthService.getInstance();
  private workService: WorkService = WorkService.getInstance();
  private routerService: RouterService = RouterService.getInstance();
  private sceneService: SceneService = SceneService.getInstance();

  aboutToAppear() {
    // 加载用户信息
    this.loadUserInfo();
    // 加载最近作品
    this.loadRecentWorks();
    // 加载场景列表
    this.loadScenes();
  }

  // 加载场景列表
  async loadScenes() {
    try {
      this.isLoadingScenes = true;
      const response = await this.sceneService.getScenes();
      
      // 将API返回的场景数据转换为ScenarioItem格式
      const scenarioItems: ScenarioItem[] = [];
      for (let i = 0; i < response.scenes.length; i++) {
        const scene = response.scenes[i];
        // 根据场景类型映射图标（如果API没有返回图标，使用默认图标）
        let icon: Resource = $r('app.media.zidingyi'); // 默认图标
        switch (scene.type) {
          case 'taobao':
            icon = $r('app.media.taobao');
            break;
          case 'douyin':
            icon = $r('app.media.douyin');
            break;
          case 'xiaohongshu':
            icon = $r('app.media.xiaohongshu');
            break;
          case 'amazon':
            icon = $r('app.media.amazon');
            break;
          case 'custom':
            icon = $r('app.media.zidingyi');
            break;
        }
        
        scenarioItems.push({
          id: scene.type,
          title: scene.title,
          icon: icon,
          route: 'pages/ScenarioDetail'
        });
      }
      
      // 添加批量处理选项（这个不在API返回的场景列表中）
      scenarioItems.push({
        id: 'batch',
        title: '批量处理',
        icon: $r('app.media.batch'),
        route: 'pages/BatchProcess'
      });
      
      this.scenarios = scenarioItems;
      console.info(`[Index] 成功加载 ${scenarioItems.length} 个场景`);
    } catch (error) {
      console.error(`[Index] 加载场景列表失败: ${error}`);
      // 如果加载失败，使用默认场景列表作为后备
      this.scenarios = [
        {
          id: 'taobao',
          title: '淘宝白底图',
          icon: $r('app.media.taobao'),
          route: 'pages/ScenarioDetail'
        },
        {
          id: 'douyin',
          title: '抖音商品图',
          icon: $r('app.media.douyin'),
          route: 'pages/ScenarioDetail'
        },
        {
          id: 'xiaohongshu',
          title: '小红书封面',
          icon: $r('app.media.xiaohongshu'),
          route: 'pages/ScenarioDetail'
        },
        {
          id: 'batch',
          title: '批量处理',
          icon: $r('app.media.batch'),
          route: 'pages/BatchProcess'
        },
        {
          id: 'amazon',
          title: '亚马逊产品图',
          icon: $r('app.media.amazon'),
          route: 'pages/ScenarioDetail'
        },
        {
          id: 'custom',
          title: '自定义制作',
          icon: $r('app.media.zidingyi'),
          route: 'pages/ScenarioDetail'
        }
      ];
    } finally {
      this.isLoadingScenes = false;
    }
  }

  // 加载用户信息
  async loadUserInfo() {
    this.userInfo = await this.userService.getUserInfo();
  }

  // 加载最近作品
  async loadRecentWorks() {
    try {
      const response = await this.workService.getWorks(1, 6); // 获取前6个作品
      const works: RecentWork[] = [];
      for (let i = 0; i < response.works.length; i++) {
        const work = response.works[i];
        const recentWork: RecentWork = {
          id: work.id,
          filename: work.filename,
          thumbnail: work.thumbnail || '',
          createdAt: work.createdAt
        };
        works.push(recentWork);
      }
      this.recentWorks = works;
    } catch (error) {
      console.error(`加载最近作品失败: ${error.message}`);
      this.recentWorks = [];
    }
  }

  // 退出登录
  async handleLogout() {
    try {
      await this.authService.logout();
    } catch (error) {
      console.error(`退出登录失败: ${error.message}`);
    } finally {
    await this.userService.logout();
    this.userInfo = null;
    // 跳转到登录页
      RouterService.getInstance().navigateTo('pages/Login', undefined, true)
        .catch((err: Error) => {
          console.error(`跳转失败: ${err.message}`);
        });
    }
  }

  build() {
    Column() {
      // 顶部导航栏
        Row() {
        // Logo
        Text('Lumina')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor('#667eea')
          .letterSpacing(-0.02)
          .layoutWeight(1)

        // 右侧图标按钮
        Row() {
          // 用户头像
          Button() {
            Image($r('app.media.touxiang'))
              .width(32)
              .height(32)
              .borderRadius(16)
              .objectFit(ImageFit.Cover)
          }
          .type(ButtonType.Circle)
          .width(40)
          .height(40)
          .backgroundColor('#F8F9FC')
          .margin({ left: 8 })
              .onClick(() => {
            // 可以跳转到个人中心或我的页面
            RouterService.getInstance().switchTab(3)
              .catch((err: Error) => {
                console.error(`切换Tab失败: ${err.message}`);
              });
          })

          // 设置按钮
          Button() {
            Image($r('app.media.settings'))
              .width(24)
              .height(24)
          }
          .type(ButtonType.Circle)
          .width(40)
          .height(40)
          .backgroundColor('#F8F9FC')
          .margin({ left: 8 })
          .onClick(() => {
            RouterService.getInstance().navigateTo('pages/Settings')
              .catch((err: Error) => {
                console.error(`跳转失败: ${err.message}`);
              });
              })
          }
        }
        .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })

      // 主内容区域
      Scroll() {
        Column() {
          // 问候语区域
          Column() {
            Text('你好，' + (this.userInfo?.nickname || this.userInfo?.phone || '创作者'))
              .fontSize(28)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1F36')
        .margin({ bottom: 8 })

        Text($r('app.string.scenario_question'))
          .fontSize(16)
              .fontWeight(FontWeight.Regular)
          .fontColor('#6B7280')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 20, bottom: 24 })

        // 快速场景标题
        Text($r('app.string.quick_scenarios'))
          .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1F36')
          .margin({ bottom: 16 })
          .width('100%')

        // 场景网格
        Grid() {
          ForEach(this.scenarios, (item: ScenarioItem) => {
            GridItem() {
              Column() {
                  // 图标背景（渐变圆形，带渐变效果）
                  Stack() {
                    Circle({ width: 64, height: 64 })
                      .fill(this.selectedSceneId === item.id ? '#F8F9FC' : '#F8F9FC')
                      .opacity(this.selectedSceneId === item.id ? 1 : 0.8)

                    // 渐变背景层（模拟渐变效果）
                    Circle({ width: 64, height: 64 })
                      .fill('#667eea')
                      .opacity(0.1)

                    // zhuanye图标作为装饰背景
                    Image($r('app.media.zhuanye'))
                      .width(40)
                      .height(40)
                      .objectFit(ImageFit.Contain)
                      .opacity(0.15)

                    // 图标（使用圆形裁剪，让方形图标匹配圆形轮廓）
                Image(item.icon)
                      .width(48)
                      .height(48)
                      .borderRadius(24)
                      .objectFit(ImageFit.Cover)
                  }
                  .width(64)
                  .height(64)
                  .alignContent(Alignment.Center)
                  .margin({ bottom: 12 })

                Text(item.title)
                    .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                    .fontColor('#1A1F36')
                  .margin({ bottom: 4 })

                Text($r('app.string.one_click_generate'))
                    .fontSize(14)
                  .fontColor('#6B7280')
              }
              .width('100%')
                .height(144)
              .justifyContent(FlexAlign.Center)
              .padding(16)
                .borderRadius(16)
                .border({
                  width: this.selectedSceneId === item.id ? 2 : 2,
                  color: this.selectedSceneId === item.id ? '#667eea' : '#E5E7EB'
                })
                .backgroundColor(this.selectedSceneId === item.id ? '#F8F9FC' : '#FFFFFF')
                .shadow({
                  radius: this.selectedSceneId === item.id ? 8 : 0,
                  color: this.selectedSceneId === item.id ? '#667eea' : '#000000',
                  offsetX: 0,
                  offsetY: this.selectedSceneId === item.id ? 4 : 0
                })
              .onClick(async () => {
                  // 切换选中状态
                  this.selectedSceneId = this.selectedSceneId === item.id ? null : item.id;
                  
                  // 将 string 类型的 route 转换为 Route 类型
                  const targetRoute = item.route as 'pages/ScenarioDetail' | 'pages/BatchProcess';
                  const params: Record<string, string | number | boolean | string[] | undefined> = {} as Record<string, string | number | boolean | string[] | undefined>;
                  params['scenarioId'] = item.id;
                  params['scenarioTitle'] = item.title;
                  
                  try {
                    console.info(`[Index] 准备跳转到: ${targetRoute}, scenarioId: ${item.id}, title: ${item.title}`);
                    await RouterService.getInstance().navigateTo(targetRoute, params);
                    console.info(`[Index] 跳转成功: ${targetRoute}`);
                  } catch (err) {
                    const errorMsg = err instanceof Error ? err.message : String(err);
                    console.error(`[Index] 跳转失败: ${errorMsg}`);
                    // 使用提示框显示错误，方便用户看到
                    promptAction.showToast({
                      message: `跳转失败: ${errorMsg}`,
                      duration: 2000
                    });
                  }
              })
            }
          }, (item: ScenarioItem) => item.id)
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
          .height(456)
        .margin({ bottom: 24 })

          // 最近作品区域
          if (this.recentWorks.length > 0) {
            Column() {
              // 区域标题和查看全部
              Row() {
                Text('最近作品')
                  .fontSize(20)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1F36')
                  .layoutWeight(1)

                Row() {
                  Text('查看全部')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#667eea')

                  Text('>')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#667eea')
                    .margin({ left: 4 })
                }
                .onClick(async () => {
                  // 切换到Tab 2 (作品页)
                  await RouterService.getInstance().switchTab(2)
                    .catch((err: Error) => {
                      console.error(`切换Tab失败: ${err.message}`);
                    });
                })
              }
              .width('100%')
              .margin({ bottom: 16 })

              // 作品图片横向滚动（第一行）
              Scroll() {
                Row() {
                  ForEach(this.recentWorks.slice(0, 5), (work: RecentWork) => {
                    Image(work.thumbnail || $r('app.media.startIcon'))
                      .width(143)
                      .height(143)
                      .borderRadius(12)
                      .objectFit(ImageFit.Cover)
                      .backgroundColor('#E5E7EB')
                      .margin({ right: 8 })
                      .shadow({
                        radius: 4,
                        color: '#000000',
                        offsetX: 0,
                        offsetY: 2
                      })
                      .onClick(() => {
                        // 跳转到作品详情
                        const params: Record<string, string | number | boolean | string[] | undefined> = {} as Record<string, string | number | boolean | string[] | undefined>;
                        params['workId'] = work.id;
                        RouterService.getInstance().navigateTo('pages/ProcessResult', params).catch((err: Error) => {
                          console.error(`跳转失败: ${err.message}`);
                        });
                      })
                  }, (work: RecentWork) => work.id)
                }
                .padding({ left: 0, right: 0 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              .margin({ left: -16, right: -16, bottom: 8 })
              .padding({ left: 16, right: 16 })

              // 文件名横向滚动（第二行）
              Scroll() {
                Row() {
                  ForEach(this.recentWorks.slice(0, 5), (work: RecentWork) => {
                    Text(work.filename)
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor('#6B7280')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width(143)
                      .textAlign(TextAlign.Center)
                      .margin({ right: 8 })
                  }, (work: RecentWork) => `name-${work.id}`)
                }
                .padding({ left: 0, right: 0 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              .margin({ left: -16, right: -16 })
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .margin({ bottom: 24 })
          }

          // 升级专业版横幅
        Row() {
            // 左侧图标
            Stack() {
              Circle({ width: 32, height: 32 })
                .fill('#FFFFFF')
                .opacity(0.2)
              
              Image($r('app.media.zhuanye'))
                .width(24)
                .height(24)
                .objectFit(ImageFit.Contain)
            }
            .width(32)
            .height(32)
            .alignContent(Alignment.Center)
            .margin({ right: 12 })

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
          Image($r('app.media.right'))
              .width(20)
              .height(20)
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
          .onClick(() => {
            // 跳转到升级页面
            RouterService.getInstance().navigateTo('pages/MemberSubscription')
              .catch((err: Error) => {
                console.error(`跳转失败: ${err.message}`);
              });
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 0, bottom: 24 })
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F8F9FC')

      // 底部导航栏
      TabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FC')
  }
}
