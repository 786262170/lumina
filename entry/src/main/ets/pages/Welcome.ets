import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';

@Entry
@Component
struct Welcome {
  // Canvas上下文设置
  private starSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private starContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.starSettings);
  
  private icon1Settings: RenderingContextSettings = new RenderingContextSettings(true);
  private icon1Context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.icon1Settings);
  
  private icon2Settings: RenderingContextSettings = new RenderingContextSettings(true);
  private icon2Context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.icon2Settings);
  
  private icon3Settings: RenderingContextSettings = new RenderingContextSettings(true);
  private icon3Context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.icon3Settings);
  
  private arrowSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private arrowContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.arrowSettings);

  // 绘制星形图标
  private drawStar(context: CanvasRenderingContext2D, centerX: number, centerY: number, radius: number) {
    const spikes = 4; // 四角星
    const outerRadius = radius;
    const innerRadius = radius * 0.4;
    
    context.beginPath();
    context.moveTo(centerX, centerY - outerRadius);
    
    for (let i = 0; i < spikes * 2; i++) {
      const angle = (i * Math.PI) / spikes;
      const r = i % 2 === 0 ? outerRadius : innerRadius;
      const x = centerX + r * Math.sin(angle);
      const y = centerY - r * Math.cos(angle);
      
      if (i === 0) {
        context.moveTo(x, y);
      } else {
        context.lineTo(x, y);
      }
    }
    
    context.closePath();
    context.fillStyle = '#FFFFFF';
    context.fill();
  }

  // 绘制闪电图标
  private drawLightning(context: CanvasRenderingContext2D, centerX: number, centerY: number) {
    context.beginPath();
    context.moveTo(centerX, centerY - 10);
    context.lineTo(centerX - 4, centerY);
    context.lineTo(centerX, centerY);
    context.lineTo(centerX - 2, centerY + 6);
    context.lineTo(centerX + 4, centerY + 6);
    context.lineTo(centerX, centerY + 10);
    context.lineTo(centerX + 4, centerY + 4);
    context.lineTo(centerX, centerY + 4);
    context.closePath();
    context.fillStyle = '#FFFFFF';
    context.fill();
  }

  // 绘制图表图标（上升趋势线）
  private drawChart(context: CanvasRenderingContext2D, centerX: number, centerY: number) {
    context.strokeStyle = '#FFFFFF';
    context.lineWidth = 2;
    context.lineCap = 'round';
    context.lineJoin = 'round';
    
    // 绘制上升趋势线
    context.beginPath();
    context.moveTo(centerX - 8, centerY + 6);
    context.lineTo(centerX - 4, centerY + 2);
    context.lineTo(centerX, centerY - 2);
    context.lineTo(centerX + 4, centerY - 6);
    context.lineTo(centerX + 8, centerY - 10);
    context.stroke();
    
    // 绘制箭头
    context.beginPath();
    context.moveTo(centerX + 8, centerY - 10);
    context.lineTo(centerX + 6, centerY - 8);
    context.lineTo(centerX + 8, centerY - 6);
    context.closePath();
    context.fillStyle = '#FFFFFF';
    context.fill();
  }

  // 绘制右箭头图标
  private drawArrow(context: CanvasRenderingContext2D, centerX: number, centerY: number) {
    context.strokeStyle = '#FFFFFF';
    context.lineWidth = 2;
    context.lineCap = 'round';
    context.lineJoin = 'round';
    
    // 绘制箭头线
    context.beginPath();
    context.moveTo(centerX - 6, centerY);
    context.lineTo(centerX + 6, centerY);
    context.stroke();
    
    // 绘制箭头头部
    context.beginPath();
    context.moveTo(centerX + 6, centerY);
    context.lineTo(centerX + 2, centerY - 4);
    context.moveTo(centerX + 6, centerY);
    context.lineTo(centerX + 2, centerY + 4);
    context.stroke();
  }

  build() {
    Column() {
      // 上半部分：紫色渐变背景
      Stack() {
        Column() {
          // 装饰性元素（模糊圆圈）
          Stack() {
            Circle({ width: 120, height: 120 })
              .fill('#FFFFFF')
              .opacity(0.1)
          }
          .width(120)
          .height(120)
          .position({ x: '80%', y: '10%' })

          Stack() {
            Circle({ width: 80, height: 80 })
              .fill('#FFFFFF')
              .opacity(0.15)
          }
          .width(80)
          .height(80)
          .position({ x: '10%', y: '60%' })

          // 星形图标容器（带阴影效果）
          Stack() {
            // 背景容器（半透明圆角方形）
            Column()
              .width(80)
              .height(80)
              .borderRadius(16)
              .backgroundColor('#FFFFFF')
              .opacity(0.25)
              .shadow({
                radius: 20,
                color: '#000000',
                offsetX: 0,
                offsetY: 4
              })

            // 星形图标（使用Canvas绘制）
            Canvas(this.starContext)
              .width(40)
              .height(40)
              .onReady(() => {
                this.drawStar(this.starContext, 20, 20, 15);
              })
          }
          .width(80)
          .height(80)
          .margin({ top: 80, bottom: 32 })

        // 标题
        Text('Welcome to Lumina')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ bottom: 24 })

        // 第一行标语
        Text('让AI帮你打造完美商品图')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .opacity(0.95)
          .margin({ bottom: 8 })

        // 第二行标语
        Text('提升销售转化率')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .opacity(0.95)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .linearGradient({
        angle: 135,
        colors: [
          ['#667eea', 0.0], // 主蓝色
          ['#764ba2', 1.0]  // 紫色
        ]
      })
      }

      // 下半部分：白色背景
      Column() {
        // 标题
        Text('为什么选择 Lumina?')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ top: 40, bottom: 32 })
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 24, right: 24 })

        // 功能卡片列表
        Column() {
          // 功能卡片1：AI智能识别
          Row() {
            // 图标容器（渐变背景）
            Stack() {
              Column()
                .width(56)
                .height(56)
                .borderRadius(12)
                .linearGradient({
                  angle: 135,
                  colors: [
                    ['#667eea', 0.0],
                    ['#764ba2', 1.0]
                  ]
                })

              // 星形图标
              Canvas(this.icon1Context)
                .width(28)
                .height(28)
                .onReady(() => {
                  this.drawStar(this.icon1Context, 14, 14, 10);
                })
            }
            .width(56)
            .height(56)
            .margin({ right: 16 })

            // 文字内容
            Column() {
              Text('AI智能识别')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
                .margin({ bottom: 4 })
                .alignSelf(ItemAlign.Start)

              Text('自动识别主体,精准抠图')
                .fontSize(14)
                .fontColor('#6B7280')
                .alignSelf(ItemAlign.Start)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(20)
          .borderRadius(16)
          .border({ width: 1, color: '#E5E7EB' })
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 16 })

          // 功能卡片2：一键批量处理
          Row() {
            // 图标容器（渐变背景）
            Stack() {
              Column()
                .width(56)
                .height(56)
                .borderRadius(12)
                .linearGradient({
                  angle: 135,
                  colors: [
                    ['#667eea', 0.0],
                    ['#764ba2', 1.0]
                  ]
                })

              // 闪电图标
              Canvas(this.icon2Context)
                .width(28)
                .height(28)
                .onReady(() => {
                  this.drawLightning(this.icon2Context, 14, 14);
                })
            }
            .width(56)
            .height(56)
            .margin({ right: 16 })

            // 文字内容
            Column() {
              Text('一键批量处理')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
                .margin({ bottom: 4 })
                .alignSelf(ItemAlign.Start)

              Text('支持最多100张图片同时处理')
                .fontSize(14)
                .fontColor('#6B7280')
                .alignSelf(ItemAlign.Start)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(20)
          .borderRadius(16)
          .border({ width: 1, color: '#E5E7EB' })
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 16 })

          // 功能卡片3：专业级效果
          Row() {
            // 图标容器（渐变背景）
            Stack() {
              Column()
                .width(56)
                .height(56)
                .borderRadius(12)
                .linearGradient({
                  angle: 135,
                  colors: [
                    ['#667eea', 0.0],
                    ['#764ba2', 1.0]
                  ]
                })

              // 图表图标（上升趋势线）
              Canvas(this.icon3Context)
                .width(28)
                .height(28)
                .onReady(() => {
                  this.drawChart(this.icon3Context, 14, 14);
                })
            }
            .width(56)
            .height(56)
            .margin({ right: 16 })

            // 文字内容
            Column() {
              Text('专业级效果')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
                .margin({ bottom: 4 })
                .alignSelf(ItemAlign.Start)

              Text('电商级品质,提升转化率')
                .fontSize(14)
                .fontColor('#6B7280')
                .alignSelf(ItemAlign.Start)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(20)
          .borderRadius(16)
          .border({ width: 1, color: '#E5E7EB' })
          .backgroundColor('#FFFFFF')
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .layoutWeight(1)

        // 底部按钮
        Button() {
          Row() {
            Text('开始体验')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .margin({ right: 8 })

            // 右箭头图标
            Canvas(this.arrowContext)
              .width(20)
              .height(20)
              .onReady(() => {
                this.drawArrow(this.arrowContext, 10, 10);
              })
          }
          .justifyContent(FlexAlign.Center)
        }
        .type(ButtonType.Normal)
        .width('100%')
        .height(56)
        .borderRadius(16)
        .linearGradient({
          angle: 135,
          colors: [
            ['#667eea', 0.0], // 主蓝色
            ['#764ba2', 1.0]  // 紫色
          ]
        })
        .onClick(() => {
          // 跳转到AI问卷页
          RouterService.getInstance().navigateTo('pages/AIQuestionnaire', undefined, true)
            .catch((err: Error) => {
              console.error(`跳转失败: ${err.message}`);
            });
        })
        .margin({ top: 24, bottom: 40, left: 24, right: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
  }
}
