import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';
import { TabItem, WorkItem } from '../common/types/CommonTypes';
import { WorkService } from '../common/services/WorkService';
import { TabBar } from '../common/components/TabBar';

@Entry
@Component
struct MyWorks {
  // 当前选中的标签
  @State selectedTab: string = '全部';
  
  // 标签列表
  private tabs: TabItem[] = [
    { id: '全部', title: '全部' },
    { id: '淘宝', title: '淘宝' },
    { id: '抖音', title: '抖音' },
    { id: '小红书', title: '小红书' },
    { id: '亚马', title: '亚马' }
  ];
  
  // 作品列表（当前为空）
  @State worksList: WorkItem[] = [];
  // 选择模式
  @State isSelectMode: boolean = false;
  // 选中的作品ID列表
  @State selectedWorkIds: string[] = [];
  // 统计信息
  @State totalCount: number = 0;
  @State storageUsed: string = '0 MB';
  // 分页信息
  @State currentPage: number = 1;
  @State pageSize: number = 20;
  @State hasMore: boolean = true;
  
  private workService: WorkService = WorkService.getInstance();

  aboutToAppear() {
    // 加载作品列表
    this.loadWorks();
  }

  // 加载作品列表
  async loadWorks() {
    try {
      const category = this.selectedTab === '全部' ? undefined : this.getCategoryFromTab(this.selectedTab);
      const response = await this.workService.getWorks(this.currentPage, this.pageSize, category);
      
      const works: WorkItem[] = [];
      for (let i = 0; i < response.works.length; i++) {
        const work = response.works[i];
        const workItem: WorkItem = {
          id: work.id,
          title: work.filename,
          thumbnail: work.thumbnail || '',
          createdAt: work.createdAt,
          category: work.category || ''
        };
        works.push(workItem);
      }
      this.worksList = works;
      
      this.totalCount = response.pagination.total;
      this.storageUsed = this.formatStorage(response.totalStorage);
      this.hasMore = response.pagination.page < response.pagination.totalPages;
    } catch (error) {
      console.error(`加载作品列表失败: ${error.message}`);
      this.worksList = [];
    }
  }

  // 将标签转换为场景类型
  getCategoryFromTab(tab: string): 'taobao' | 'douyin' | 'xiaohongshu' | 'amazon' | undefined {
    const map: Record<string, 'taobao' | 'douyin' | 'xiaohongshu' | 'amazon'> = {
      '淘宝': 'taobao',
      '抖音': 'douyin',
      '小红书': 'xiaohongshu',
      '亚马': 'amazon'
    };
    return map[tab];
  }

  // 格式化存储大小
  formatStorage(bytes: number): string {
    if (bytes < 1024) {
      return `${bytes} B`;
    } else if (bytes < 1024 * 1024) {
      return `${(bytes / 1024).toFixed(2)} KB`;
    } else if (bytes < 1024 * 1024 * 1024) {
      return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
    } else {
      return `${(bytes / (1024 * 1024 * 1024)).toFixed(2)} GB`;
    }
  }

