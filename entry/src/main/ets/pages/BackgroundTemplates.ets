import router from '@ohos.router';

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
    let templates = this.allTemplates;
    
    // 按分类过滤
    if (this.selectedCategory !== 'All') {
      templates = templates.filter(t => t.category === this.selectedCategory);
    }
    
    // 按搜索关键词过滤
    if (this.searchKeyword.trim()) {
      const keyword = this.searchKeyword.toLowerCase();
      templates = templates.filter(t => 
        t.title.toLowerCase().includes(keyword)
      );
    }
    
    return templates;
  }

  // 处理模板点击
  handleTemplateClick(template: BackgroundTemplate) {
    // 跳转到模板详情/选择页面
    router.pushUrl({
      url: 'pages/BackgroundTemplateDetail',
      params: {
        templateId: template.id,
        templateTitle: template.title,
        templateCategory: template.category,
        templateRating: template.rating,
        returnUrl: 'pages/BackgroundTemplates' // 标记返回页面
      }
    }).then(() => {
      // 页面返回后，检查是否有选择结果
      // 注意：在HarmonyOS中，返回数据需要通过其他方式传递
      // 这里我们使用一个简单的方法：在返回时通过路由参数传递
    }).catch((err: Error) => {
      console.error(`跳转失败: ${err.message}`);
    });
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
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor('#1F2937')
          .onClick(() => {
            // 返回上一页
            router.back();
          })

        // 标题
        Text('Background Templates')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: -24 })

        // 搜索按钮
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor('#6B7280')
          .margin({ right: 12 })
          .onClick(() => {
            this.showSearchBar = !this.showSearchBar;
            if (!this.showSearchBar) {
              this.searchKeyword = '';
            }
          })

        // 筛选按钮
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor('#6B7280')
          .onClick(() => {
            this.showFilter = !this.showFilter;
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
            .backgroundColor('#F3F4F6')
            .borderRadius(20)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .onChange((value: string) => {
              this.searchKeyword = value;
            })
            .onSubmit(() => {
              this.handleSearch();
            })

          if (this.searchKeyword.trim()) {
            Image($r('app.media.startIcon'))
              .width(20)
              .height(20)
              .fillColor('#6B7280')
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
      }

      // 分类标签栏
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Text(category)
              .fontSize(14)
              .fontWeight(this.selectedCategory === category ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#6B7280')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(20)
              .backgroundColor(this.selectedCategory === category ? '#6366F1' : '#F3F4F6')
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

      // 空状态提示
      if (this.filteredTemplates.length === 0) {
        Column() {
          Image($r('app.media.startIcon'))
            .width(64)
            .height(64)
            .fillColor('#9CA3AF')
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
            ForEach(this.filteredTemplates, (template: BackgroundTemplate) => {
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
                  .backgroundColor('#F3F4F6')
                  
                  // 高级标签（如果有）
                  if (template.isPremium) {
                    Row() {
                      Text('PRO')
                        .fontSize(10)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor('#FF6B6B')
                        .borderRadius(4)
                    }
                    .width('100%')
                    .height('100%')
                    .justifyContent(FlexAlign.Start)
                    .alignItems(VerticalAlign.Bottom)
                    .padding(8)
                  }
                }
                .width('100%')
                .aspectRatio(1)
                .borderRadius(12)
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
              .onClick(() => {
                this.handleTemplateClick(template);
              })
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

