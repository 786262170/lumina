import router from '@ohos.router';

@Entry
@Component
struct BackgroundTemplateDetail {
  @State templateId: string = '';
  @State templateTitle: string = '';
  @State templateCategory: string = '';
  @State templateRating: number = 0;
  @State isSelected: boolean = false; // 是否已选择

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.templateId = params['templateId'] as string || '';
      this.templateTitle = params['templateTitle'] as string || '';
      this.templateCategory = params['templateCategory'] as string || '';
      this.templateRating = params['templateRating'] as number || 0;
    }
  }

  // 选择模板
  handleSelectTemplate() {
    this.isSelected = true;
    // 返回上一页
    router.back();
    console.info(`已选择模板: ${this.templateTitle}`);
  }

  // 预览模板
  handlePreview() {
    // 显示模板预览（全屏或弹窗）
    console.info('预览模板');
    // TODO: 实现全屏预览功能
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
        Text('Template Detail')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: -24 })

        // 占位（保持对称）
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .opacity(0)
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })

      // 内容区域
      Scroll() {
        Column() {
          // 模板预览大图
          Stack() {
            // 占位图片（后续可替换为实际图片）
            Column() {
              Image($r('app.media.startIcon'))
                .width(80)
                .height(80)
                .fillColor('#9CA3AF')
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#F3F4F6')
          }
          .width('100%')
          .height(400)
          .margin({ top: 20, bottom: 20 })
          .borderRadius(16)

          // 模板信息卡片
          Column() {
            // 标题和评分
            Row() {
              Column() {
                Text(this.templateTitle)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1F2937')
                  .margin({ bottom: 8 })

                Row() {
                  Image($r('app.media.startIcon'))
                    .width(16)
                    .height(16)
                    .fillColor('#FBBF24')
                    .margin({ right: 6 })

                  Text(this.templateRating.toString())
                    .fontSize(14)
                    .fontColor('#6B7280')
                    .margin({ right: 16 })

                  Text(this.templateCategory)
                    .fontSize(14)
                    .fontColor('#6366F1')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor('#EEF2FF')
                    .borderRadius(4)
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Center)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 20 })

            // 模板描述
            Text('This background template is perfect for product photography and professional presentations. It features a clean, minimalist design that works well with various subjects.')
              .fontSize(14)
              .fontColor('#6B7280')
              .lineHeight(20)
              .margin({ bottom: 24 })

            // 使用建议
            Column() {
              Row() {
                Image($r('app.media.startIcon'))
                  .width(20)
                  .height(20)
                  .fillColor('#6366F1')
                  .margin({ right: 12 })

                Text('Usage Tips')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1F2937')
              }
              .width('100%')
              .margin({ bottom: 12 })

              Text('• Best for product photography\n• Works well with light-colored subjects\n• Recommended for e-commerce listings\n• Suitable for professional presentations')
                .fontSize(13)
                .fontColor('#6B7280')
                .lineHeight(20)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(16)
            .backgroundColor('#F9FAFB')
            .borderRadius(12)
            .margin({ bottom: 24 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 20 })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)

      // 底部操作栏
      Row() {
        // 预览按钮
        Button('Preview')
          .type(ButtonType.Normal)
          .backgroundColor('#F3F4F6')
          .fontColor('#1F2937')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width(120)
          .height(48)
          .borderRadius(24)
          .onClick(() => {
            this.handlePreview();
          })

        // 选择按钮
        Button(this.isSelected ? '已选择' : 'Select Template')
          .type(ButtonType.Normal)
          .backgroundColor(this.isSelected ? '#10B981' : '#6366F1')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .height(48)
          .borderRadius(24)
          .margin({ left: 12 })
          .enabled(!this.isSelected)
          .onClick(() => {
            this.handleSelectTemplate();
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
}