  // 返回上一页
  async handleBack() {
    console.info('[MyWorks] handleBack 被调用');
    const routerService = RouterService.getInstance();
    const routeHistory = routerService.getRouteHistory();
    const currentRoute = routerService.getCurrentRoute();
    
    console.info(`[MyWorks] 当前路由: ${currentRoute}, 历史栈长度: ${routeHistory.length}, 历史栈: ${JSON.stringify(routeHistory)}`);
    
    // 检查路由历史，判断是否应该返回到首页
    // Tab 页面通过 switchTab 进入时，历史栈应该至少有 Index
    if (routeHistory.length <= 1) {
      // 历史栈只有一页或为空，返回到首页
      console.info('[MyWorks] 路由历史栈为空或只有一页，返回到首页');
      await routerService.navigateTo('pages/Index', undefined, true)
        .catch((error: Error) => {
          console.error(`[MyWorks] 跳转首页失败: ${error.message}`);
        });
    } else if (routeHistory.length === 2 && routeHistory[0] === 'pages/Index') {
      // 历史栈有两页，第一页是 Index，说明是通过 Tab 切换进入的
      // 直接返回到 Index
      console.info('[MyWorks] 通过 Tab 切换进入，返回到首页');
      await routerService.navigateTo('pages/Index', undefined, true)
        .catch((error: Error) => {
          console.error(`[MyWorks] 跳转首页失败: ${error.message}`);
        });
    } else {
      // 尝试返回上一页
      console.info('[MyWorks] 尝试返回上一页');
      await routerService.goBack()
        .catch((err: Error) => {
          console.error(`[MyWorks] 返回失败: ${err.message}`);
          // 如果返回失败，则返回到首页
          routerService.navigateTo('pages/Index', undefined, true)
            .catch((error: Error) => {
              console.error(`[MyWorks] 跳转首页失败: ${error.message}`);
            });
        });
    }
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
          console.info('[MyWorks] 返回按钮被点击');
          await this.handleBack();
        })

        // 标题
      Text('我的作品')
        .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1F36')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: -40 })

        // 选择按钮
        Button() {
          Text(this.isSelectMode ? '取消' : '选择')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#667eea')
        }
        .type(ButtonType.Normal)
        .width(60)
        .height(32)
        .backgroundColor('#F8F9FC')
        .borderRadius(8)
        .onClick(() => {
          this.isSelectMode = !this.isSelectMode;
          if (!this.isSelectMode) {
            this.selectedWorkIds = []; // 取消选择模式时清空选中项
          }
        })
      }
        .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
        .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })
      
      // 导航标签栏
      Scroll() {
        Row() {
          ForEach(this.tabs, (tab: TabItem) => {
            Text(tab.title)
              .fontSize(14)
              .fontWeight(this.selectedTab === tab.id ? FontWeight.Medium : FontWeight.Regular)
              .fontColor(this.selectedTab === tab.id ? '#FFFFFF' : '#1A1F36')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(16)
              .backgroundColor(this.selectedTab === tab.id ? '#667eea' : 'transparent')
              .onClick(() => {
                this.selectedTab = tab.id;
                this.currentPage = 1;
                this.loadWorks(); // 切换标签时重新加载数据
              })
          }, (tab: TabItem) => tab.id)
        }
        .padding({ left: 20, right: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(48)
      .backgroundColor('#FFFFFF')

      // 统计栏（有作品时显示）
      if (this.worksList.length > 0) {
        Row() {
          Text(`共 ${this.totalCount} 张`)
            .fontSize(14)
            .fontColor('#6B7280')
          Blank()
          Text(`已用 ${this.storageUsed}`)
            .fontSize(14)
            .fontColor('#6B7280')
        }
        .width('100%')
        .height(40)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#F8F9FC')
        .border({ width: { bottom: 1 }, color: '#E5E7EB' })
      }
      
      // 内容区域
      if (this.worksList.length === 0) {
        // 空状态
        Column() {
          // 文件夹图标
          Stack() {
            Circle({ width: 100, height: 100 })
              .fill('#F8F9FC')

          Image($r('app.media.startIcon'))
              .width(60)
              .height(60)
              .fillColor('#C7C7CC')
          }
            .width(100)
            .height(100)
            .margin({ bottom: 32 })
          
          // "还没有作品"文字
          Text('还没有作品')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1F36')
            .margin({ bottom: 12 })
          
          // 提示文字
          Text('开始处理你的第一张图片吧')
            .fontSize(14)
            .fontColor('#6B7280')
            .margin({ bottom: 32 })
          
          // "立即处理"按钮
          Text('立即处理')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#667eea')
            .decoration({ type: TextDecorationType.Underline })
            .onClick(() => {
              // 跳转到工作台
              RouterService.getInstance().navigateTo('pages/Workbench')
                .catch((err: Error) => {
                  console.error(`跳转失败: ${err.message}`);
                });
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 20, right: 20 })
      } else {
        // 作品网格（3列布局）
        Scroll() {
          Grid() {
            ForEach(this.worksList, (work: WorkItem) => {
              GridItem() {
                Stack() {
                  // 作品缩略图
                  Image(work.thumbnail || $r('app.media.startIcon'))
                    .width('100%')
                    .aspectRatio(1)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                    .backgroundColor('#E5E7EB')
                    .onClick(() => {
                      if (this.isSelectMode) {
                        // 选择模式：切换选中状态
                        const index = this.selectedWorkIds.indexOf(work.id);
                        if (index >= 0) {
                          this.selectedWorkIds.splice(index, 1);
                        } else {
                          this.selectedWorkIds.push(work.id);
                        }
                      } else {
                        // 普通模式：跳转到作品详情
                        const params: Record<string, string | number | boolean | string[] | undefined> = {} as Record<string, string | number | boolean | string[] | undefined>;
                        params['workId'] = work.id;
                        params['imagePath'] = work.thumbnail;
                        RouterService.getInstance().navigateTo('pages/ProcessResult', params).catch((err: Error) => {
                          console.error(`跳转失败: ${err.message}`);
                        });
                      }
                    })
                    .gesture(
                      LongPressGesture({ repeat: false, duration: 500 })
                        .onAction(() => {
                          // 长按进入选择模式
                          if (!this.isSelectMode) {
                            this.isSelectMode = true;
                            this.selectedWorkIds = [work.id];
                          }
                        })
                    )

                  // 选中状态指示器
                  if (this.isSelectMode) {
                    Stack() {
                      Circle({ width: 24, height: 24 })
                        .fill(this.selectedWorkIds.indexOf(work.id) >= 0 ? '#667eea' : 'transparent')
                        .stroke(this.selectedWorkIds.indexOf(work.id) >= 0 ? '#667eea' : '#FFFFFF')
                        .strokeWidth(2)

                      if (this.selectedWorkIds.indexOf(work.id) >= 0) {
                        Text('✓')
                          .fontSize(14)
                          .fontColor('#FFFFFF')
                          .fontWeight(FontWeight.Medium)
                      }
                    }
                    .width(24)
                    .height(24)
                    .position({ x: 8, y: 8 })
                  }
        }
        .width('100%')
                .aspectRatio(1)
              }
            }, (work: WorkItem) => work.id)
          }
          .columnsTemplate('1fr 1fr 1fr')
          .columnsGap(8)
          .rowsGap(8)
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 100 })
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Auto)

        // 批量操作栏（选择模式时显示）
        if (this.isSelectMode && this.selectedWorkIds.length > 0) {
          Row() {
            Text(`已选择 ${this.selectedWorkIds.length} 项`)
              .fontSize(14)
              .fontColor('#1A1F36')
        .layoutWeight(1)

            Button() {
              Text('分享')
                .fontSize(14)
                .fontColor('#667eea')
            }
            .type(ButtonType.Normal)
            .width(80)
            .height(36)
            .backgroundColor('#F8F9FC')
            .border({ width: 1, color: '#667eea' })
            .borderRadius(8)
            .margin({ right: 12 })
            .onClick(() => {
              this.handleShare();
            })

            Button() {
              Text('删除')
                .fontSize(14)
                .fontColor('#FFFFFF')
            }
            .type(ButtonType.Normal)
            .width(80)
            .height(36)
            .backgroundColor('#EF4444')
            .borderRadius(8)
            .onClick(() => {
              this.handleDelete();
            })
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .border({ width: { top: 1 }, color: '#E5E7EB' })
          .shadow({
            radius: 8,
            color: '#000000',
            offsetX: 0,
            offsetY: -2
          })
        }
      }

      // 底部导航栏
      TabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FC')
  }

  // 分享选中的作品
  handleShare() {
    console.info('分享作品:', this.selectedWorkIds);
    // TODO: 实现分享功能
    // 可以使用系统分享API
  }

  // 删除选中的作品
  async handleDelete() {
    if (this.selectedWorkIds.length === 0) {
      return;
    }
    
    console.info('删除作品:', this.selectedWorkIds);
    try {
      if (this.selectedWorkIds.length === 1) {
        // 单个删除
        await this.workService.deleteWork(this.selectedWorkIds[0]);
      } else {
        // 批量删除
        await this.workService.batchDeleteWorks(this.selectedWorkIds);
      }
      
      // 更新作品列表
      this.worksList = this.worksList.filter(work => 
        this.selectedWorkIds.indexOf(work.id) < 0
      );
      this.selectedWorkIds = [];
      
      // 如果删除后列表为空，退出选择模式
      if (this.worksList.length === 0) {
        this.isSelectMode = false;
      }
      
      // 重新加载数据以更新统计信息
      await this.loadWorks();
    } catch (error) {
      console.error(`删除作品失败: ${error.message}`);
      // TODO: 显示错误提示
    }
  }

}

