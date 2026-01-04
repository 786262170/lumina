import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';
import { TabBar } from '../common/components/TabBar';

// 背景模板数据类型
interface BackgroundTemplate {
  id: string;
  title: string;
  category: string;
  rating: number;
  imageUrl: string; // 图片资源路径，后续可替换为实际图片
  isPremium?: boolean; // 是否为高级模板
}

@Entry
@Component
struct BackgroundTemplates {
  @State selectedCategory: string = 'All'; // 当前选中的分类
  @State searchKeyword: string = ''; // 搜索关键词
  @State showFilter: boolean = false; // 是否显示筛选面板
  @State showSearchBar: boolean = false; // 是否显示搜索框
  @State selectedTemplate: BackgroundTemplate | null = null; // 选中的模板

  // 分类列表
  private categories: string[] = ['All', 'Studio', 'Lifestyle', 'Nature', 'Creative'];

  // 模板数据（模拟数据，后续可接入真实API）
  private allTemplates: BackgroundTemplate[] = [
    // Studio 分类
    { id: '1', title: 'Pure White', category: 'Studio', rating: 4.9, imageUrl: '' },
    { id: '2', title: 'Light Grey', category: 'Studio', rating: 4.8, imageUrl: '' },
    { id: '3', title: 'Dark Grey', category: 'Studio', rating: 4.7, imageUrl: '' },
    { id: '4', title: 'Pure Black', category: 'Studio', rating: 4.9, imageUrl: '' },
    { id: '5', title: 'Soft Gradient', category: 'Studio', rating: 4.8, imageUrl: '' },
    { id: '6', title: 'Infinity Cove', category: 'Studio', rating: 4.6, imageUrl: '' },
    { id: '7', title: 'White Marble', category: 'Studio', rating: 4.8, imageUrl: '' },
    { id: '8', title: 'Wood Texture', category: 'Studio', rating: 4.7, imageUrl: '' },
    { id: '9', title: 'Abstract Geometric', category: 'Studio', rating: 4.9, imageUrl: '' },
    
    // Lifestyle 分类
    { id: '10', title: 'Modern Living Room', category: 'Lifestyle', rating: 4.8, imageUrl: '' },
    { id: '11', title: 'Cozy Bedroom', category: 'Lifestyle', rating: 4.7, imageUrl: '' },
    { id: '12', title: 'Home Office', category: 'Lifestyle', rating: 4.9, imageUrl: '' },
    { id: '13', title: 'Cafe Interior', category: 'Lifestyle', rating: 4.6, imageUrl: '' },
    { id: '14', title: 'Retail Store', category: 'Lifestyle', rating: 4.7, imageUrl: '' },
    { id: '15', title: 'Kitchen', category: 'Lifestyle', rating: 4.5, imageUrl: '' },
    
    // Nature 分类
    { id: '16', title: 'Green Grass', category: 'Nature', rating: 4.9, imageUrl: '' },
    { id: '17', title: 'Sandy Beach', category: 'Nature', rating: 4.8, imageUrl: '' },
    { id: '18', title: 'Blue Sky', category: 'Nature', rating: 4.7, imageUrl: '' },
    { id: '19', title: 'Forest Path', category: 'Nature', rating: 4.9, imageUrl: '' },
    { id: '20', title: 'Mountain View', category: 'Nature', rating: 4.8, imageUrl: '' },
    { id: '21', title: 'Sunset', category: 'Nature', rating: 4.9, imageUrl: '' },
    
    // Creative 分类
    { id: '22', title: 'Neon Lights', category: 'Creative', rating: 4.8, imageUrl: '' },
    { id: '23', title: 'Bokeh Background', category: 'Creative', rating: 4.7, imageUrl: '' },
    { id: '24', title: 'Aurora Gradient', category: 'Creative', rating: 4.9, imageUrl: '' },
  ];

  // 获取过滤后的模板列表
  get filteredTemplates(): BackgroundTemplate[] {
    // 确保 allTemplates 已初始化
    if (!this.allTemplates || this.allTemplates.length === 0) {
      return [];
    }
    
    let templates = this.allTemplates;
    
    // 按分类过滤
    if (this.selectedCategory !== 'All') {
      templates = templates.filter(t => t.category === this.selectedCategory);
    }
    
    // 按搜索关键词过滤
    if (this.searchKeyword && this.searchKeyword.trim()) {
      const keyword = this.searchKeyword.toLowerCase();
      templates = templates.filter(t => 
        t.title.toLowerCase().includes(keyword)
      );
    }
    
    return templates || [];
  }

  // 处理模板点击
  handleTemplateClick(template: BackgroundTemplate) {
    // 跳转到模板详情/选择页面
    const params: Record<string, string | number | boolean | string[] | undefined> = {} as Record<string, string | number | boolean | string[] | undefined>;
    params['templateId'] = template.id;
    params['templateTitle'] = template.title;
    params['templateCategory'] = template.category;
    params['templateRating'] = template.rating;
    params['returnUrl'] = 'pages/BackgroundTemplates'; // 标记返回页面
    RouterService.getInstance().navigateTo('pages/BackgroundTemplateDetail', params).catch((err: Error) => {
      console.error(`跳转失败: ${err.message}`);
    });
  }

  // 返回首页
  async handleBack() {
    console.info('[BackgroundTemplates] handleBack 被调用');
    try {
      await RouterService.getInstance().navigateTo('pages/Index', undefined, true);
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : String(err);
      console.error(`[BackgroundTemplates] 跳转首页失败: ${errorMsg}`);
    }
  }

  // 处理搜索
  handleSearch() {
    // 搜索逻辑已在 getter 中实现
    console.info(`搜索关键词: ${this.searchKeyword}`);
  }

