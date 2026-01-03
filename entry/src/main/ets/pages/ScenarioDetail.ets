import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';
import { picker } from '@kit.CoreFileKit';
import { BackgroundTemplate } from '../common/types/CommonTypes';
import { TopNavBar } from '../common/components/TopNavBar';
import { ImageService, SceneType, ImageOperation, ImageOperationParams, ProcessImageRequest, FileData } from '../common/services/ImageService';
import { ToastUtil } from '../common/utils/ToastUtil';
import { UserService } from '../common/services/UserService';
import fs from '@ohos.file.fs';
import fileIo from '@ohos.fileio';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Context } from '@kit.AbilityKit';
import { dataSharePredicates } from '@kit.ArkData';
import { abilityAccessCtrl } from '@kit.AbilityKit';

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
  // 快速设置
  @State outputSize: string = '2000x2000'; // 输出尺寸
  @State quality: number = 85; // 输出质量（0-100）
  @State edgeSmoothing: boolean = true; // 边缘平滑

  private imageService: ImageService = ImageService.getInstance();

  // 返回上一页
  async handleBack() {
    console.info('[ScenarioDetail] handleBack 被调用');
    try {
      await RouterService.getInstance().goBack();
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : String(err);
      console.error(`[ScenarioDetail] 返回失败: ${errorMsg}`);
      // 如果无法返回，则返回到首页
      try {
        await RouterService.getInstance().navigateTo('pages/Index', undefined, true);
      } catch (error) {
        const navErrorMsg = error instanceof Error ? error.message : String(error);
        console.error(`[ScenarioDetail] 跳转首页失败: ${navErrorMsg}`);
      }
    }
  }

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
            console.info('[ScenarioDetail] 返回按钮被点击');
            await this.handleBack();
          })

        // 标题
        Text(this.scenarioTitle || '淘宝白底图')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1F36')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: -40 })
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
          // 场景信息横幅（渐变背景）
          Column() {
            Text(this.scenarioTitle || '淘宝白底图')
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .margin({ bottom: 8 })

            Text(this.getScenarioDescription())
              .fontSize(14)
              .fontColor('#FFFFFF')
              .opacity(0.9)
              .lineHeight(20)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 24, bottom: 24 })
          .linearGradient({
            angle: 135,
            colors: [
              ['#667eea', 0.0],
              ['#764ba2', 1.0]
            ]
          })
          .borderRadius({ bottomLeft: 24, bottomRight: 24 })
          .margin({ bottom: 24 })

          // 快速设置区域
          Column() {
            Text('快速设置')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1F36')
              .margin({ bottom: 16 })
              .width('100%')

            // 输出尺寸选择
            Column() {
              Text('输出尺寸')
                .fontSize(14)
                .fontColor('#6B7280')
                .margin({ bottom: 12 })
                .width('100%')

              Row() {
                ForEach(this.getSizePresets(), (preset: string) => {
                  Button(preset)
                    .type(ButtonType.Normal)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.outputSize === preset ? '#FFFFFF' : '#1A1F36')
                    .backgroundColor(this.outputSize === preset ? '#667eea' : '#F8F9FC')
                    .border({
                      width: this.outputSize === preset ? 0 : 1,
                      color: '#E5E7EB'
                    })
                    .borderRadius(8)
                    .height(36)
                    .layoutWeight(1)
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.outputSize = preset;
                    })
                }, (preset: string) => preset)
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 12 })

            // 输出质量滑块
            Column() {
              Row() {
                Text('输出质量')
                  .fontSize(14)
                  .fontColor('#6B7280')
                  .layoutWeight(1)

                Text(`${this.quality}%`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#667eea')
              }
              .width('100%')
              .margin({ bottom: 12 })

              Slider({
                value: this.quality,
                min: 0,
                max: 100,
                step: 1,
                style: SliderStyle.OutSet
              })
                .width('100%')
                .blockColor('#667eea')
                .trackColor('#E5E7EB')
                .selectedColor('#667eea')
                .onChange((value: number) => {
                  this.quality = value;
                })

          Row() {
                Text('低')
                  .fontSize(12)
                  .fontColor('#C7C7CC')
                Blank()
                Text('高')
                  .fontSize(12)
                  .fontColor('#C7C7CC')
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 12 })

            // 边缘平滑开关
            Row() {
            Column() {
                Text('边缘平滑')
                .fontSize(14)
                  .fontColor('#1A1F36')
                .margin({ bottom: 4 })

                Text('优化边缘细节，让抠图更自然')
                  .fontSize(12)
                .fontColor('#6B7280')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.edgeSmoothing })
                .selectedColor('#667eea')
                .switchPointColor('#FFFFFF')
                .onChange((isOn: boolean) => {
                  this.edgeSmoothing = isOn;
                })
          }
          .width('100%')
          .padding(16)
            .backgroundColor('#FFFFFF')
          .borderRadius(12)
            .margin({ bottom: 24 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Start)

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
                  RouterService.getInstance().navigateTo('pages/BackgroundTemplates')
                    .catch((err: Error) => {
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
              RouterService.getInstance().navigateTo('pages/BackgroundTemplates')
                .catch((err: Error) => {
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

  // 获取尺寸预设列表
  getSizePresets(): string[] {
    const presets: Record<string, string[]> = {
      'taobao': ['2000x2000', '1600x1600', '1000x1000'],
      'douyin': ['1080x1920', '720x1280', '540x960'],
      'xiaohongshu': ['1242x1660', '1080x1440', '900x1200'],
      'amazon': ['2000x2000', '1600x1600', '1000x1000'],
      'custom': ['2000x2000', '1600x1600', '1000x1000']
    };
    return presets[this.scenarioId] || ['2000x2000', '1600x1600', '1000x1000'];
  }

  // 选择单张图片
  async selectImage() {
    try {
      // 优先尝试使用文件选择器（DocumentViewPicker），这样可以避免媒体库URI的问题
      // 如果文件选择器不可用，再使用相册选择器
      try {
        const documentPicker = new picker.DocumentViewPicker();
        const documentSelectOptions = new picker.DocumentSelectOptions();
        documentSelectOptions.fileSuffixFilters = ['.jpg', '.jpeg', '.png', '.webp'];
        documentSelectOptions.maxSelectNumber = 1;
        
        const documentSelectResult = await documentPicker.select(documentSelectOptions);
        if (documentSelectResult && documentSelectResult.length > 0) {
          this.selectedImageUri = documentSelectResult[0];
          this.selectedImagePath = this.selectedImageUri;
          console.info(`已选择图片（文件选择器）: ${this.selectedImageUri}`);
          return;
        }
      } catch (docError) {
        console.warn(`文件选择器失败，尝试使用相册选择器: ${docError}`);
      }
      
      // 如果文件选择器失败，使用相册选择器（但可能无法读取）
      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.selectedImageUri = photoSelectResult.photoUris[0];
        // 将URI转换为路径用于显示
        this.selectedImagePath = this.selectedImageUri;
        console.info(`已选择图片（相册选择器）: ${this.selectedImageUri}`);
        // 提示用户：如果选择的是相册中的图片，可能无法读取，建议使用文件选择器
        if (this.selectedImageUri.startsWith('file://media/Photo/')) {
          ToastUtil.showError('提示：从相册选择的图片可能无法读取，建议使用文件管理器选择图片');
        }
      }
    } catch (err) {
      console.error(`选择图片失败: ${JSON.stringify(err)}`);
      ToastUtil.showError('选择图片失败，请重试');
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
        const batchParams: Record<string, string | number | boolean | string[] | undefined> = {} as Record<string, string | number | boolean | string[] | undefined>;
        batchParams['imagePaths'] = this.selectedImagePaths;
        batchParams['imageUris'] = this.selectedImageUris;
        batchParams['scenarioId'] = this.scenarioId;
        batchParams['scenarioTitle'] = this.scenarioTitle;
        batchParams['isBatch'] = true;
        batchParams['templateId'] = this.selectedTemplate?.id || '';
        batchParams['templateTitle'] = this.selectedTemplate?.title || '';
        RouterService.getInstance().navigateTo('pages/Workbench', batchParams).catch((err: Error) => {
          console.error(`跳转到工作台失败: ${err.message}`);
        });
      } else {
        console.info(`开始处理图片，场景：${this.scenarioTitle}, URI: ${this.selectedImageUri}`);
        
        try {
          // 1. 读取文件内容
          this.processingProgress = 10;
          console.info('[ScenarioDetail] 开始读取文件...');
          
          let fileBuffer: ArrayBuffer | null = null;
          let fileName: string = 'unknown_image.jpg';
          
          // 对于媒体库文件，使用 photoAccessHelper 读取
          if (this.selectedImageUri.startsWith('file://media/Photo/')) {
            console.info(`[ScenarioDetail] 检测到媒体库文件，尝试使用 photoAccessHelper 读取`);
            
            try {
              const userService: UserService = UserService.getInstance();
              const context: Context | null = userService.getContext();
              
              if (!context) {
                throw new Error('无法获取应用上下文');
              }
              
              // 请求权限
              const atManager = abilityAccessCtrl.createAtManager();
              await atManager.requestPermissionsFromUser(context, ['ohos.permission.READ_IMAGEVIDEO']);
              
              // 使用 photoAccessHelper 获取所有图片资源
              const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
              const fetchOptions: photoAccessHelper.FetchOptions = {
                fetchColumns: [],
                predicates: new dataSharePredicates.DataSharePredicates()
              };
              
              // 获取所有图片资源
              const fetchResult = await phAccessHelper.getAssets(fetchOptions);
              if (!fetchResult || fetchResult.getCount() === 0) {
                throw new Error('无法从媒体库获取图片资源');
              }
              
              // 遍历查找匹配的 URI
              let foundAsset: photoAccessHelper.PhotoAsset | null = null;
              let currentAsset: photoAccessHelper.PhotoAsset | null = await fetchResult.getFirstObject();
              let index = 0;
              
              while (currentAsset && index < fetchResult.getCount()) {
                const assetUri: string = currentAsset.uri;
                console.info(`[ScenarioDetail] 检查资源 URI: ${assetUri}`);
                
                // 检查 URI 是否匹配（支持多种格式）
                if (assetUri === this.selectedImageUri || 
                    assetUri.includes(this.selectedImageUri.split('/').pop() || '')) {
                  foundAsset = currentAsset;
                  console.info(`[ScenarioDetail] 找到匹配的资源: ${assetUri}`);
                  break;
                }
                
                // 获取下一个资源
                currentAsset = await fetchResult.getNextObject();
                index++;
              }
              
              if (!foundAsset) {
                throw new Error('无法在媒体库中找到匹配的图片资源');
              }
              
              fileName = foundAsset.displayName || 'image.jpg';
              
              // 尝试使用 PhotoAsset 的方法读取文件内容
              const assetUri: string = foundAsset.uri;
              console.info(`[ScenarioDetail] 使用 PhotoAsset 读取文件: ${assetUri}`);
              
              // 方法1: 尝试将文件复制到应用沙箱目录
              try {
                console.info(`[ScenarioDetail] 尝试将文件复制到应用沙箱目录`);
                const userService: UserService = UserService.getInstance();
                const context: Context | null = userService.getContext();
                
                if (!context) {
                  throw new Error('无法获取应用上下文');
                }
                
                // 获取应用缓存目录
                const cacheDir: string = context.cacheDir;
                const tempFilePath: string = `${cacheDir}/${fileName}`;
                
                console.info(`[ScenarioDetail] 目标路径: ${tempFilePath}`);
                
                // 使用 fs 模块复制文件
                // 先尝试读取源文件
                const srcFile = fs.openSync(assetUri, fs.OpenMode.READ_ONLY);
                const srcStat = fs.statSync(assetUri);
                const fileSize: number = srcStat.size;
                
                // 读取源文件内容
                const buffer = new ArrayBuffer(fileSize);
                fs.readSync(srcFile.fd, buffer);
                fs.closeSync(srcFile);
                
                // 写入临时文件
                const destFile = fs.openSync(tempFilePath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
                fs.writeSync(destFile.fd, buffer);
                fs.closeSync(destFile);
                
                // 从临时文件读取（验证）
                const tempFile = fs.openSync(tempFilePath, fs.OpenMode.READ_ONLY);
                fileBuffer = new ArrayBuffer(fileSize);
                fs.readSync(tempFile.fd, fileBuffer);
                fs.closeSync(tempFile);
                
                console.info(`[ScenarioDetail] 通过文件复制成功读取文件: ${fileName}, 大小: ${fileSize}`);
              } catch (copyError) {
                console.warn(`[ScenarioDetail] 文件复制失败: ${copyError}`);
                
                // 方法2: 尝试使用 fileIo 模块直接读取 URI
                try {
                  console.info(`[ScenarioDetail] 尝试使用 fileIo 模块读取 URI: ${assetUri}`);
                  const file: number = await fileIo.open(assetUri, 0);
                  const stat: fileIo.Stat = await fileIo.stat(assetUri);
                  const fileSize: number = stat.size;
                  fileBuffer = new ArrayBuffer(fileSize);
                  await fileIo.read(file, fileBuffer);
                  await fileIo.close(file);
                  console.info(`[ScenarioDetail] 通过 fileIo 成功读取文件: ${fileName}, 大小: ${fileSize}`);
                } catch (fileIoError) {
                  console.warn(`[ScenarioDetail] fileIo 读取失败: ${fileIoError}`);
                  
                  // 方法3: 尝试使用 fs 模块直接读取 URI
                  try {
                    console.info(`[ScenarioDetail] 尝试使用 fs 模块直接读取 URI: ${assetUri}`);
                    const file = fs.openSync(assetUri, fs.OpenMode.READ_ONLY);
                    const stat = fs.statSync(assetUri);
                    const fileSize: number = stat.size;
                    fileBuffer = new ArrayBuffer(fileSize);
                    fs.readSync(file.fd, fileBuffer);
                    fs.closeSync(file);
                    console.info(`[ScenarioDetail] 通过 fs 直接读取 URI 成功: ${fileName}, 大小: ${fileSize}`);
                  } catch (fsError) {
                    console.warn(`[ScenarioDetail] fs 直接读取 URI 失败: ${fsError}`);
                    throw new Error('无法读取媒体库文件。请使用文件管理器选择图片，或使用相机拍摄新图片');
                  }
                }
              }
            } catch (photoError) {
              console.error(`[ScenarioDetail] photoAccessHelper 读取失败: ${photoError}`);
              // 如果错误消息已经包含了我们的提示，直接抛出；否则添加提示
              const errorStr: string = photoError instanceof Error ? photoError.message : String(photoError);
              if (errorStr.includes('文件"选项') || errorStr.includes('文件管理器')) {
                throw photoError instanceof Error ? photoError : new Error(errorStr);
              } else {
                const errorMsg: string = '无法读取媒体库文件。请重新选择图片，在图片选择器中选择"文件"选项（而不是"相册"选项），或使用文件管理器选择图片';
                throw new Error(errorMsg);
              }
            }
          }
          
          // 如果不是媒体库文件，尝试直接路径读取
          if (!fileBuffer) {
            const pathVariants: string[] = [
              this.selectedImageUri.replace('file://', ''),
              this.selectedImageUri.replace('file:///', '/'),
              this.selectedImageUri.replace('file://', '/'),
            ];
            
            let readSuccess = false;
            for (let j = 0; j < pathVariants.length; j++) {
              const tryPath = pathVariants[j];
              try {
                console.info(`[ScenarioDetail] 尝试路径: ${tryPath}`);
                const file = fs.openSync(tryPath, fs.OpenMode.READ_ONLY);
                const stat = fs.statSync(tryPath);
                const fileSize = stat.size;
                fileBuffer = new ArrayBuffer(fileSize);
                fs.readSync(file.fd, fileBuffer);
                fs.closeSync(file);
                fileName = tryPath.split('/').pop() || 'image.jpg';
                console.info(`[ScenarioDetail] 成功读取文件: ${fileName}, 大小: ${fileSize}`);
                readSuccess = true;
                break;
              } catch (tryError) {
                console.info(`[ScenarioDetail] 路径 ${tryPath} 失败: ${tryError}`);
              }
            }
            
            if (!readSuccess || !fileBuffer) {
              // 所有路径都失败，提示用户
              throw new Error(`无法读取文件: ${this.selectedImageUri}，请检查文件权限或使用其他方式选择图片`);
            }
          }
          
          // 2. 上传图片到服务器
          this.processingProgress = 20;
          console.info('[ScenarioDetail] 开始上传图片...');
          const sceneType = this.scenarioId as SceneType || 'custom';
          
          // 使用文件内容上传
          const fileDataArray: FileData[] = [
            { buffer: fileBuffer, fileName: fileName }
          ];
          const uploadResponse = await this.imageService.uploadImageFiles(fileDataArray, sceneType);
          
          if (uploadResponse.images.length === 0) {
            throw new Error('图片上传失败');
          }
          
          const uploadedImage = uploadResponse.images[0];
          console.info(`[ScenarioDetail] 图片上传成功，ID: ${uploadedImage.id}`);
          this.processingProgress = 30;
          
          // 继续后续处理流程
          // 3. 调用图片处理API
          this.processingProgress = 40;
          console.info('[ScenarioDetail] 开始处理图片...');
          
          const operations: ImageOperation[] = [];
          if (this.selectedTemplate) {
            const template = this.selectedTemplate;
            const backgroundParams: ImageOperationParams = {
              backgroundTemplateId: template.id,
              backgroundColor: '#FFFFFF'
            };
            const backgroundOp: ImageOperation = {
              type: 'background',
              params: backgroundParams
            };
            operations.push(backgroundOp);
          }
          
          const cutoutParams: ImageOperationParams = {};
          const cutoutOp: ImageOperation = {
            type: 'cutout',
            params: cutoutParams
          };
          operations.push(cutoutOp);
          
          const processRequest: ProcessImageRequest = {
            imageId: uploadedImage.id,
            operations: operations,
            outputSize: this.outputSize,
            quality: this.quality,
            edgeSmoothing: this.edgeSmoothing,
            sceneType: sceneType
          };
          
          this.processingProgress = 50;
          const processResponse = await this.imageService.processImage(processRequest);
          console.info(`[ScenarioDetail] 处理任务已创建，任务ID: ${processResponse.taskId}`);
          this.processingProgress = 60;
          
          // 4. 等待处理完成（轮询状态）
          this.processingProgress = 70;
          const result = await this.imageService.waitForProcessResult(
            processResponse.taskId,
            (progress: number) => {
              this.processingProgress = 70 + Math.floor(progress * 0.2);
            },
            30000
          );
          
          this.processingProgress = 100;
          console.info('[ScenarioDetail] 图片处理完成');
          ToastUtil.showSuccess('图片处理完成');
          
          // 5. 跳转到工作台页面
          const singleParams: Record<string, string | number | boolean | string[] | undefined> = {};
          singleParams['imagePath'] = this.selectedImagePath;
          singleParams['imageUri'] = this.selectedImageUri;
          singleParams['scenarioId'] = this.scenarioId;
          singleParams['scenarioTitle'] = this.scenarioTitle;
          singleParams['isBatch'] = false;
          singleParams['templateId'] = this.selectedTemplate?.id || '';
          singleParams['templateTitle'] = this.selectedTemplate?.title || '';
          singleParams['taskId'] = processResponse.taskId;
          singleParams['processedImageId'] = result.resultImage.id;
          singleParams['processedImageUrl'] = result.resultImage.url;
          
          RouterService.getInstance().navigateTo('pages/Workbench', singleParams).catch((err: Error) => {
            console.error(`跳转到工作台失败: ${err.message}`);
            ToastUtil.showError(`跳转失败: ${err.message}`);
          });
        } catch (error) {
          console.error(`[ScenarioDetail] 处理图片失败: ${error}`);
          const errorMsg = error instanceof Error ? error.message : String(error);
          ToastUtil.showError(`处理失败: ${errorMsg}`);
          // 不再重新抛出错误，避免被外部的 catch 块再次处理
        } finally {
          this.isProcessing = false;
          this.processingProgress = 0;
        }
      }
    } catch (error) {
      // 这个 catch 块应该不会被执行，因为内部的 catch 已经处理了所有错误
      // 但为了安全起见，保留这个 catch 块，但不显示 Toast（避免重复）
      console.error(`[ScenarioDetail] 外层 catch 捕获到错误: ${error}`);
      this.isProcessing = false;
      this.processingProgress = 0;
    } finally {
      this.isProcessing = false;
      this.processingProgress = 0;
    }
  }
}

