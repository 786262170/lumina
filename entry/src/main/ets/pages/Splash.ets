import router from '@ohos.router';

@Entry
@Component
struct Splash {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear() {
    // 延迟2秒后跳转到欢迎页
    setTimeout(() => {
      router.replaceUrl({
        url: 'pages/Welcome',
        params: {}
      }).catch((err: Error) => {
        console.error(`跳转失败: ${err.message}`);
      });
    }, 2000);
  }

  build() {
    Stack() {
      // 渐变紫色背景
      Column() {
        // 使用LinearGradient实现渐变效果
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 180,
        colors: [
          ['#A78BFA', 0], // 浅紫色
          ['#7C3AED', 1]  // 深紫色
        ]
      })

      // 主要内容区域
      Column() {
        // 太阳图标
        Stack() {
          // 使用Canvas绘制太阳图标（中心圆圈 + 8条虚线辐射线）
          Canvas(this.context)
            .width(120)
            .height(120)
            .onReady(() => {
              this.drawSunIcon();
            })
        }
        .width(120)
        .height(120)
        .margin({ bottom: 32 })

        // 应用名称
        Text('Lumina')
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ bottom: 24 })

        // 第一行标语
        Text('Light Up Your Products')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .opacity(0.9)
          .margin({ bottom: 8 })

        // 第二行标语
        Text('Let AI Help You')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .opacity(0.95)
          .margin({ bottom: 60 })

        // 加载指示器
        LoadingProgress()
          .color('#FFFFFF')
          .width(40)
          .height(40)
          .margin({ bottom: 80 })

        // 版本号
        Text('Version 1.0.0')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .opacity(0.7)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  // 绘制太阳图标
  private drawSunIcon() {
    const centerX = 60;
    const centerY = 60;
    const circleRadius = 20;
    const rayLength = 30;
    const rayCount = 8;

    // 绘制中心圆圈
    this.context.beginPath();
    this.context.arc(centerX, centerY, circleRadius, 0, 2 * Math.PI);
    this.context.fillStyle = '#FFFFFF';
    this.context.fill();

    // 绘制8条虚线辐射线
    this.context.strokeStyle = '#FFFFFF';
    this.context.lineWidth = 2;
    this.context.setLineDash([4, 4]); // 虚线样式

    for (let i = 0; i < rayCount; i++) {
      const angle = (i * 2 * Math.PI) / rayCount;
      const startX = centerX + (circleRadius + 5) * Math.cos(angle);
      const startY = centerY + (circleRadius + 5) * Math.sin(angle);
      const endX = centerX + (circleRadius + rayLength) * Math.cos(angle);
      const endY = centerY + (circleRadius + rayLength) * Math.sin(angle);

      this.context.beginPath();
      this.context.moveTo(startX, startY);
      this.context.lineTo(endX, endY);
      this.context.stroke();
    }
  }
}