  // 清除搜索
  handleClearSearch() {
    this.searchKeyword = '';
    this.showSearchBar = false;
  }

  aboutToAppear() {
    // 检查是否有返回的模板选择结果（从详情页返回）
    const params = router.getParams() as Record<string, Object>;
    if (params && params['isSelected']) {
      // 模板已选择，可以在这里处理
      this.selectedTemplate = {
        id: params['templateId'] as string || '',
        title: params['templateTitle'] as string || '',
        category: params['templateCategory'] as string || '',
        rating: params['templateRating'] as number || 0,
        imageUrl: ''
      };
      console.info(`模板已选择: ${this.selectedTemplate.title}`);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 返回按钮
        Button() {
          Image($r('app.media.last'))
            .width(20)
            .height(20)
            .fillColor('#1A1F36')
        }
        .type(ButtonType.Normal)
        .width(40)
        .height(40)
        .backgroundColor('#F8F9FC')
        .borderRadius(8)
          .onClick(async () => {
            await this.handleBack();
          })

        // 标题
        Text('背景模板')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1F36')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 头像按钮
        Button() {
          Image($r('app.media.touxiang'))
          .width(24)
          .height(24)
            .objectFit(ImageFit.Contain)
        }
        .type(ButtonType.Normal)
        .width(40)
        .height(40)
        .backgroundColor('#F8F9FC')
        .borderRadius(8)
          .margin({ right: 12 })
          .onClick(() => {
          // 跳转到我的页面
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
            .objectFit(ImageFit.Contain)
        }
        .type(ButtonType.Normal)
        .width(40)
        .height(40)
        .backgroundColor('#F8F9FC')
        .borderRadius(8)
          .onClick(() => {
          // 跳转到设置页面
          RouterService.getInstance().navigateTo('pages/Settings')
            .catch((err: Error) => {
              console.error(`跳转失败: ${err.message}`);
            });
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })

      // 搜索框（条件显示）
      if (this.showSearchBar) {
        Row() {
          TextInput({ placeholder: '搜索模板...', text: this.searchKeyword })
            .layoutWeight(1)
            .fontSize(14)
            .fontColor('#1A1F36')
            .backgroundColor('#F8F9FC')
            .borderRadius(20)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .border({ width: 1, color: '#E5E7EB' })
            .onChange((value: string) => {
              this.searchKeyword = value;
            })
            .onSubmit(() => {
              this.handleSearch();
            })

          if (this.searchKeyword.trim()) {
            Button() {
              Text('×')
                .fontSize(20)
                .fontColor('#6B7280')
            }
            .type(ButtonType.Normal)
            .width(32)
            .height(32)
            .backgroundColor('#F8F9FC')
            .borderRadius(16)
              .margin({ left: 8 })
              .onClick(() => {
                this.handleClearSearch();
              })
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#E5E7EB' })
        .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
      }

      // 分类标签栏
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Button(category)
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontWeight(this.selectedCategory === category ? FontWeight.Medium : FontWeight.Regular)
              .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#6B7280')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(18)
              .backgroundColor(this.selectedCategory === category ? '#667eea' : '#F8F9FC')
              .border({
                width: this.selectedCategory === category ? 0 : 1,
                color: '#E5E7EB'
              })
              .margin({ right: 12 })
              .onClick(() => {
                this.selectedCategory = category;
              })
          }, (category: string) => category)
        }
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })

      // 空状态提示
      if (!this.filteredTemplates || this.filteredTemplates.length === 0) {
        Column() {
          Image($r('app.media.mubanpipei'))
            .width(64)
            .height(64)
            .objectFit(ImageFit.Contain)
            .margin({ bottom: 16 })

          Text('未找到匹配的模板')
            .fontSize(16)
            .fontColor('#6B7280')
            .margin({ bottom: 8 })

          Text('请尝试其他搜索关键词或分类')
            .fontSize(14)
            .fontColor('#9CA3AF')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 模板网格
        Scroll() {
          Grid() {
            ForEach(this.filteredTemplates || [], (template: BackgroundTemplate) => {
            GridItem() {
              Column() {
                // 模板预览图片
                Stack() {
                  // 占位图片（后续可替换为实际图片）
                  Column() {
                    Image($r('app.media.startIcon'))
                      .width(48)
                      .height(48)
                      .fillColor('#9CA3AF')
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .backgroundColor('#F8F9FC')
                  
                  // 高级标签（如果有）
                  if (template.isPremium) {
                    Row() {
                      Text('PRO')
                        .fontSize(10)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor('#EF4444')
                        .borderRadius(4)
                    }
                    .width('100%')
                    .height('100%')
                    .justifyContent(FlexAlign.Start)
                    .alignItems(VerticalAlign.Top)
                    .padding(8)
                  }
                }
                .width('100%')
                .aspectRatio(1)
                .borderRadius(12)
                .shadow({
                  radius: 4,
                  color: '#000000',
                  offsetX: 0,
                  offsetY: 2
                })
                .margin({ bottom: 8 })

                // 模板标题
                Text(template.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1F2937')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 4 })

                // 评分
                Row() {
                  Image($r('app.media.startIcon'))
                    .width(14)
                    .height(14)
                    .fillColor('#FBBF24')
                    .margin({ right: 4 })

                  Text(template.rating.toString())
                    .fontSize(12)
                    .fontColor('#6B7280')
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .padding(8)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .onClick(() => {
                this.handleTemplateClick(template);
              })
              .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
            }
          }, (template: BackgroundTemplate) => template.id)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(12)
        .rowsGap(16)
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }

      // 底部导航栏
      TabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FC')
  }
}

