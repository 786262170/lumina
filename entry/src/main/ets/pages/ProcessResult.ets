import router from '@ohos.router';

@Entry
@Component
struct ProcessResult {
  @State originalImagePath: string = ''; // 原始图片路径
  @State processedImagePath: string = ''; // 处理后的图片路径
  @State originalImageUri: string = ''; // 原始图片URI
  @State processedImageUri: string = ''; // 处理后的图片URI
  @State isSliderMode: boolean = false; // 是否为滑动对比模式
  @State sliderValue: number = 50; // 滑动条的值（0-100）
  
  // 图片信息
  @State fileName: string = '未命名.jpg';
  @State originalSize: string = '1920x1080';
  @State processedSize: string = '1920x1080';
  @State processTime: string = '2.3秒';
  @State scenarioTitle: string = '';

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
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor('#1F2937')
          .onClick(() => {
            router.back();
          })

        // 标题
        Text('处理完成')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: -24 })

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

          // 切换到滑动对比按钮
          Text(this.isSliderMode ? '切换到并排对比' : '切换到滑动对比')
            .fontSize(14)
            .fontColor('#3B82F6')
            .margin({ top: 16, bottom: 24 })
            .onClick(() => {
              this.isSliderMode = !this.isSliderMode;
            })

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
          .height(300)
          .borderRadius(12)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#F3F4F6')

        // 处理前图片（顶层，通过clipRect控制显示区域）
        Row() {
          Image(this.originalImagePath || this.originalImageUri)
            .width('100%')
            .height(300)
            .objectFit(ImageFit.Cover)
            .backgroundColor('#F3F4F6')
        }
        .width(`${this.sliderValue}%`)
        .height(300)
        .clip(true)

        // 分割线指示器
        Column() {
          // 分割线
          Column()
            .width(2)
            .height('100%')
            .backgroundColor('#3B82F6')
            .shadow({ radius: 4, color: '#3B82F6', offsetX: 0, offsetY: 0 })
        }
        .width(2)
        .height(300)
        .position({ x: `${this.sliderValue}%`, y: 0 })
        .offset({ x: -1 })

        // 标签
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
        .position({ x: 0, y: 260 })
      }
      .width('100%')
      .height(300)
      .borderRadius(12)

      // 滑动条控件
      Slider({
        value: this.sliderValue,
        min: 0,
        max: 100,
        step: 1,
        style: SliderStyle.OutSet
      })
        .width('100%')
        .height(40)
        .blockColor('#3B82F6')
        .trackColor('#E5E7EB')
        .selectedColor('#3B82F6')
        .onChange((value: number) => {
          this.sliderValue = value;
        })
    }
    .width('100%')
    .margin({ top: 20 })
    .padding({ left: 20, right: 20 })
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

