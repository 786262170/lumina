import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';
import { picker } from '@kit.CoreFileKit';
import { BatchBackgroundTemplate } from '../common/types/CommonTypes';
import { TopNavBar } from '../common/components/TopNavBar';

@Entry
@Component
struct BatchProcess {
  @State selectedImageUris: string[] = []; // 选中的图片URI
  @State selectedImagePaths: string[] = []; // 选中的图片路径（用于显示）
  @State selectedBackgroundIndex: number = 0; // 选中的背景模板索引
  @State selectedSizePreset: string = '2000x2000'; // 选中的尺寸预设
  @State isProcessing: boolean = false; // 是否正在处理
  @State processingProgress: number = 0; // 处理进度（0-100）
  @State imageStatuses: Map<number, 'pending' | 'processing' | 'completed' | 'error'> = new Map(); // 每张图片的处理状态
  @State imageProgresses: Map<number, number> = new Map(); // 每张图片的处理进度

  // 背景模板选项
  private backgroundTemplates: BatchBackgroundTemplate[] = [
    { id: 0, name: '白色', color: '#FFFFFF', isGradient: false },
    { id: 1, name: '灰色', color: '#F3F4F6', isGradient: false },
    { id: 2, name: '紫色渐变', color: '#6366F1', isGradient: true, gradientColors: ['#6366F1', '#8B5CF6'] },
    { id: 3, name: '粉色渐变', color: '#EC4899', isGradient: true, gradientColors: ['#EC4899', '#F472B6'] }
  ];

  // 尺寸预设选项
  private sizePresets: string[] = ['2000x2000', '1600x1600', '自定义'];

  // 返回上一页
  async handleBack() {
    console.info('[BatchProcess] handleBack 被调用');
    try {
      await RouterService.getInstance().goBack();
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : String(err);
      console.error(`[BatchProcess] 返回失败: ${errorMsg}`);
      // 如果无法返回，则返回到首页
      try {
        await RouterService.getInstance().navigateTo('pages/Index', undefined, true);
      } catch (error) {
        const navErrorMsg = error instanceof Error ? error.message : String(error);
        console.error(`[BatchProcess] 跳转首页失败: ${navErrorMsg}`);
      }
    }
  }

  aboutToAppear() {
    // 页面初始化
  }

  build() {
    Column() {
      // 顶部导航栏（带更多选项按钮）
      Row() {
        // 左侧：TopNavBar（需要调整，因为TopNavBar本身是完整的Row）
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
            await this.handleBack();
          })

          // 标题
          Text('批量处理')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1F36')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ left: -40 })
        }
        .layoutWeight(1)
        
        // 右侧：更多选项按钮
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor('#6B7280')
          .onClick(() => {
            // 显示更多选项菜单（后续实现）
            console.info('显示更多选项');
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })

      // 内容区域
      Scroll() {
        Column() {
          // 上传区域
          Column() {
            Image($r('app.media.startIcon'))
              .width(48)
              .height(48)
              .fillColor('#3B82F6')
              .margin({ bottom: 12 })

            Text('点击上传或拖拽图片')
              .fontSize(14)
              .fontColor('#1F2937')
              .margin({ bottom: 4 })

            Text('最多支持100张')
              .fontSize(12)
              .fontColor('#6B7280')
          }
          .width('100%')
          .height(160)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .borderRadius(12)
          .border({ width: 1, style: BorderStyle.Dashed, color: '#D1D5DB' })
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            this.selectImages();
          })
          .margin({ top: 16, bottom: 16 })

