import router from '@ohos.router';
import { picker } from '@kit.CoreFileKit';
import { ToolItem } from '../common/types/CommonTypes';

// 背景模板接口
interface BackgroundTemplate {
  id: string;
  label: string;
  color?: string;
  gradient?: string;
}

// 尺寸预设接口
interface SizePreset {
  id: string;
  label: string;
  dimensions: string;
}

@Entry
@Component
struct Workbench {
  @State imagePath: string = ''; // 图片路径（单张模式）
  @State imageUri: string = ''; // 图片URI（单张模式）
  @State imagePaths: string[] = []; // 图片路径数组（批量模式）
  @State imageUris: string[] = []; // 图片URI数组（批量模式）
  @State isBatch: boolean = false; // 是否为批量模式
  @State currentImageIndex: number = 0; // 当前显示的图片索引（批量模式）
  @State imageInfo: string = ''; // 图片信息（尺寸、格式、大小）
  @State selectedTool: number = -1; // 当前选中的工具
  @State canUndo: boolean = false; // 是否可以撤销
  @State canRedo: boolean = false; // 是否可以重做
  @State isDrawerOpen: boolean = false; // 抽屉是否打开
  @State selectedBackground: string = 'white'; // 选中的背景模板
  @State selectedSize: string = 'amazon'; // 选中的尺寸预设
  @State outputQuality: number = 85; // 输出质量

  // 返回上一页
  handleBack() {
    console.info('handleBack 被调用');
    try {
      router.back();
      console.info('router.back() 已调用');
    } catch (err) {
      console.error(`router.back() 调用失败: ${JSON.stringify(err)}`);
      // 如果无法返回，则返回到首页
      router.replaceUrl({ url: 'pages/Index' }).catch((error: Error) => {
        console.error(`跳转首页失败: ${error.message}`);
      });
    }
  }

  // 工具栏图标列表
  private tools: ToolItem[] = [
    { id: 0, name: '上传', icon: 'upload' },
    { id: 1, name: '抠图', icon: 'crop' },
    { id: 2, name: '背景', icon: 'gallery' },
    { id: 3, name: '光效', icon: 'enhance' },
    { id: 4, name: '尺寸', icon: 'fullscreen' },
    { id: 5, name: '滤镜', icon: 'settings' }
  ];

