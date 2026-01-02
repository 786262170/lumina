import router from '@ohos.router';
import { picker } from '@kit.CoreFileKit';
import { ToolItem } from '../common/types/CommonTypes';

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

  // 工具栏图标列表
  private tools: ToolItem[] = [
    { id: 0, name: '上传', icon: 'upload' },
    { id: 1, name: '裁剪', icon: 'crop' },
    { id: 2, name: '图库', icon: 'gallery' },
    { id: 3, name: '增强', icon: 'enhance' },
    { id: 4, name: '全屏', icon: 'fullscreen' },
    { id: 5, name: '设置', icon: 'settings' }
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
    Row() {
      // 左侧工具栏
      Column() {
        ForEach(this.tools, (tool: ToolItem) => {
          Column() {
            // 圆形图标按钮
            Stack() {
              Circle({ width: 48, height: 48 })
                .fill(this.selectedTool === tool.id ? '#6366F1' : '#F3F4F6')
                .stroke(this.selectedTool === tool.id ? '#6366F1' : '#E5E7EB')
                .strokeWidth(1)

              // 图标（使用Image组件，后续可以替换为实际图标）
              Image($r('app.media.startIcon'))
                .width(24)
                .height(24)
                .fillColor(this.selectedTool === tool.id ? '#FFFFFF' : '#6B7280')
            }
            .width(48)
            .height(48)
            .opacity(this.selectedTool === tool.id ? 1 : 0.8)
            .scale({ x: this.selectedTool === tool.id ? 1.1 : 1.0, y: this.selectedTool === tool.id ? 1.1 : 1.0 })
            .animation({
              duration: 200,
              curve: Curve.EaseOut
            })
            .onClick(() => {
              this.handleToolClick(tool.id);
            })
          }
          .width(48)
          .margin({ bottom: 16 })
        }, (tool: ToolItem) => tool.id.toString())
      }
      .width(64)
      .padding({ top: 20, bottom: 20 })
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
                .fillColor('#9CA3AF')
                .margin({ bottom: 12 })

              Text('暂无图片')
                .fontSize(14)
                .fontColor('#9CA3AF')
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
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
          Row() {
            Text(this.imageInfo)
              .fontSize(12)
              .fontColor('#6B7280')
          }
          .width('100%')
          .height(32)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#F9FAFB')
          .border({ width: { top: 1 }, color: '#E5E7EB' })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')

    // 底部操作栏
    .overlay(this.buildBottomBar(), {
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
          .width(20)
          .height(20)
          .fillColor(this.canUndo ? '#1F2937' : '#9CA3AF')
      }
      .type(ButtonType.Circle)
      .width(40)
      .height(40)
      .backgroundColor('#FFFFFF')
      .border({ width: 1, color: '#E5E7EB' })
      .enabled(this.canUndo)
      .onClick(() => {
        this.handleUndo();
      })

      // 重做按钮
      Button() {
        Image($r('app.media.startIcon'))
          .width(20)
          .height(20)
          .fillColor(this.canRedo ? '#1F2937' : '#9CA3AF')
      }
      .type(ButtonType.Circle)
      .width(40)
      .height(40)
      .backgroundColor('#FFFFFF')
      .border({ width: 1, color: '#E5E7EB' })
      .margin({ left: 12 })
      .enabled(this.canRedo)
      .onClick(() => {
        this.handleRedo();
      })

      Blank()

      // 应用按钮（紫色渐变）
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
        angle: 0,
        colors: [
          ['#6366F1', 0],
          ['#8B5CF6', 1]
        ]
      })
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
            .fillColor('#3B82F6')
            .margin({ right: 6 })

          Text('导出')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#3B82F6')
        }
        .justifyContent(FlexAlign.Center)
      }
      .type(ButtonType.Normal)
      .width(100)
      .height(40)
      .borderRadius(20)
      .backgroundColor('#FFFFFF')
      .border({ width: 1, color: '#3B82F6' })
      .onClick(() => {
        this.handleExport();
      })
    }
    .width('100%')
    .height(64)
    .padding({ left: 20, right: 20 })
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