          // 已选择图片区域
          if (this.selectedImagePaths.length > 0) {
            Column() {
              Row() {
                Text(`已选择${this.selectedImagePaths.length}张图片`)
                  .fontSize(14)
                  .fontColor('#1F2937')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)

                Text('清空')
                  .fontSize(14)
                  .fontColor('#EF4444')
                  .onClick(() => {
                    this.clearAllImages();
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 横向滚动的图片缩略图
              Scroll() {
                Row() {
                  ForEach(this.selectedImagePaths, (path: string, index: number) => {
                    Stack({ alignContent: Alignment.TopEnd }) {
                      Image(path)
                        .width(80)
                        .height(80)
                        .borderRadius(8)
                        .objectFit(ImageFit.Cover)
                        .backgroundColor('#F3F4F6')
                        .opacity(this.imageStatuses.get(index) === 'processing' ? 0.6 : 1)

                      // 处理状态遮罩
                      if (this.imageStatuses.get(index) === 'processing' || this.imageStatuses.get(index) === 'completed') {
                        Stack() {
                          // 进度条背景
                          Column()
                            .width(80)
                            .height(4)
                            .backgroundColor('rgba(0, 0, 0, 0.3)')
                            .borderRadius(2)

                          // 进度条
                          if (this.imageStatuses.get(index) === 'processing') {
                            Column()
                              .width(`${this.imageProgresses.get(index) || 0}%`)
                              .height(4)
                              .backgroundColor('#667eea')
                              .borderRadius(2)
                          }

                          // 完成图标
                          if (this.imageStatuses.get(index) === 'completed') {
                            Stack() {
                              Circle({ width: 20, height: 20 })
                                .fill('#10B981')
                              Text('✓')
                                .fontSize(12)
                                .fontColor('#FFFFFF')
                                .fontWeight(FontWeight.Medium)
                            }
                            .width(20)
                            .height(20)
                            .position({ x: 30, y: 30 })
                          }
                        }
                        .width(80)
                        .height(80)
                        .position({ x: 0, y: 0 })
                      }

                      // 错误状态
                      if (this.imageStatuses.get(index) === 'error') {
                        Stack() {
                          Circle({ width: 20, height: 20 })
                            .fill('#EF4444')
                          Text('×')
                            .fontSize(12)
                            .fontColor('#FFFFFF')
                            .fontWeight(FontWeight.Medium)
                        }
                        .width(20)
                        .height(20)
                        .position({ x: 60, y: 4 })
                      }

                      // 删除按钮（仅在待处理状态显示）
                      if (this.imageStatuses.get(index) === 'pending' || !this.imageStatuses.has(index)) {
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
                    }
                    .margin({ right: 12 })
                  }, (path: string, index: number) => `${path}_${index}`)
                }
                .padding({ left: 4, right: 4 })
              }
              .scrollBar(BarState.Off)
              .scrollable(ScrollDirection.Horizontal)
              .width('100%')
              .height(88)
            }
            .width('100%')
            .margin({ bottom: 24 })
          }

          // 统一设置区域
          Column() {
            Text('统一设置')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2937')
              .margin({ bottom: 16 })
              .width('100%')

            // 背景模板
            Column() {
              Text('背景模板')
                .fontSize(14)
                .fontColor('#6B7280')
                .margin({ bottom: 12 })
                .width('100%')

              Row() {
                ForEach(this.backgroundTemplates, (template: BatchBackgroundTemplate) => {
                  Column() {
                    if (template.isGradient && template.gradientColors) {
                      // 渐变背景
                      Row()
                        .width(60)
                        .height(60)
                        .borderRadius(8)
                        .linearGradient({
                          angle: 135,
                          colors: [
                            [template.gradientColors[0], 0],
                            [template.gradientColors[1], 1]
                          ]
                        })
                        .border({
                          width: this.selectedBackgroundIndex === template.id ? 2 : 0,
                          color: '#3B82F6'
                        })
                    } else {
                      // 纯色背景
                      Row()
                        .width(60)
                        .height(60)
                        .borderRadius(8)
                        .backgroundColor(template.color)
                        .border({
                          width: this.selectedBackgroundIndex === template.id ? 2 : 1,
                          color: this.selectedBackgroundIndex === template.id ? '#3B82F6' : '#E5E7EB'
                        })
                    }
                  }
                  .onClick(() => {
                    this.selectedBackgroundIndex = template.id;
                  })
                  .margin({ right: 12 })
                }, (template: BatchBackgroundTemplate) => `bg_${template.id}`)
              }
              .width('100%')
            }
            .width('100%')
            .margin({ bottom: 24 })

            // 尺寸预设
            Column() {
              Text('尺寸预设')
                .fontSize(14)
                .fontColor('#6B7280')
                .margin({ bottom: 12 })
                .width('100%')

              Row() {
                ForEach(this.sizePresets, (preset: string) => {
                  Button(preset)
                    .type(ButtonType.Normal)
                    .fontSize(14)
                    .fontColor(preset === this.selectedSizePreset ? '#FFFFFF' : '#6B7280')
                    .backgroundColor(preset === this.selectedSizePreset ? '#3B82F6' : '#F3F4F6')
                    .borderRadius(8)
                    .height(36)
                    .layoutWeight(1)
                    .onClick(() => {
                      if (preset === '自定义') {
                        // 显示自定义尺寸输入框（后续实现）
                        console.info('打开自定义尺寸设置');
                      } else {
                        this.selectedSizePreset = preset;
                      }
                    })
                    .margin({ right: preset !== this.sizePresets[this.sizePresets.length - 1] ? 12 : 0 })
                }, (preset: string) => preset)
              }
              .width('100%')
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      // 处理进度显示（处理中时显示）
      if (this.isProcessing) {
        Column() {
          Row() {
            Text(`处理中: ${Math.floor(this.processingProgress)}%`)
              .fontSize(14)
              .fontColor('#1A1F36')
              .layoutWeight(1)

            Text(`${this.getCompletedCount()}/${this.selectedImagePaths.length}`)
              .fontSize(14)
              .fontColor('#6B7280')
          }
          .width('100%')
          .margin({ bottom: 8 })

          // 总进度条
          Progress({
            value: this.processingProgress,
            total: 100,
            type: ProgressType.Linear
          })
            .width('100%')
            .height(8)
            .color('#667eea')
            .backgroundColor('#E5E7EB')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ left: 20, right: 20, bottom: 12 })
      }

      // 底部操作按钮
      Button(this.isProcessing ? '处理中...' : '开始批量处理')
        .type(ButtonType.Normal)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .width('100%')
        .height(48)
        .borderRadius(24)
        .linearGradient({
          angle: 0,
          colors: [
            ['#6366F1', 0],
            ['#8B5CF6', 1]
          ]
        })
        .enabled(this.selectedImagePaths.length > 0 && !this.isProcessing)
        .opacity(this.isProcessing ? 0.6 : 1)
        .onClick(() => {
          if (!this.isProcessing) {
          this.startBatchProcessing();
          }
        })
        .margin({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }

  // 选择多张图片
  async selectImages() {
    try {
      // Context will be obtained when needed
      const context: Context | null = null;
      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 100; // 最多选择100张

      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        // 合并新选择的图片（避免重复）
        const newUris = photoSelectResult.photoUris.filter(uri => !this.selectedImageUris.includes(uri));
        const totalCount = this.selectedImageUris.length + newUris.length;
        
        if (totalCount > 100) {
          // 如果超过100张，只添加前100张
          const remaining = 100 - this.selectedImageUris.length;
          this.selectedImageUris = this.selectedImageUris.concat(newUris.slice(0, remaining));
          this.selectedImagePaths = this.selectedImageUris;
        } else {
          this.selectedImageUris = this.selectedImageUris.concat(newUris);
          this.selectedImagePaths = this.selectedImageUris;
        }
        
        console.info(`已选择 ${this.selectedImageUris.length} 张图片`);
      }
    } catch (err) {
      console.error(`选择图片失败: ${JSON.stringify(err)}`);
    }
  }

  // 获取已完成数量
  getCompletedCount(): number {
    let count = 0;
    this.imageStatuses.forEach((status) => {
      if (status === 'completed') {
        count++;
      }
    });
    return count;
  }

  // 移除某张图片
  removeImage(index: number) {
    if (index >= 0 && index < this.selectedImagePaths.length) {
      this.selectedImagePaths.splice(index, 1);
      this.selectedImageUris.splice(index, 1);
      this.imageStatuses.delete(index);
      this.imageProgresses.delete(index);
    }
  }

  // 清空所有图片
  clearAllImages() {
    this.selectedImagePaths = [];
    this.selectedImageUris = [];
  }

  // 开始批量处理
  async startBatchProcessing() {
    if (this.selectedImageUris.length === 0) {
      return;
    }

    this.isProcessing = true;
    try {
      console.info(`开始批量处理 ${this.selectedImageUris.length} 张图片`);
      console.info(`背景模板: ${this.backgroundTemplates[this.selectedBackgroundIndex].name}`);
      console.info(`尺寸预设: ${this.selectedSizePreset}`);

      // TODO: 实现实际的批量图片处理逻辑
      // 1. 上传所有图片到服务器
      // 2. 调用批量图片处理API，应用统一设置
      // 3. 显示处理进度
      // 4. 处理完成后跳转到结果页面或工作台

      // 模拟处理过程
      await new Promise<void>(resolve => setTimeout(resolve, 2000));

      // 跳转到工作台页面
      const params: Record<string, string | number | boolean | string[] | undefined> = {} as Record<string, string | number | boolean | string[] | undefined>;
      params['imagePaths'] = this.selectedImagePaths;
      params['imageUris'] = this.selectedImageUris;
      params['scenarioId'] = 'batch';
      params['scenarioTitle'] = '批量处理';
      params['isBatch'] = true;
      params['backgroundTemplate'] = this.selectedBackgroundIndex;
      params['sizePreset'] = this.selectedSizePreset;
      RouterService.getInstance().navigateTo('pages/Workbench', params).catch((err: Error) => {
        console.error(`跳转到工作台失败: ${err.message}`);
      });
    } catch (err) {
      console.error(`批量处理失败: ${JSON.stringify(err)}`);
    } finally {
      this.isProcessing = false;
    }
  }
}