  // 背景模板列表
  private backgroundTemplates: BackgroundTemplate[] = [
    { id: 'white', label: '纯白', color: '#FFFFFF' },
    { id: 'light-gray', label: '浅灰', color: '#F3F4F6' },
    { id: 'aurora', label: '渐变', gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' },
    { id: 'scene1', label: '客厅', color: '#E0E7FF' },
    { id: 'scene2', label: '工作室', color: '#FEF3C7' },
    { id: 'custom', label: '自定义', color: '#F8F9FC' }
  ];

  // 尺寸预设列表
  private sizePresets: SizePreset[] = [
    { id: 'amazon', label: 'Amazon', dimensions: '2000x2000' },
    { id: 'shopify', label: 'Shopify', dimensions: '2048x2048' },
    { id: 'ebay', label: 'eBay', dimensions: '1600x1600' },
    { id: 'custom', label: '自定义', dimensions: '' }
  ];

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.isBatch = params['isBatch'] as boolean || false;
      if (this.isBatch) {
        // 批量模式
        this.imagePaths = params['imagePaths'] as string[] || [];
        this.imageUris = params['imageUris'] as string[] || [];
        if (this.imagePaths.length > 0) {
          this.imagePath = this.imagePaths[0];
        }
        if (this.imageUris.length > 0) {
          this.imageUri = this.imageUris[0];
        }
      } else {
        // 单张模式
        this.imagePath = params['imagePath'] as string || '';
        this.imageUri = params['imageUri'] as string || '';
      }
      // 加载图片信息
      this.loadImageInfo();
    }
  }

  build() {
    Column() {
      // 顶部导航栏（带返回按钮）
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
        .onClick(() => {
          this.handleBack();
        })

        // 标题
        Text('工作台')
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

      // 主内容区
      Row() {
        // 左侧工具栏
        Column() {
        ForEach(this.tools, (tool: ToolItem) => {
          Button() {
            Image($r('app.media.startIcon'))
              .width(24)
              .height(24)
              .fillColor(this.selectedTool === tool.id ? '#FFFFFF' : '#6B7280')
          }
          .type(ButtonType.Normal)
          .width(36)
          .height(36)
          .borderRadius(12)
          .backgroundColor(this.selectedTool === tool.id ? '#667eea' : '#F8F9FC')
          .margin({ bottom: 8 })
          .onClick(() => {
            this.handleToolClick(tool.id);
            // 打开抽屉
            if (tool.id >= 0) {
              this.isDrawerOpen = true;
            }
          })
        }, (tool: ToolItem) => tool.id.toString())
      }
      .width(48)
      .padding({ top: 16, bottom: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { right: 1 }, color: '#E5E7EB' })
      .alignItems(HorizontalAlign.Center)

      // 主内容区
      Column() {
        // 图片显示区域（带透明背景棋盘格）
        Stack() {
          // 棋盘格背景（表示透明）- 使用Canvas绘制
          Canvas(this.checkerboardContext)
            .width('100%')
            .height('100%')
            .onReady(() => {
              this.drawCheckerboardPattern();
            })

          // 图片
          if (this.imagePath) {
            Image(this.imagePath)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Contain)
              .backgroundColor('#FFFFFF')
          } else {
            // 占位符
            Column() {
              Image($r('app.media.startIcon'))
                .width(48)
                .height(48)
                .fillColor('#C7C7CC')
                .margin({ bottom: 12 })

              Text('拖拽图片到此处或点击上传')
                .fontSize(14)
                .fontColor('#6B7280')
                .margin({ bottom: 4 })

              Text('支持 JPG, PNG, WebP')
                .fontSize(12)
                .fontColor('#C7C7CC')
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.handleUpload();
            })
          }

          // 批量模式下的图片切换按钮
          if (this.isBatch && this.imagePaths.length > 1) {
            Row() {
              // 上一张按钮
              if (this.currentImageIndex > 0) {
                Button() {
                  Image($r('app.media.startIcon'))
                    .width(20)
                    .height(20)
                    .fillColor('#FFFFFF')
                }
                .type(ButtonType.Circle)
                .width(40)
                .height(40)
                .backgroundColor('#000000')
                .opacity(0.5)
                .onClick(() => {
                  this.switchToPreviousImage();
                })
              } else {
                Blank()
              }

              Blank()

              // 下一张按钮
              if (this.currentImageIndex < this.imagePaths.length - 1) {
                Button() {
                  Image($r('app.media.startIcon'))
                    .width(20)
                    .height(20)
                    .fillColor('#FFFFFF')
                }
                .type(ButtonType.Circle)
                .width(40)
                .height(40)
                .backgroundColor('#000000')
                .opacity(0.5)
                .onClick(() => {
                  this.switchToNextImage();
                })
              } else {
                Blank()
              }
            }
            .width('100%')
            .height('100%')
            .padding({ left: 16, right: 16 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
          }

          // 批量模式下的图片计数
          if (this.isBatch && this.imagePaths.length > 1) {
            Row() {
              Text(`${this.currentImageIndex + 1} / ${this.imagePaths.length}`)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('#000000')
                .opacity(0.6)
                .borderRadius(12)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Top)
            .padding({ top: 16, left: 16 })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')

        // 图片信息栏
        if (this.imageInfo) {
          Column() {
            Text(this.imageInfo)
              .fontSize(12)
              .fontColor('#6B7280')
              .margin({ bottom: 2 })

            Text('JPG, 2.3MB')
              .fontSize(12)
              .fontColor('#C7C7CC')
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .layoutWeight(1)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FC')

    // 底部操作栏
    .overlay(this.buildBottomBar(), {
      align: Alignment.Bottom
    })
    // 底部抽屉（属性面板）
    .overlay(this.buildBottomDrawer(), {
      align: Alignment.Bottom
    })
  }

  private checkerboardSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private checkerboardContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.checkerboardSettings);

  // 绘制棋盘格图案
  private drawCheckerboardPattern() {
    const context = this.checkerboardContext;
    const tileSize = 20;
    
    // 使用较大的尺寸来覆盖整个画布
    const width = 2000;
    const height = 2000;

    // 填充白色背景
    context.fillStyle = '#FFFFFF';
    context.fillRect(0, 0, width, height);

    // 绘制灰色方格
    context.fillStyle = '#E5E7EB';
    for (let y = 0; y < height; y += tileSize) {
      for (let x = 0; x < width; x += tileSize) {
        if ((Math.floor(x / tileSize) + Math.floor(y / tileSize)) % 2 === 0) {
          context.fillRect(x, y, tileSize, tileSize);
        }
      }
    }
  }

  // 构建底部操作栏
  @Builder
  buildBottomBar() {
    Row() {
      // 撤销按钮
      Button() {
        Image($r('app.media.startIcon'))
          .width(18)
          .height(18)
          .fillColor(this.canUndo ? '#1A1F36' : '#C7C7CC')
      }
      .type(ButtonType.Normal)
      .width(32)
      .height(32)
      .borderRadius(8)
      .backgroundColor('#F8F9FC')
      .enabled(this.canUndo)
      .opacity(this.canUndo ? 1 : 0.4)
      .onClick(() => {
        this.handleUndo();
      })

      // 重做按钮
      Button() {
        Image($r('app.media.startIcon'))
          .width(18)
          .height(18)
          .fillColor(this.canRedo ? '#1A1F36' : '#C7C7CC')
      }
      .type(ButtonType.Normal)
      .width(32)
      .height(32)
      .borderRadius(8)
      .backgroundColor('#F8F9FC')
      .margin({ left: 8 })
      .enabled(this.canRedo)
      .opacity(this.canRedo ? 1 : 0.4)
      .onClick(() => {
        this.handleRedo();
      })

      Blank()

      // 应用按钮（渐变）
      Button() {
        Text('应用')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
      }
      .type(ButtonType.Normal)
      .width(120)
      .height(40)
      .borderRadius(20)
      .linearGradient({
        angle: 135,
        colors: [
          ['#667eea', 0.0],
          ['#764ba2', 1.0]
        ]
      })
      .enabled(this.imagePath !== '')
      .opacity(this.imagePath !== '' ? 1 : 0.5)
      .onClick(() => {
        this.handleApply();
      })

      Blank()

      // 导出按钮
      Button() {
        Row() {
          Image($r('app.media.startIcon'))
            .width(18)
            .height(18)
            .fillColor('#667eea')
            .margin({ right: 6 })

          Text('导出')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#667eea')
        }
        .justifyContent(FlexAlign.Center)
      }
      .type(ButtonType.Normal)
      .width(100)
      .height(40)
      .borderRadius(20)
      .backgroundColor('#FFFFFF')
      .border({ width: 1, color: '#667eea' })
      .enabled(this.imagePath !== '')
      .opacity(this.imagePath !== '' ? 1 : 0.5)
      .onClick(() => {
        this.handleExport();
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

  // 加载图片信息
  async loadImageInfo() {
    if (this.imagePath) {
      // 这里可以获取图片的实际信息
      // 暂时使用模拟数据
      this.imageInfo = '原图: 1920x1080 | JPG, 2.3MB';
    }
  }

  // 处理工具点击
  handleToolClick(toolId: number) {
    const previousTool = this.selectedTool;
    this.selectedTool = this.selectedTool === toolId ? -1 : toolId;

    // 如果点击的是已选中的工具，则取消选择
    if (previousTool === toolId) {
      return;
    }

    switch (toolId) {
      case 0: // 上传
        this.handleUpload();
        break;
      case 1: // 裁剪
        this.handleCrop();
        break;
      case 2: // 图库
        this.handleGallery();
        break;
      case 3: // 增强
        this.handleEnhance();
        break;
      case 4: // 全屏
        this.handleFullscreen();
        break;
      case 5: // 设置
        this.handleSettings();
        break;
    }
  }

  // 上传图片
  async handleUpload() {
    try {
      // Context will be obtained when needed
      const context: Context | null = null;
      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.imageUri = photoSelectResult.photoUris[0];
        this.imagePath = this.imageUri;
        this.loadImageInfo();
        this.selectedTool = -1;
        console.info('图片上传成功');
      }
    } catch (err) {
      console.error(`选择图片失败: ${JSON.stringify(err)}`);
      // TODO: 显示错误提示给用户
    }
  }

  // 裁剪
  handleCrop() {
    console.info('打开裁剪工具');
    // TODO: 实现裁剪功能
  }

  // 图库
  handleGallery() {
    console.info('打开图库');
    // 跳转到背景模板页面
    router.pushUrl({
      url: 'pages/BackgroundTemplates'
    }).catch((err: Error) => {
      console.error(`跳转失败: ${err.message}`);
    });
  }

  // 增强
  handleEnhance() {
    console.info('打开增强工具');
    // TODO: 实现图片增强功能
  }

  // 全屏
  handleFullscreen() {
    console.info('全屏显示');
    // TODO: 实现全屏预览
  }

  // 设置
  handleSettings() {
    console.info('打开设置');
    // TODO: 实现设置功能
  }

  // 撤销
  handleUndo() {
    console.info('撤销操作');
    // TODO: 实现撤销功能
    this.canUndo = false;
  }

  // 重做
  handleRedo() {
    console.info('重做操作');
    // TODO: 实现重做功能
    this.canRedo = false;
  }

  // 应用
  handleApply() {
    console.info('应用更改');
    // TODO: 实现应用功能
  }

  // 切换到上一张图片（批量模式）
  switchToPreviousImage() {
    if (this.isBatch && this.currentImageIndex > 0) {
      this.currentImageIndex--;
      this.imagePath = this.imagePaths[this.currentImageIndex];
      this.imageUri = this.imageUris[this.currentImageIndex];
      this.loadImageInfo();
      // 可以添加切换动画效果
    }
  }

  // 切换到下一张图片（批量模式）
  switchToNextImage() {
    if (this.isBatch && this.currentImageIndex < this.imagePaths.length - 1) {
      this.currentImageIndex++;
      this.imagePath = this.imagePaths[this.currentImageIndex];
      this.imageUri = this.imageUris[this.currentImageIndex];
      this.loadImageInfo();
      // 可以添加切换动画效果
    }
  }

  // 构建底部抽屉（属性面板）
  @Builder
  buildBottomDrawer() {
    if (this.isDrawerOpen) {
      Stack() {
        // 背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.4)
          .onClick(() => {
            this.isDrawerOpen = false;
          })

        // 抽屉内容
        Column() {
          // 拖拽手柄
          Row() {
            Blank()
            Stack() {
              Circle({ width: 40, height: 4 })
                .fill('#D1D5DB')
            }
            .width(40)
            .height(4)
            .margin({ top: 8 })
            Blank()
          }
          .width('100%')

          // 抽屉头部
          Row() {
            Text(this.getToolLabel() + '设置')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1F36')
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Button() {
              Text('×')
                .fontSize(24)
                .fontColor('#6B7280')
            }
            .type(ButtonType.Normal)
            .width(32)
            .height(32)
            .backgroundColor('#F8F9FC')
            .borderRadius(8)
            .onClick(() => {
              this.isDrawerOpen = false;
            })
          }
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })
          .border({ width: { bottom: 1 }, color: '#E5E7EB' })

          // 抽屉内容（可滚动）
          Scroll() {
            Column() {
              // 根据选中的工具显示不同的属性配置
              if (this.selectedTool === 0) {
                // 上传工具
                this.buildUploadProperties()
              } else if (this.selectedTool === 1) {
                // 抠图工具
                this.buildCutoutProperties()
              } else if (this.selectedTool === 2) {
                // 背景工具
                this.buildBackgroundProperties()
              } else if (this.selectedTool === 3) {
                // 光效工具
                this.buildLightingProperties()
              } else if (this.selectedTool === 4) {
                // 尺寸工具
                this.buildSizeProperties()
              } else if (this.selectedTool === 5) {
                // 滤镜工具
                this.buildFilterProperties()
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          }
          .layoutWeight(1)
          .width('100%')
        }
        .width('100%')
        .height('60%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 24, topRight: 24 })
        .shadow({
          radius: 16,
          color: '#000000',
          offsetX: 0,
          offsetY: -4
        })
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
    }
  }

  // 获取工具标签
  getToolLabel(): string {
    const tool = this.tools.find(t => t.id === this.selectedTool);
    return tool ? tool.name : '';
  }

  // 构建上传属性
  @Builder
  buildUploadProperties() {
    Column() {
      Text('上传设置')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .margin({ bottom: 16 })
        .width('100%')

      Button() {
        Text('选择文件')
          .fontSize(14)
          .fontColor('#1A1F36')
      }
      .type(ButtonType.Normal)
      .width('100%')
      .height(44)
      .borderRadius(8)
      .backgroundColor('#F8F9FC')
      .border({ width: 1, color: '#E5E7EB' })
      .margin({ bottom: 12 })
      .onClick(() => {
        this.handleUpload();
        this.isDrawerOpen = false;
      })

      Button() {
        Text('从云端导入')
          .fontSize(14)
          .fontColor('#1A1F36')
      }
      .type(ButtonType.Normal)
      .width('100%')
      .height(44)
      .borderRadius(8)
      .backgroundColor('#F8F9FC')
      .border({ width: 1, color: '#E5E7EB' })
      .margin({ bottom: 24 })

      Text('支持格式')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .margin({ bottom: 8 })
        .width('100%')

      Text('JPG, PNG, WebP, HEIC')
        .fontSize(14)
        .fontColor('#6B7280')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 构建抠图属性
  @Builder
  buildCutoutProperties() {
    Column() {
      Text('抠图模式')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .margin({ bottom: 16 })
        .width('100%')

      Button() {
        Text('自动抠图')
          .fontSize(14)
          .fontColor('#FFFFFF')
      }
      .type(ButtonType.Normal)
      .width('100%')
      .height(44)
      .borderRadius(8)
      .backgroundColor('#667eea')
      .margin({ bottom: 12 })

      Button() {
        Text('手动选择')
          .fontSize(14)
          .fontColor('#1A1F36')
      }
      .type(ButtonType.Normal)
      .width('100%')
      .height(44)
      .borderRadius(8)
      .backgroundColor('#F8F9FC')
      .border({ width: 1, color: '#E5E7EB' })
      .margin({ bottom: 24 })

      Text('边缘处理')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .margin({ bottom: 16 })
        .width('100%')

      Row() {
        Text('柔和')
          .fontSize(12)
          .fontColor('#C7C7CC')
        Blank()
        Text('锐利')
          .fontSize(12)
          .fontColor('#C7C7CC')
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 构建背景属性
  @Builder
  buildBackgroundProperties() {
    Column() {
      Text('背景模板')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .margin({ bottom: 16 })
        .width('100%')

      Grid() {
        ForEach(this.backgroundTemplates, (template: BackgroundTemplate) => {
          GridItem() {
            Button() {
              if (template.gradient) {
                // 渐变背景
                Blank()
              } else {
                Blank()
                  .backgroundColor(template.color || '#FFFFFF')
              }
            }
            .type(ButtonType.Normal)
            .width(60)
            .height(60)
            .borderRadius(8)
            .backgroundColor(template.color || '#F8F9FC')
            .border({
              width: this.selectedBackground === template.id ? 2 : 1,
              color: this.selectedBackground === template.id ? '#667eea' : '#E5E7EB'
            })
            .onClick(() => {
              this.selectedBackground = template.id;
            })
          }
        }, (template: BackgroundTemplate) => template.id)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .margin({ bottom: 24 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 构建光效属性
  @Builder
  buildLightingProperties() {
    Column() {
      Text('光效类型')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .margin({ bottom: 16 })
        .width('100%')

      Text('功能开发中...')
        .fontSize(14)
        .fontColor('#6B7280')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 构建尺寸属性
  @Builder
  buildSizeProperties() {
    Column() {
      Text('输出尺寸')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .margin({ bottom: 16 })
        .width('100%')

      Row() {
        ForEach(this.sizePresets, (preset: SizePreset) => {
          Button() {
            Column() {
              Text(preset.label)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.selectedSize === preset.id ? '#FFFFFF' : '#1A1F36')
              if (preset.dimensions) {
                Text(preset.dimensions)
                  .fontSize(11)
                  .fontColor(this.selectedSize === preset.id ? '#FFFFFF' : '#6B7280')
                  .opacity(this.selectedSize === preset.id ? 0.9 : 0.7)
                  .margin({ top: 2 })
              }
            }
            .justifyContent(FlexAlign.Center)
          }
          .type(ButtonType.Normal)
          .width(80)
          .height(60)
          .borderRadius(8)
          .backgroundColor(this.selectedSize === preset.id ? '#667eea' : '#F8F9FC')
          .border({
            width: this.selectedSize === preset.id ? 0 : 1,
            color: '#E5E7EB'
          })
          .margin({ right: 8 })
          .onClick(() => {
            this.selectedSize = preset.id;
          })
        }, (preset: SizePreset) => preset.id)
      }
      .width('100%')
      .margin({ bottom: 24 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 构建滤镜属性
  @Builder
  buildFilterProperties() {
    Column() {
      Text('滤镜效果')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .margin({ bottom: 16 })
        .width('100%')

      Text('功能开发中...')
        .fontSize(14)
        .fontColor('#6B7280')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 导出
  async handleExport() {
    console.info('导出图片');
    // TODO: 实现导出功能
    if (!this.imagePath) {
      console.error('没有可导出的图片');
      // TODO: 显示提示信息
      return;
    }

    try {
      // 这里可以实现图片保存功能
      // 可以使用 @kit.CoreFileKit 中的相关API
      console.info('图片导出成功');
      // TODO: 显示成功提示
    } catch (err) {
      console.error(`导出失败: ${JSON.stringify(err)}`);
      // TODO: 显示错误提示
    }
  }
}

