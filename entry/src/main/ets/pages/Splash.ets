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
        angle: 135,
        colors: [
          ['#667eea', 0.0], // 主蓝色
          ['#764ba2', 1.0]  // 紫色
        ]
      })

      // 主要内容区域
      Column() {
        // Logo图标（使用Canvas绘制太阳/女神图标）
        Stack() {
          Canvas(this.context)
            .width(80)
            .height(80)
            .onReady(() => {
              this.drawLuminaLogo();
            })
        }
        .width(80)
        .height(80)
        .margin({ bottom: 24 })
        .transition(TransitionEffect.OPACITY.animation({ duration: 800, curve: Curve.EaseOut }))

        // 应用名称
        Text('Lumina')
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .letterSpacing(-0.02)
          .margin({ bottom: 16 })
          .transition(TransitionEffect.OPACITY.animation({ duration: 800, curve: Curve.EaseOut }))

        // 第一行标语
        Text('Light Up Your Products')
          .fontSize(18)
          .fontColor('#FFFFFF')
          .opacity(0.9)
          .margin({ bottom: 8 })
          .transition(TransitionEffect.OPACITY.animation({ duration: 800, curve: Curve.EaseOut }))

        // 第二行标语
        Text('Let AI Help You')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .opacity(0.85)
          .margin({ bottom: 80 })
          .transition(TransitionEffect.OPACITY.animation({ duration: 800, curve: Curve.EaseOut }))

        // 加载指示器（旋转圆圈）
        Stack() {
          Circle({ width: 32, height: 32 })
            .stroke('#FFFFFF')
            .strokeWidth(3)
            .fill(Color.Transparent)
            .opacity(0.9)
        }
        .width(32)
        .height(32)
        .margin({ bottom: 80 })
        .transition(TransitionEffect.OPACITY.animation({ duration: 800, curve: Curve.EaseOut }))
        .animation({
          iterations: -1,
          duration: 2000,
          curve: Curve.Linear
        })

        // 版本号
        Text('Version 1.0.0')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .opacity(0.6)
          .letterSpacing(0.02)
          .transition(TransitionEffect.OPACITY.animation({ duration: 800, curve: Curve.EaseOut }))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  // 绘制Lumina Logo（太阳/女神图标）
  private drawLuminaLogo() {
    const centerX = 40;
    const centerY = 40;
    
    // 清除画布
    this.context.clearRect(0, 0, 80, 80);
    
    // 绘制外层长射线（4条）
    this.context.strokeStyle = '#FFFFFF';
    this.context.lineWidth = 2.5;
    this.context.lineCap = 'round';
    
    // 上下左右4条长射线
    this.drawRay(centerX, centerY, 0, 4, 16); // 上
    this.drawRay(centerX, centerY, Math.PI, 4, 16); // 下
    this.drawRay(centerX, centerY, Math.PI / 2, 4, 16); // 右
    this.drawRay(centerX, centerY, -Math.PI / 2, 4, 16); // 左
    
    // 绘制对角线长射线（4条）
    this.drawRay(centerX, centerY, Math.PI / 4, 9.5, 8.5); // 右上
    this.drawRay(centerX, centerY, -Math.PI / 4, 9.5, 8.5); // 右下
    this.drawRay(centerX, centerY, 3 * Math.PI / 4, 9.5, 8.5); // 左上
    this.drawRay(centerX, centerY, -3 * Math.PI / 4, 9.5, 8.5); // 左下
    
    // 绘制内层短射线（4条）
    this.context.lineWidth = 2;
    this.context.globalAlpha = 0.8;
    this.drawRay(centerX, centerY, 0, 20, 6); // 上
    this.drawRay(centerX, centerY, Math.PI, 20, 6); // 下
    this.drawRay(centerX, centerY, Math.PI / 2, 20, 6); // 右
    this.drawRay(centerX, centerY, -Math.PI / 2, 20, 6); // 左
    
    this.context.globalAlpha = 1.0;
    
    // 绘制中心圆圈（三层）
    // 外层圆圈
    this.context.beginPath();
    this.context.arc(centerX, centerY, 14, 0, 2 * Math.PI);
    this.context.fillStyle = '#FFFFFF';
    this.context.fill();
    
    // 中层圆圈（半透明）
    this.context.beginPath();
    this.context.arc(centerX, centerY, 10, 0, 2 * Math.PI);
    this.context.fillStyle = 'rgba(255, 255, 255, 0.4)';
    this.context.fill();
    
    // 内层圆圈
    this.context.beginPath();
    this.context.arc(centerX, centerY, 6, 0, 2 * Math.PI);
    this.context.fillStyle = '#FFFFFF';
    this.context.fill();
  }
  
  // 绘制射线辅助方法
  private drawRay(centerX: number, centerY: number, angle: number, startRadius: number, length: number) {
    const startX = centerX + startRadius * Math.cos(angle);
    const startY = centerY + startRadius * Math.sin(angle);
    const endX = centerX + (startRadius + length) * Math.cos(angle);
    const endY = centerY + (startRadius + length) * Math.sin(angle);
    
    this.context.beginPath();
    this.context.moveTo(startX, startY);
    this.context.lineTo(endX, endY);
    this.context.stroke();
  }
}

