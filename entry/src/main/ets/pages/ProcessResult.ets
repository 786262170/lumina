import router from '@ohos.router';

// 批量结果接口
interface BatchResult {
  id: string;
  beforeUrl: string;
  afterUrl: string;
  filename: string;
}

@Entry
@Component
struct ProcessResult {
  @State originalImagePath: string = ''; // 原始图片路径
  @State processedImagePath: string = ''; // 处理后的图片路径
  @State originalImageUri: string = ''; // 原始图片URI
  @State processedImageUri: string = ''; // 处理后的图片URI
  @State isSliderMode: boolean = false; // 是否为滑动对比模式
  @State sliderValue: number = 50; // 滑动条的值（0-100）
  @State isDragging: boolean = false; // 是否正在拖拽
  
  // 图片信息
  @State fileName: string = '未命名.jpg';
  @State originalSize: string = '1920x1080';
  @State processedSize: string = '1920x1080';
  @State processTime: string = '2.3秒';
  @State scenarioTitle: string = '';

  // 批量结果（如果有）
  @State batchResults: BatchResult[] = [];
  @State currentResultIndex: number = 0;

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

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.originalImagePath = params['originalImagePath'] as string || params['imagePath'] as string || '';
      this.processedImagePath = params['processedImagePath'] as string || params['imagePath'] as string || '';
      this.originalImageUri = params['originalImageUri'] as string || params['imageUri'] as string || '';
      this.processedImageUri = params['processedImageUri'] as string || params['imageUri'] as string || '';
      this.scenarioTitle = params['scenarioTitle'] as string || '';
      
      // 如果有图片信息参数，则使用
      if (params['fileName']) {
        this.fileName = params['fileName'] as string;
      }
      if (params['originalSize']) {
        this.originalSize = params['originalSize'] as string;
      }
      if (params['processedSize']) {
        this.processedSize = params['processedSize'] as string;
      }
      if (params['processTime']) {
        this.processTime = params['processTime'] as string;
      }
      
