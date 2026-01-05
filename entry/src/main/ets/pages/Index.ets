import router from '@ohos.router';
import { UserService, UserInfo } from '../common/services/UserService';
import { AuthService } from '../common/services/AuthService';
import { WorkService } from '../common/services/WorkService';
import { RouterService } from '../common/services/RouterService';
import { SceneService } from '../common/services/SceneService';
import { promptAction } from '@kit.ArkUI';
import { ScenarioItem, RecentWork } from '../common/types/CommonTypes';
import { TabBar } from '../common/components/TabBar';
import { LuminaColors, LuminaSpacing, LuminaRadius, LuminaTypography, LuminaLayout, LuminaSizes } from '../common/DesignSystem';

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
          .fontSize(LuminaTypography.TITLE)
          .fontWeight(LuminaTypography.WEIGHT_MEDIUM)
          .fontColor(LuminaColors.PRIMARY_BLUE)
          .letterSpacing(-0.02)
          .layoutWeight(1)

        // 右侧图标按钮
        Row() {
          // 用户头像
          Button() {
            Image($r('app.media.touxiang'))
              .width(LuminaSizes.AVATAR_SM)
              .height(LuminaSizes.AVATAR_SM)
              .borderRadius(LuminaSizes.AVATAR_SM / 2)
              .objectFit(ImageFit.Cover)
          }
          .type(ButtonType.Circle)
          .width(LuminaSizes.AVATAR_MD)
          .height(LuminaSizes.AVATAR_MD)
          .backgroundColor(LuminaColors.BG_PRIMARY)
          .margin({ left: LuminaSpacing.SM })
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
              .width(LuminaSizes.ICON_MD)
              .height(LuminaSizes.ICON_MD)
          }
          .type(ButtonType.Circle)
          .width(LuminaSizes.AVATAR_MD)
          .height(LuminaSizes.AVATAR_MD)
          .backgroundColor(LuminaColors.BG_PRIMARY)
          .margin({ left: LuminaSpacing.SM })
          .onClick(() => {
            RouterService.getInstance().navigateTo('pages/Settings')
              .catch((err: Error) => {
                console.error(`跳转失败: ${err.message}`);
              });
          })
        }
      }
      .width('100%')
      .height(LuminaSizes.NAV_BAR_HEIGHT)
      .padding({ left: LuminaLayout.PAGE_PADDING_H, right: LuminaLayout.PAGE_PADDING_H })
      .backgroundColor(LuminaColors.BG_SURFACE)
      .border({ width: { bottom: 1 }, color: LuminaColors.BORDER })

      // 主内容区域
      Scroll() {
        Column() {
          // 问候语区域
          Column() {
            Text('你好，' + (this.userInfo?.nickname || this.userInfo?.phone || '创作者'))
              .fontSize(LuminaTypography.HEADLINE)
              .fontWeight(LuminaTypography.WEIGHT_MEDIUM)
              .fontColor(LuminaColors.TEXT_PRIMARY)
              .margin({ bottom: LuminaSpacing.SM })

            Text($r('app.string.scenario_question'))
              .fontSize(LuminaTypography.BODY)
              .fontWeight(LuminaTypography.WEIGHT_REGULAR)
              .fontColor(LuminaColors.TEXT_SECONDARY)
          }
          .width('100%')
          .alignItems(LuminaLayout.ALIGN_START)
          .margin({ top: LuminaSpacing.MD, bottom: LuminaLayout.SECTION_SPACING })

        // 快速场景标题
        Text($r('app.string.quick_scenarios'))
          .fontSize(LuminaTypography.TITLE)
          .fontWeight(LuminaTypography.WEIGHT_MEDIUM)
          .fontColor(LuminaColors.TEXT_PRIMARY)
          .margin({ bottom: LuminaSpacing.MD })
          .width('100%')

        // 场景网格
        Grid() {
          ForEach(this.scenarios, (item: ScenarioItem) => {
            GridItem() {
              Column() {
                // 图标背景（渐变圆形，带渐变效果）
                Stack() {
                  Circle({ width: 64, height: 64 })
                    .fill(this.selectedSceneId === item.id ? LuminaColors.BG_PRIMARY : LuminaColors.BG_PRIMARY)
                    .opacity(this.selectedSceneId === item.id ? 1 : 0.8)

                  // 渐变背景层（模拟渐变效果）
                  Circle({ width: 64, height: 64 })
                    .fill(LuminaColors.PRIMARY_BLUE)
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
                .margin({ bottom: LuminaSpacing.SM })

                Text(item.title)
                  .fontSize(LuminaTypography.BODY)
                  .fontWeight(LuminaTypography.WEIGHT_MEDIUM)
                  .fontColor(LuminaColors.TEXT_PRIMARY)
                  .margin({ bottom: LuminaSpacing.XS })

                Text($r('app.string.one_click_generate'))
                  .fontSize(LuminaTypography.CAPTION)
                  .fontColor(LuminaColors.TEXT_SECONDARY)
              }
              .width('100%')
              .height(144)
              .justifyContent(FlexAlign.Center)
              .padding(LuminaSpacing.MD)
              .borderRadius(LuminaRadius.XL)
              .border({
                width: 2,
                color: this.selectedSceneId === item.id ? LuminaColors.PRIMARY_BLUE : LuminaColors.BORDER
              })
              .backgroundColor(this.selectedSceneId === item.id ? LuminaColors.BG_PRIMARY : LuminaColors.BG_SURFACE)
              .shadow({
                radius: this.selectedSceneId === item.id ? 8 : 0,
                color: this.selectedSceneId === item.id ? LuminaColors.PRIMARY_BLUE : '#000000',
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
        .columnsGap(LuminaLayout.GRID_GAP)
        .rowsGap(LuminaLayout.GRID_GAP)
        .width('100%')
        .height(456)
        .margin({ bottom: LuminaLayout.SECTION_SPACING })

          // 最近作品区域
          if (this.recentWorks.length > 0) {
            Column() {
              // 区域标题和查看全部
              Row() {
                Text('最近作品')
                  .fontSize(LuminaTypography.TITLE)
                  .fontWeight(LuminaTypography.WEIGHT_MEDIUM)
                  .fontColor(LuminaColors.TEXT_PRIMARY)
                  .layoutWeight(1)

                Row() {
                  Text('查看全部')
                    .fontSize(LuminaTypography.BODY)
                    .fontWeight(LuminaTypography.WEIGHT_MEDIUM)
                    .fontColor(LuminaColors.PRIMARY_BLUE)

                  Text('>')
                    .fontSize(LuminaTypography.BODY)
                    .fontWeight(LuminaTypography.WEIGHT_MEDIUM)
                    .fontColor(LuminaColors.PRIMARY_BLUE)
                    .margin({ left: LuminaSpacing.XS })
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
              .margin({ bottom: LuminaSpacing.MD })

              // 作品图片横向滚动（第一行）
              Scroll() {
                Row() {
                  ForEach(this.recentWorks.slice(0, 5), (work: RecentWork) => {
                    Image(work.thumbnail || $r('app.media.startIcon'))
                      .width(LuminaSizes.WORK_THUMBNAIL_SIZE)
                      .height(LuminaSizes.WORK_THUMBNAIL_SIZE)
                      .borderRadius(LuminaRadius.LG)
                      .objectFit(ImageFit.Cover)
                      .backgroundColor(LuminaColors.BORDER)
                      .margin({ right: LuminaSpacing.SM })
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
              .margin({ left: -LuminaLayout.PAGE_PADDING_H, right: -LuminaLayout.PAGE_PADDING_H, bottom: LuminaSpacing.SM })
              .padding({ left: LuminaLayout.PAGE_PADDING_H, right: LuminaLayout.PAGE_PADDING_H })

              // 文件名横向滚动（第二行）
              Scroll() {
                Row() {
                  ForEach(this.recentWorks.slice(0, 5), (work: RecentWork) => {
                    Text(work.filename)
                      .fontSize(LuminaTypography.LABEL)
                      .fontWeight(LuminaTypography.WEIGHT_REGULAR)
                      .fontColor(LuminaColors.TEXT_SECONDARY)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width(LuminaSizes.WORK_THUMBNAIL_SIZE)
                      .textAlign(LuminaLayout.TEXT_ALIGN_CENTER)
                      .margin({ right: LuminaSpacing.SM })
                  }, (work: RecentWork) => `name-${work.id}`)
                }
                .padding({ left: 0, right: 0 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              .margin({ left: -LuminaLayout.PAGE_PADDING_H, right: -LuminaLayout.PAGE_PADDING_H })
              .padding({ left: LuminaLayout.PAGE_PADDING_H, right: LuminaLayout.PAGE_PADDING_H })
            }
            .width('100%')
            .margin({ bottom: LuminaLayout.SECTION_SPACING })
          }

          // 升级专业版横幅
          Row() {
            // 左侧图标
            Stack() {
              Circle({ width: LuminaSizes.ICON_LG, height: LuminaSizes.ICON_LG })
                .fill('#FFFFFF')
                .opacity(0.2)
              
              Image($r('app.media.zhuanye'))
                .width(LuminaSizes.ICON_MD)
                .height(LuminaSizes.ICON_MD)
                .objectFit(ImageFit.Contain)
            }
            .width(LuminaSizes.ICON_LG)
            .height(LuminaSizes.ICON_LG)
            .alignContent(Alignment.Center)
            .margin({ right: LuminaSpacing.SM })

            // 中间文字
            Column() {
              Text($r('app.string.upgrade_pro'))
                .fontSize(LuminaTypography.BODY)
                .fontWeight(LuminaTypography.WEIGHT_MEDIUM)
                .fontColor('#FFFFFF')
                .margin({ bottom: LuminaSpacing.XS })

              Text($r('app.string.unlimited_use'))
                .fontSize(LuminaTypography.CAPTION)
                .fontColor('#FFFFFF')
                .opacity(0.9)
            }
            .alignItems(LuminaLayout.ALIGN_START)
            .layoutWeight(1)

            // 右侧箭头
            Image($r('app.media.right'))
              .width(20)
              .height(20)
              .fillColor('#FFFFFF')
          }
          .width('100%')
          .height(80)
          .padding({ left: 20, right: 20, top: LuminaSpacing.MD, bottom: LuminaSpacing.MD })
          .borderRadius(LuminaRadius.XL)
          .linearGradient({
            angle: 135,
            colors: [
              [LuminaColors.PRIMARY_BLUE, 0.0],
              [LuminaColors.SECONDARY_PURPLE, 1.0]
            ]
          })
          .shadow({
            radius: 12,
            color: LuminaColors.PRIMARY_BLUE,
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
        .padding({ left: LuminaLayout.PAGE_PADDING_H, right: LuminaLayout.PAGE_PADDING_H, top: 0, bottom: LuminaLayout.SECTION_SPACING })
        .alignItems(LuminaLayout.ALIGN_START)
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: LuminaLayout.PAGE_PADDING_H, right: LuminaLayout.PAGE_PADDING_H })
      .backgroundColor(LuminaColors.BG_PRIMARY)

      // 底部导航栏
      TabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(LuminaColors.BG_PRIMARY)
  }
}
