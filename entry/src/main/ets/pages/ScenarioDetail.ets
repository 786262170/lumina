import router from '@ohos.router';
import { picker } from '@kit.CoreFileKit';
import { BackgroundTemplate } from '../common/types/CommonTypes';

@Entry
@Component
struct ScenarioDetail {
  @State scenarioId: string = '';
  @State scenarioTitle: string = '';
  @State selectedImageUri: string = ''; // 选中的图片URI
  @State selectedImagePath: string = ''; // 选中的图片路径（用于显示）
  @State selectedImageUris: string[] = []; // 批量处理时选中的多张图片URI
  @State selectedImagePaths: string[] = []; // 批量处理时选中的多张图片路径
  @State isProcessing: boolean = false; // 是否正在处理
  @State processingProgress: number = 0; // 处理进度（0-100）
  @State selectedTemplate: BackgroundTemplate | null = null; // 选中的背景模板

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.scenarioId = params['scenarioId'] as string || '';
      this.scenarioTitle = params['scenarioTitle'] as string || '';
      
      // 检查是否有返回的模板选择结果
      if (params['isSelected']) {
        const template: BackgroundTemplate = {
          id: params['templateId'] as string || '',
          title: params['templateTitle'] as string || '',
          category: params['templateCategory'] as string || '',
          rating: params['templateRating'] as number || 0,
          thumbnail: '',
          isSelected: true
        };
        this.selectedTemplate = template;
        console.info(`已选择模板: ${template.title}`);
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
        Text(this.scenarioTitle || '淘宝白底图')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: -24 })

        // 帮助按钮
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor('#6B7280')
          .borderRadius(12)
          .backgroundColor('#F3F4F6')
          .padding(4)
          .onClick(() => {
            // 显示帮助信息（后续实现）
            console.info('显示帮助信息');
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
          // 场景说明区域
          Row() {
            // 信息图标
            Image($r('app.media.startIcon'))
              .width(20)
              .height(20)
              .fillColor('#6366F1')
              .margin({ right: 12 })

            Column() {
              Text('场景说明')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
                .margin({ bottom: 4 })

              Text(this.getScenarioDescription())
                .fontSize(13)
                .fontColor('#6B7280')
                .lineHeight(18)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .padding(16)
          .margin({ top: 16, bottom: 16 })
          .backgroundColor('#F5F3FF')
          .borderRadius(12)

          // 图片上传区域
          if (this.isBatchMode() && this.selectedImagePaths.length === 0) {
            // 批量处理模式 - 未选择图片
            Column() {
              // 上传图标
              Image($r('app.media.startIcon'))
                .width(48)
                .height(48)
                .fillColor('#3B82F6')
                .margin({ bottom: 16 })

              Text('点击上传多张图片')
                .fontSize(14)
                .fontColor('#92400E')
                .margin({ bottom: 8 })

              Text('支持JPG、PNG格式，最多50张')
                .fontSize(12)
                .fontColor('#9CA3AF')
            }
            .width('100%')
            .height(280)
            .justifyContent(FlexAlign.Center)
            .borderRadius(12)
            .border({ width: 1, style: BorderStyle.Dashed, color: '#D1D5DB' })
            .backgroundColor('#FFFFFF')
            .onClick(() => {
              this.selectImages();
            })
          } else if (!this.isBatchMode() && this.selectedImagePath === '') {
            // 单张图片模式 - 未选择图片
            Column() {
              // 上传图标
              Image($r('app.media.startIcon'))
                .width(48)
                .height(48)
                .fillColor('#3B82F6')
                .margin({ bottom: 16 })

              Text('点击或拖拽上传图片')
                .fontSize(14)
                .fontColor('#92400E')
                .margin({ bottom: 8 })

              Text('支持JPG、PNG格式')
                .fontSize(12)
                .fontColor('#9CA3AF')
            }
            .width('100%')
            .height(280)
            .justifyContent(FlexAlign.Center)
            .borderRadius(12)
            .border({ width: 1, style: BorderStyle.Dashed, color: '#D1D5DB' })
            .backgroundColor('#FFFFFF')
            .onClick(() => {
              this.selectImage();
            })

          // 背景模板选择按钮
          if (this.selectedTemplate) {
            // 已选择模板，显示模板信息
            Row() {
              Column() {
                Row() {
                  Image($r('app.media.startIcon'))
                    .width(16)
                    .height(16)
                    .fillColor('#10B981')
                    .margin({ right: 6 })

                  Text('已选择: ' + this.selectedTemplate.title)
                    .fontSize(14)
                    .fontColor('#10B981')
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .margin({ bottom: 4 })

                Text(this.selectedTemplate.category + ' · ' + this.selectedTemplate.rating + '⭐')
                  .fontSize(12)
                  .fontColor('#6B7280')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Button('更换')
                .type(ButtonType.Normal)
                .fontSize(12)
                .fontColor('#6366F1')
                .backgroundColor('#EEF2FF')
                .borderRadius(16)
                .height(28)
                .padding({ left: 12, right: 12 })
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/BackgroundTemplates'
                  }).catch((err: Error) => {
                    console.error(`跳转失败: ${err.message}`);
                  });
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .margin({ top: 12 })
            .borderRadius(8)
            .border({ width: 1, color: '#10B981' })
            .backgroundColor('#F0FDF4')
          } else {
            // 未选择模板，显示选择按钮
            Row() {
              Image($r('app.media.startIcon'))
                .width(20)
                .height(20)
                .fillColor('#6366F1')
                .margin({ right: 8 })

              Text('选择背景模板')
                .fontSize(14)
                .fontColor('#6366F1')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)

              Image($r('app.media.startIcon'))
                .width(16)
                .height(16)
                .fillColor('#6366F1')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .margin({ top: 12 })
            .borderRadius(8)
            .border({ width: 1, color: '#6366F1' })
            .backgroundColor('#EEF2FF')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/BackgroundTemplates'
              }).catch((err: Error) => {
                console.error(`跳转失败: ${err.message}`);
              });
            })
          }
          } else if (this.isBatchMode() && this.selectedImagePaths.length > 0) {
            // 批量处理模式 - 已选择图片
            Column() {
              Text(`已选择 ${this.selectedImagePaths.length} 张图片`)
                .fontSize(14)
                .fontColor('#1F2937')
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 12 })

              // 图片网格预览
              Grid() {
                ForEach(this.selectedImagePaths, (path: string, index: number) => {
                  GridItem() {
                    Stack({ alignContent: Alignment.TopEnd }) {
                      Image(path)
                        .width('100%')
                        .height('100%')
                        .borderRadius(8)
                        .objectFit(ImageFit.Cover)
                        .backgroundColor('#F3F4F6')

                      // 删除按钮
                      Image($r('app.media.startIcon'))
                        .width(20)
                        .height(20)
                        .fillColor('#FFFFFF')
                        .backgroundColor('#EF4444')
                        .borderRadius(10)
                        .padding(4)
                        .margin({ top: 4, right: 4 })
                        .onClick(() => {
                          this.removeImage(index);
                        })
                    }
                    .width('100%')
                    .height('100%')
                  }
                }, (path: string, index: number) => `${path}_${index}`)
              }
              .columnsTemplate('1fr 1fr 1fr')
              .columnsGap(8)
              .rowsGap(8)
              .width('100%')
              .height(200)
              .margin({ bottom: 16 })

              Row() {
                Button('重新选择')
                  .type(ButtonType.Normal)
                  .fontSize(14)
                  .fontColor('#6B7280')
                  .backgroundColor('#F3F4F6')
                  .borderRadius(8)
                  .layoutWeight(1)
                  .onClick(() => {
                    this.selectedImagePaths = [];
                    this.selectedImageUris = [];
                  })

                Button('开始处理')
                  .type(ButtonType.Normal)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#3B82F6')
                  .borderRadius(8)
                  .layoutWeight(1)
                  .margin({ left: 12 })
                  .enabled(!this.isProcessing)
                  .onClick(() => {
                    this.processImage();
                  })
              }
              .width('100%')
            }
            .width('100%')
          } else {
            // 单张图片模式 - 已选择图片
            Column() {
              Image(this.selectedImagePath)
                .width('100%')
                .height(300)
                .borderRadius(12)
                .objectFit(ImageFit.Cover)
                .backgroundColor('#F3F4F6')

              Row() {
                Button('重新上传')
                  .type(ButtonType.Normal)
                  .fontSize(14)
                  .fontColor('#6B7280')
                  .backgroundColor('#F3F4F6')
                  .borderRadius(8)
                  .layoutWeight(1)
                  .onClick(() => {
                    this.selectedImagePath = '';
                    this.selectedImageUri = '';
                  })

                Button('开始处理')
                  .type(ButtonType.Normal)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#3B82F6')
                  .borderRadius(8)
                  .layoutWeight(1)
                  .margin({ left: 12 })
                  .enabled(!this.isProcessing)
                  .onClick(() => {
                    this.processImage();
                  })
              }
              .width('100%')
              .margin({ top: 16 })
            }
            .width('100%')
          }

        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      // 处理进度提示（条件显示）
      if (this.isProcessing) {
        Column() {
          Progress({ value: this.processingProgress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .height(4)
            .color('#3B82F6')
            .backgroundColor('#E5E7EB')

          Row() {
            Text(`正在处理中... ${this.processingProgress}%`)
              .fontSize(14)
              .fontColor('#6B7280')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { top: 1 }, color: '#E5E7EB' })
      }

      // 底部按钮区域
      Row() {
        Button('预览效果')
          .type(ButtonType.Normal)
          .fontSize(16)
          .fontColor('#6B7280')
          .backgroundColor('#F3F4F6')
          .borderRadius(8)
          .layoutWeight(1)
          .height(48)
          .enabled(this.hasSelectedImages() && !this.isProcessing)
          .onClick(() => {
            this.previewImage();
          })

        Button(this.isProcessing ? '处理中...' : '开始处理')
          .type(ButtonType.Normal)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isProcessing ? '#9CA3AF' : '#3B82F6')
          .borderRadius(8)
          .layoutWeight(1)
          .height(48)
          .margin({ left: 12 })
          .enabled(this.hasSelectedImages() && !this.isProcessing)
          .onClick(() => {
            this.processImage();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 1 }, color: '#E5E7EB' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }

  // 获取场景描述
  getScenarioDescription(): string {
    const descriptions: Record<string, string> = {
      'taobao': '自动生成纯白背景，符合淘宝平台规格',
      'douyin': '自动适配竖屏比例，优化商品展示效果',
      'xiaohongshu': '自动裁剪为3:4比例，提升内容吸引力',
      'batch': '批量处理多张图片，一次性完成所有优化',
      'amazon': '符合Amazon图片规范，自动优化图片质量',
      'custom': '自定义处理参数，灵活调整各项设置'
    };
    return descriptions[this.scenarioId] || '上传图片开始处理';
  }

  // 获取处理提示
  getProcessingTips(): string {
    const tips: Record<string, string> = {
      'taobao': '• 支持JPG、PNG格式\n• 图片大小不超过10MB\n• 建议使用清晰的产品图片\n• 处理时间约10-30秒',
      'douyin': '• 自动适配竖屏比例\n• 优化图片清晰度\n• 支持添加文字水印\n• 处理时间约15-30秒',
      'xiaohongshu': '• 自动裁剪为3:4比例\n• 优化图片色彩\n• 支持多种滤镜效果\n• 处理时间约10-20秒',
      'batch': '• 支持同时处理最多50张图片\n• 自动应用相同处理参数\n• 批量下载处理结果\n• 处理时间根据数量而定',
      'amazon': '• 符合Amazon图片规范\n• 自动优化图片质量\n• 支持多角度产品图\n• 处理时间约15-30秒',
      'custom': '• 可自定义背景颜色\n• 可调整图片尺寸\n• 可添加文字和贴纸\n• 处理时间根据复杂度而定'
    };
    return tips[this.scenarioId] || '请上传图片开始处理';
  }

  // 判断是否为批量处理模式
  isBatchMode(): boolean {
    return this.scenarioId === 'batch';
  }

  // 判断是否已选择图片
  hasSelectedImages(): boolean {
    if (this.isBatchMode()) {
      return this.selectedImagePaths.length > 0;
    } else {
      return this.selectedImagePath !== '';
    }
  }

  // 选择单张图片
  async selectImage() {
    try {
      // Context will be obtained when needed
      const context: Context | null = null;
      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.selectedImageUri = photoSelectResult.photoUris[0];
        // 将URI转换为路径用于显示
        this.selectedImagePath = this.selectedImageUri;
        console.info(`已选择图片: ${this.selectedImageUri}`);
      }
    } catch (err) {
      console.error(`选择图片失败: ${JSON.stringify(err)}`);
      // 可以显示错误提示
    }
  }

  // 选择多张图片（批量处理）
  async selectImages() {
    try {
      // Context will be obtained when needed
      const context: Context | null = null;
      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 50; // 最多选择50张

      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.selectedImageUris = photoSelectResult.photoUris;
        // 将URI转换为路径用于显示
        this.selectedImagePaths = this.selectedImageUris;
        console.info(`已选择 ${this.selectedImageUris.length} 张图片`);
      }
    } catch (err) {
      console.error(`选择图片失败: ${JSON.stringify(err)}`);
      // 可以显示错误提示
    }
  }

  // 移除批量处理中的某张图片
  removeImage(index: number) {
    if (index >= 0 && index < this.selectedImagePaths.length) {
      this.selectedImagePaths.splice(index, 1);
      this.selectedImageUris.splice(index, 1);
    }
  }

  // 预览图片
  previewImage() {
    if (this.isBatchMode()) {
      if (this.selectedImagePaths.length > 0) {
        // 批量预览（后续可以实现图片轮播预览）
        console.info(`预览 ${this.selectedImagePaths.length} 张图片`);
      }
    } else {
      if (this.selectedImagePath) {
        // 打开图片预览（后续可以实现全屏预览）
        console.info(`预览图片: ${this.selectedImagePath}`);
        // 可以使用ImagePreview组件实现全屏预览
      }
    }
  }

  // 处理图片
  async processImage() {
    if (this.isBatchMode()) {
      if (this.selectedImageUris.length === 0) {
        return;
      }
    } else {
      if (!this.selectedImageUri) {
        return;
      }
    }

    this.isProcessing = true;
    this.processingProgress = 0;
    try {
      if (this.isBatchMode()) {
        console.info(`开始批量处理图片，场景：${this.scenarioTitle}, 共 ${this.selectedImageUris.length} 张`);
        // TODO: 实现实际的批量图片处理逻辑
        // 1. 上传所有图片到服务器
        // 2. 调用批量图片处理API
        // 3. 显示处理进度
        // 4. 处理完成后跳转到结果页面

        // 模拟处理过程，更新进度
        const totalImages = this.selectedImageUris.length;
        for (let i = 0; i < totalImages; i++) {
          await new Promise<void>(resolve => setTimeout(resolve, 1000));
          this.processingProgress = Math.floor(((i + 1) / totalImages) * 100);
        }
        console.info('批量图片处理完成');
        
        // 跳转到工作台页面
        router.pushUrl({
          url: 'pages/Workbench',
          params: {
            imagePaths: this.selectedImagePaths,
            imageUris: this.selectedImageUris,
            scenarioId: this.scenarioId,
            scenarioTitle: this.scenarioTitle,
            isBatch: true,
            templateId: this.selectedTemplate?.id || '',
            templateTitle: this.selectedTemplate?.title || ''
          }
        }).catch((err: Error) => {
          console.error(`跳转到工作台失败: ${err.message}`);
        });
      } else {
        console.info(`开始处理图片，场景：${this.scenarioTitle}, URI: ${this.selectedImageUri}`);
        // TODO: 实现实际的图片处理逻辑
        // 1. 上传图片到服务器
        // 2. 调用图片处理API
        // 3. 显示处理进度
        // 4. 处理完成后跳转到结果页面

        // 模拟处理过程，更新进度
        const steps = ['上传图片', '处理中', '优化中', '完成'];
        for (let i = 0; i < steps.length; i++) {
          await new Promise<void>(resolve => setTimeout(resolve, 500));
          this.processingProgress = Math.floor(((i + 1) / steps.length) * 100);
        }
        console.info('图片处理完成');
        
        // 跳转到工作台页面
        router.pushUrl({
          url: 'pages/Workbench',
          params: {
            imagePath: this.selectedImagePath,
            imageUri: this.selectedImageUri,
            scenarioId: this.scenarioId,
            scenarioTitle: this.scenarioTitle,
            isBatch: false,
            templateId: this.selectedTemplate?.id || '',
            templateTitle: this.selectedTemplate?.title || ''
          }
        }).catch((err: Error) => {
          console.error(`跳转到工作台失败: ${err.message}`);
        });
      }
    } catch (err) {
      console.error(`处理图片失败: ${JSON.stringify(err)}`);
      // 可以显示错误提示
    } finally {
      this.isProcessing = false;
      this.processingProgress = 0;
    }
  }
}