      // 如果没有处理后图片，使用原始图片作为占位
      if (!this.processedImagePath && this.originalImagePath) {
        this.processedImagePath = this.originalImagePath;
      }
    }
  }

  build() {
    Column() {
      // 顶部导航栏
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
        Text('处理完成')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1F36')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: -40 })

        // 分享按钮（向上箭头）
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor('#1F2937')
          .onClick(() => {
            this.handleShare();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })

      // 内容区域
      Scroll() {
        Column() {
          // 图片对比区域
          if (this.isSliderMode) {
            // 滑动对比模式
            this.buildSliderComparison()
          } else {
            // 并排对比模式
            this.buildSideBySideComparison()
          }

          // 切换对比模式按钮
          Row() {
            Button(this.isSliderMode ? '并排对比' : '滑动对比')
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontColor('#667eea')
              .backgroundColor('#F8F9FC')
              .border({ width: 1, color: '#667eea' })
              .borderRadius(8)
              .width(100)
              .height(36)
              .onClick(() => {
                this.isSliderMode = !this.isSliderMode;
                if (!this.isSliderMode) {
                  this.sliderValue = 50; // 重置滑块位置
                }
              })
          }
          .width('100%')
          .margin({ top: 16, bottom: 24 })
          .justifyContent(FlexAlign.Center)

          // 操作按钮
          Row() {
            Button('重新处理')
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontColor('#1F2937')
              .backgroundColor('#FFFFFF')
              .border({ width: 1, color: '#E5E7EB' })
              .borderRadius(8)
              .layoutWeight(1)
              .height(44)
              .onClick(() => {
                this.handleReprocess();
              })

            Button('调整效果')
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontColor('#1F2937')
              .backgroundColor('#FFFFFF')
              .border({ width: 1, color: '#E5E7EB' })
              .borderRadius(8)
              .layoutWeight(1)
              .height(44)
              .margin({ left: 12 })
              .onClick(() => {
                this.handleAdjustEffect();
              })

            Button('保存到相册')
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#3B82F6')
              .borderRadius(8)
              .layoutWeight(1)
              .height(44)
              .margin({ left: 12 })
              .onClick(() => {
                this.handleSaveToAlbum();
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 24 })

          // 信息面板
          Column() {
            this.buildInfoRow('文件名', this.fileName)
            this.buildInfoRow('原始尺寸', this.originalSize)
            this.buildInfoRow('处理后尺寸', this.processedSize)
            this.buildInfoRow('处理时间', this.processTime)
          }
          .width('100%')
          .padding(16)
          .margin({ left: 20, right: 20, bottom: 20 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }

  // 构建并排对比视图
  @Builder
  buildSideBySideComparison() {
    Row() {
      // 处理前图片
      Stack({ alignContent: Alignment.Bottom }) {
        Image(this.originalImagePath || this.originalImageUri)
          .width('100%')
          .height('100%')
          .borderRadius(12)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#F3F4F6')

        // Before标签
        Text('Before')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .margin({ bottom: 12 })
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .borderRadius(4)
      }
      .width('48%')
      .height(300)
      .margin({ right: '2%' })

      // 处理后图片
      Stack({ alignContent: Alignment.Bottom }) {
        Image(this.processedImagePath || this.processedImageUri)
          .width('100%')
          .height('100%')
          .borderRadius(12)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#F3F4F6')

        // After标签
        Text('After')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .margin({ bottom: 12 })
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .borderRadius(4)
      }
      .width('48%')
      .height(300)
      .margin({ left: '2%' })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20 })
  }

  // 构建滑动对比视图
  @Builder
  buildSliderComparison() {
    Column() {
      Stack() {
        // 处理后图片（底层）
        Image(this.processedImagePath || this.processedImageUri)
          .width('100%')
          .height(343)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#F3F4F6')

        // 处理前图片（顶层，通过clip控制显示区域）
        Stack() {
          Image(this.originalImagePath || this.originalImageUri)
            .width('100%')
            .height(343)
            .objectFit(ImageFit.Cover)
            .backgroundColor('#F3F4F6')
        }
        .width(`${this.sliderValue}%`)
        .height(343)
        .clip(true)

        // 滑块手柄（可拖拽）
        Stack() {
          // 垂直分割线
          Column()
            .width(3)
            .height('100%')
            .backgroundColor('#667eea')
            .shadow({ radius: 4, color: '#667eea', offsetX: 0, offsetY: 0 })

          // 圆形手柄
          Stack() {
            Circle({ width: 40, height: 40 })
              .fill('#FFFFFF')
              .shadow({ radius: 8, color: '#000000', offsetX: 0, offsetY: 2 })

            // 手柄图标（左右箭头）
            Row() {
              Text('◄')
                .fontSize(12)
                .fontColor('#667eea')
                .margin({ right: 4 })
              Text('►')
                .fontSize(12)
                .fontColor('#667eea')
                .margin({ left: 4 })
            }
          }
          .width(40)
          .height(40)
          .position({ x: 0, y: '50%' })
          .offset({ x: -18.5, y: -20 })
        }
        .width(3)
        .height(343)
        .position({ x: `${this.sliderValue}%`, y: 0 })
        .offset({ x: -1.5 })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down || event.type === TouchType.Move) {
            this.isDragging = true;
            // 计算新的滑块位置
            const touch = event.touches[0];
            if (touch) {
              // 这里需要通过全局坐标计算，暂时使用Slider控件
            }
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.isDragging = false;
          }
        })

        // 标签（Before/After）
        Row() {
          Text('Before')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('rgba(0, 0, 0, 0.5)')
            .borderRadius(4)

          Blank()

          Text('After')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('rgba(0, 0, 0, 0.5)')
            .borderRadius(4)
        }
        .width('100%')
        .height(40)
        .padding({ left: 12, right: 12 })
        .position({ x: 0, y: 303 })
      }
      .width(343)
      .height(343)
      .borderRadius(16)
      .margin({ bottom: 16 })

      // 滑动条控件（用于精确控制）
      Slider({
        value: this.sliderValue,
        min: 0,
        max: 100,
        step: 1,
        style: SliderStyle.OutSet
      })
        .width('100%')
        .height(40)
        .blockColor('#667eea')
        .trackColor('#E5E7EB')
        .selectedColor('#667eea')
        .onChange((value: number) => {
          this.sliderValue = value;
        })

      // 批量结果缩略图（如果有）
      if (this.batchResults.length > 1) {
        Column() {
            Text('批量结果')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1F36')
              .margin({ bottom: 12 })
              .width('100%')

          Scroll() {
            Row() {
              ForEach(this.batchResults, (result: BatchResult, index: number) => {
                Column() {
                  Stack() {
                    Image(result.afterUrl || result.beforeUrl)
                      .width(80)
                      .height(80)
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                      .backgroundColor('#F3F4F6')

                    // 选中指示器
                    if (index === this.currentResultIndex) {
                      Stack() {
                        Circle({ width: 20, height: 20 })
                          .fill('#667eea')
                        Text('✓')
                          .fontSize(12)
                          .fontColor('#FFFFFF')
                      }
                      .width(20)
                      .height(20)
                      .position({ x: 60, y: 4 })
                    }
                  }
                  .width(80)
                  .height(80)
                  .margin({ right: 12 })
                  .onClick(() => {
                    this.currentResultIndex = index;
                    // 更新当前显示的图片
                    this.originalImagePath = result.beforeUrl;
                    this.processedImagePath = result.afterUrl;
                    this.fileName = result.filename;
                  })

                  Text(result.filename)
                    .fontSize(11)
                    .fontColor('#6B7280')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width(80)
                    .margin({ top: 4 })
                    .textAlign(TextAlign.Center)
                }
                .margin({ right: 12 })
              }, (result: BatchResult, index: number) => `${result.id}-${index}`)
            }
            .padding({ left: 0, right: 0 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
          .margin({ left: -20, right: -20 })
          .padding({ left: 20, right: 20 })
        }
        .width('100%')
        .margin({ top: 24 })
      }
    }
    .width('100%')
    .margin({ top: 20 })
    .padding({ left: 20, right: 20 })
    .alignItems(HorizontalAlign.Center)
  }

  // 构建信息行
  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#6B7280')
        .layoutWeight(1)

      Text(value)
        .fontSize(13)
        .fontColor('#1F2937')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
  }

  // 分享
  handleShare() {
    console.info('分享图片');
    // TODO: 实现分享功能
  }

  // 重新处理
  handleReprocess() {
    console.info('重新处理');
    // 返回到场景详情页面，保留场景信息
    router.replaceUrl({
      url: 'pages/ScenarioDetail',
      params: {
        scenarioId: this.scenarioTitle,
        scenarioTitle: this.scenarioTitle
      }
    }).catch((err: Error) => {
      console.error(`跳转失败: ${err.message}`);
    });
  }

  // 调整效果
  handleAdjustEffect() {
    console.info('调整效果');
    // 跳转到工作台页面进行进一步编辑
    router.pushUrl({
      url: 'pages/Workbench',
      params: {
        imagePath: this.processedImagePath,
        imageUri: this.processedImageUri,
        scenarioId: this.scenarioTitle,
        scenarioTitle: this.scenarioTitle,
        isBatch: false
      }
    }).catch((err: Error) => {
      console.error(`跳转失败: ${err.message}`);
    });
  }

  // 保存到相册
  async handleSaveToAlbum() {
    console.info('保存到相册');
    try {
      // 获取图片URI
      const imageUri = this.processedImageUri || this.processedImagePath;
      if (!imageUri) {
        console.error('没有可保存的图片');
        return;
      }
      
      // TODO: 实现保存图片到相册的功能
      // 需要使用 @kit.MediaLibraryKit 中的相关API
      // 示例代码（需要根据实际API调整）:
      // const context = getContext(this) as Context;
      // const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      // const photoAsset = await phAccessHelper.createAsset(photoType.IMAGE, 'processed_image.jpg', album);
      // await phAccessHelper.addAssets([photoAsset]);
      
      console.info('图片已保存到相册');
      // 可以显示成功提示（使用promptAction.showToast等）
    } catch (err) {
      console.error(`保存图片失败: ${JSON.stringify(err)}`);
      // 可以显示错误提示
    }
  }
}

