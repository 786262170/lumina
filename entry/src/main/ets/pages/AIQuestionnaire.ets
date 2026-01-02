import router from '@ohos.router';
import { ProductOption, Question } from '../common/types/CommonTypes';

@Entry
@Component
struct AIQuestionnaire {
  // 当前问题索引（0-2，共3个问题）
  @State currentQuestion: number = 0;
  // 当前选中的选项ID
  @State selectedOptionId: string = '';
  
  // 问题列表
  private questions: Question[] = [
    {
      title: '您主要销售什么类型的产品?',
      subtitle: '选择最符合您业务场景的选项',
      options: [
        { id: 'apparel', name: '服装配饰', icon: 'bag' },
        { id: 'electronics', name: '电子数码', icon: 'phone' },
        { id: 'cosmetics', name: '美妆护肤', icon: 'cosmetic' },
        { id: 'food', name: '食品饮料', icon: 'food' },
        { id: 'home', name: '家居用品', icon: 'home' },
        { id: 'sports', name: '运动户外', icon: 'sports' },
        { id: 'books', name: '图书文具', icon: 'book' },
        { id: 'other', name: '其他', icon: 'other' }
      ]
    },
    {
      title: '您主要在哪些平台销售?',
      subtitle: '可选择多个平台',
      options: [
        { id: 'taobao', name: '淘宝', icon: 'platform' },
        { id: 'tmall', name: '天猫', icon: 'platform' },
        { id: 'jd', name: '京东', icon: 'platform' },
        { id: 'douyin', name: '抖音', icon: 'platform' },
        { id: 'xiaohongshu', name: '小红书', icon: 'platform' },
        { id: 'amazon', name: '亚马逊', icon: 'platform' },
        { id: 'other', name: '其他平台', icon: 'platform' }
      ]
    },
    {
      title: '您偏好的设计风格是?',
      subtitle: '选择最能代表您品牌的风格',
      options: [
        { id: 'simple', name: '简约现代', icon: 'simple' },
        { id: 'professional', name: '专业商务', icon: 'professional' },
        { id: 'creative', name: '创意个性', icon: 'creative' }
      ]
    }
  ];

  // Canvas上下文设置
  private bagSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private bagContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.bagSettings);
  
  private iconSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private iconContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.iconSettings);

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

        Blank()

        // 问题进度
        Text(`问题 ${this.currentQuestion + 1}/3`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2937')

        Blank()

        // 跳过按钮
        Text('跳过')
          .fontSize(16)
          .fontColor('#6B7280')
          .onClick(() => {
            this.skipToIndex();
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
          // 中央图标（根据问题显示不同图标）
          Stack() {
            // 紫色渐变圆形背景
            Column()
              .width(120)
              .height(120)
              .borderRadius(60)
              .linearGradient({
                angle: 135,
                colors: [
                  ['#667eea', 0.0],
                  ['#764ba2', 1.0]
                ]
              })

            // 根据当前问题显示不同图标
            Canvas(this.bagContext)
              .width(60)
              .height(60)
              .key(`center-icon-${this.currentQuestion}`)
              .onReady(() => {
                // 清空画布
                this.bagContext.clearRect(0, 0, 60, 60);
                if (this.currentQuestion === 0) {
                  // 第一个问题：购物袋
                  this.drawBagIcon(this.bagContext, 30, 30);
                } else if (this.currentQuestion === 1) {
                  // 第二个问题：平台图标（可以用购物袋或平台图标）
                  this.drawBagIcon(this.bagContext, 30, 30);
                } else {
                  // 第三个问题：四角星+sparkles
                  this.drawStarWithSparkles(this.bagContext, 30, 30);
                }
              })
          }
          .width(120)
          .height(120)
          .margin({ top: 40, bottom: 32 })

          // 问题标题
          Text(this.questions[this.currentQuestion].title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 12 })
            .padding({ left: 24, right: 24 })

          // 问题说明
          Text(this.questions[this.currentQuestion].subtitle)
            .fontSize(14)
            .fontColor('#6B7280')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 32 })
            .padding({ left: 24, right: 24 })

          // 选项列表（带动画过渡）
          Column() {
            ForEach(this.questions[this.currentQuestion].options, (option: ProductOption) => {
              Row() {
                // 图标
                Stack() {
                  // 图标背景
                  Column()
                    .width(40)
                    .height(40)
                    .borderRadius(8)
                    .backgroundColor(this.selectedOptionId === option.id ? '#7C3AED' : '#F3F4F6')

                  // 图标内容
                  Canvas(this.iconContext)
                    .width(24)
                    .height(24)
                    .onReady(() => {
                      this.drawOptionIcon(this.iconContext, 12, 12, option.icon, this.selectedOptionId === option.id);
                    })
                }
                .width(40)
                .height(40)
                .margin({ right: 12 })

                // 选项文本
                Text(option.name)
                  .fontSize(16)
                  .fontColor('#1F2937')
                  .layoutWeight(1)

                // 选中指示器（对勾）
                if (this.selectedOptionId === option.id) {
                  Stack() {
                    Circle({ width: 20, height: 20 })
                      .fill('#667eea')
                    Text('✓')
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .fontWeight(FontWeight.Medium)
                  }
                  .width(20)
                  .height(20)
                }
              }
              .width('100%')
              .height(64)
              .padding({ left: 16, right: 16 })
              .borderRadius(12)
              .border({
                width: this.selectedOptionId === option.id ? 2 : 1,
                color: this.selectedOptionId === option.id ? '#667eea' : '#E5E7EB'
              })
              .backgroundColor(this.selectedOptionId === option.id ? '#F8F9FC' : '#FFFFFF')
              .shadow({
                radius: this.selectedOptionId === option.id ? 8 : 0,
                color: this.selectedOptionId === option.id ? '#667eea' : '#000000',
                offsetX: 0,
                offsetY: this.selectedOptionId === option.id ? 4 : 0
              })
              .margin({ bottom: 12 })
              .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
              .onClick(() => {
                this.selectedOptionId = option.id;
              })
            }, (option: ProductOption) => option.id)
          }
          .width('100%')
          .padding({ left: 24, right: 24 })
          .margin({ bottom: 40 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      // 底部按钮和进度指示器
      Column() {
        // 下一步按钮
        Button() {
          Text('下一步')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .type(ButtonType.Normal)
        .width('100%')
        .height(56)
        .borderRadius(16)
        .linearGradient({
          angle: 135,
          colors: [
            ['#667eea', 0.0],
            ['#764ba2', 1.0]
          ]
        })
        .enabled(this.selectedOptionId !== '')
        .opacity(this.selectedOptionId !== '' ? 1 : 0.5)
        .onClick(() => {
          this.nextQuestion();
        })
        .margin({ bottom: 16 })

        // 进度指示器
        Row() {
          ForEach([0, 1, 2], (index: number) => {
            Column()
              .width(8)
              .height(8)
              .borderRadius(4)
              .backgroundColor(index === this.currentQuestion ? '#667eea' : '#E5E7EB')
              .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
              .margin({ left: 4, right: 4 })
          }, (index: number) => index.toString())
        }
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 20 })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  // 绘制购物袋图标
  private drawBagIcon(context: CanvasRenderingContext2D, centerX: number, centerY: number) {
    context.strokeStyle = '#FFFFFF';
    context.lineWidth = 3;
    context.lineCap = 'round';
    context.lineJoin = 'round';
    
    // 绘制购物袋主体
    context.beginPath();
    // 顶部提手
    context.moveTo(centerX - 12, centerY - 8);
    context.quadraticCurveTo(centerX - 12, centerY - 12, centerX - 8, centerY - 12);
    context.lineTo(centerX + 8, centerY - 12);
    context.quadraticCurveTo(centerX + 12, centerY - 12, centerX + 12, centerY - 8);
    
    // 袋身
    context.lineTo(centerX + 12, centerY + 12);
    context.lineTo(centerX - 12, centerY + 12);
    context.closePath();
    context.stroke();
    
    // 底部横线
    context.beginPath();
    context.moveTo(centerX - 8, centerY + 12);
    context.lineTo(centerX + 8, centerY + 12);
    context.stroke();
  }

  // 绘制选项图标
  private drawOptionIcon(context: CanvasRenderingContext2D, centerX: number, centerY: number, iconType: string, isSelected: boolean) {
    context.strokeStyle = isSelected ? '#FFFFFF' : '#6B7280';
    context.fillStyle = isSelected ? '#FFFFFF' : '#6B7280';
    context.lineWidth = 2;
    context.lineCap = 'round';
    context.lineJoin = 'round';
    
    switch (iconType) {
      case 'bag':
        // 购物袋
        this.drawBagIcon(context, centerX, centerY);
        break;
      case 'phone':
        // 手机
        context.strokeRect(centerX - 6, centerY - 8, 12, 16);
        context.fillRect(centerX - 4, centerY - 6, 8, 2);
        break;
      case 'cosmetic':
        // 化妆品（圆形）
        context.beginPath();
        context.arc(centerX, centerY, 6, 0, Math.PI * 2);
        context.stroke();
        break;
      case 'food':
        // 食物（圆形带点）
        context.beginPath();
        context.arc(centerX, centerY, 6, 0, Math.PI * 2);
        context.fill();
        break;
      case 'home':
        // 家居（房子）
        context.beginPath();
        context.moveTo(centerX, centerY - 8);
        context.lineTo(centerX - 6, centerY);
        context.lineTo(centerX - 6, centerY + 6);
        context.lineTo(centerX + 6, centerY + 6);
        context.lineTo(centerX + 6, centerY);
        context.closePath();
        context.stroke();
        break;
      case 'sports':
        // 运动（圆形）
        context.beginPath();
        context.arc(centerX, centerY, 6, 0, Math.PI * 2);
        context.stroke();
        break;
      case 'book':
        // 书本
        context.strokeRect(centerX - 6, centerY - 4, 12, 8);
        context.beginPath();
        context.moveTo(centerX, centerY - 4);
        context.lineTo(centerX, centerY + 4);
        context.stroke();
        break;
      case 'magic':
        // 魔法棒（星形）
        this.drawStar(context, centerX, centerY, 6);
        break;
      case 'batch':
        // 批量（多个方块）
        context.fillRect(centerX - 6, centerY - 4, 4, 4);
        context.fillRect(centerX - 1, centerY - 4, 4, 4);
        context.fillRect(centerX - 6, centerY + 1, 4, 4);
        context.fillRect(centerX - 1, centerY + 1, 4, 4);
        break;
      case 'template':
        // 模板（网格）
        context.strokeRect(centerX - 6, centerY - 6, 12, 12);
        context.beginPath();
        context.moveTo(centerX, centerY - 6);
        context.lineTo(centerX, centerY + 6);
        context.moveTo(centerX - 6, centerY);
        context.lineTo(centerX + 6, centerY);
        context.stroke();
        break;
      case 'enhance':
        // 优化（向上箭头）
        context.beginPath();
        context.moveTo(centerX, centerY - 6);
        context.lineTo(centerX - 4, centerY);
        context.lineTo(centerX + 4, centerY);
        context.closePath();
        context.fill();
        break;
      case 'simple':
        // 简约现代（简洁线条）
        context.beginPath();
        context.moveTo(centerX - 6, centerY);
        context.lineTo(centerX - 2, centerY - 4);
        context.lineTo(centerX + 2, centerY - 4);
        context.lineTo(centerX + 6, centerY);
        context.lineTo(centerX + 2, centerY + 4);
        context.lineTo(centerX - 2, centerY + 4);
        context.closePath();
        context.stroke();
        break;
      case 'professional':
        // 专业商务（方形）
        context.strokeRect(centerX - 6, centerY - 6, 12, 12);
        context.beginPath();
        context.moveTo(centerX - 6, centerY);
        context.lineTo(centerX + 6, centerY);
        context.moveTo(centerX, centerY - 6);
        context.lineTo(centerX, centerY + 6);
        context.stroke();
        break;
      case 'creative':
        // 创意个性（星形+sparkles）
        this.drawStar(context, centerX, centerY, 6);
        // 添加小sparkles
        context.fillRect(centerX - 8, centerY - 2, 2, 2);
        context.fillRect(centerX + 6, centerY - 2, 2, 2);
        break;
      default:
        // 默认图标（圆形）
        context.beginPath();
        context.arc(centerX, centerY, 6, 0, Math.PI * 2);
        context.stroke();
    }
  }

  // 绘制星形
  private drawStar(context: CanvasRenderingContext2D, centerX: number, centerY: number, radius: number) {
    const spikes = 5;
    const outerRadius = radius;
    const innerRadius = radius * 0.4;
    
    context.beginPath();
    for (let i = 0; i < spikes * 2; i++) {
      const angle = (i * Math.PI) / spikes - Math.PI / 2;
      const r = i % 2 === 0 ? outerRadius : innerRadius;
      const x = centerX + r * Math.cos(angle);
      const y = centerY + r * Math.sin(angle);
      
      if (i === 0) {
        context.moveTo(x, y);
      } else {
        context.lineTo(x, y);
      }
    }
    context.closePath();
    context.fill();
  }

  // 绘制四角星+sparkles（用于第三个问题的中央图标）
  private drawStarWithSparkles(context: CanvasRenderingContext2D, centerX: number, centerY: number) {
    context.strokeStyle = '#FFFFFF';
    context.fillStyle = '#FFFFFF';
    context.lineWidth = 3;
    context.lineCap = 'round';
    context.lineJoin = 'round';
    
    // 绘制四角星（十字星形）
    const size = 20;
    context.beginPath();
    // 上
    context.moveTo(centerX, centerY - size);
    context.lineTo(centerX, centerY - size / 2);
    // 右
    context.moveTo(centerX + size, centerY);
    context.lineTo(centerX + size / 2, centerY);
    // 下
    context.moveTo(centerX, centerY + size);
    context.lineTo(centerX, centerY + size / 2);
    // 左
    context.moveTo(centerX - size, centerY);
    context.lineTo(centerX - size / 2, centerY);
    // 连接中心
    context.moveTo(centerX - size / 2, centerY);
    context.lineTo(centerX + size / 2, centerY);
    context.moveTo(centerX, centerY - size / 2);
    context.lineTo(centerX, centerY + size / 2);
    context.stroke();
    
    // 绘制两个小加号（sparkles）
    const sparkleSize = 4;
    // 左上sparkle
    context.beginPath();
    context.moveTo(centerX - 16, centerY - 16);
    context.lineTo(centerX - 16, centerY - 16 + sparkleSize);
    context.moveTo(centerX - 16 - sparkleSize / 2, centerY - 16 + sparkleSize / 2);
    context.lineTo(centerX - 16 + sparkleSize / 2, centerY - 16 + sparkleSize / 2);
    context.stroke();
    
    // 右下sparkle
    context.beginPath();
    context.moveTo(centerX + 16, centerY + 16);
    context.lineTo(centerX + 16, centerY + 16 - sparkleSize);
    context.moveTo(centerX + 16 - sparkleSize / 2, centerY + 16 - sparkleSize / 2);
    context.lineTo(centerX + 16 + sparkleSize / 2, centerY + 16 - sparkleSize / 2);
    context.stroke();
  }

  // 下一题（带动画过渡）
  private nextQuestion() {
    if (this.currentQuestion < 2) {
      // 添加淡出动画
      animateTo({
        duration: 200,
        curve: Curve.EaseInOut
      }, () => {
        this.currentQuestion++;
        this.selectedOptionId = '';
      });
      
      // 淡入动画
      animateTo({
        duration: 300,
        curve: Curve.EaseInOut
      }, () => {
        // 内容已更新
      });
    } else {
      // 完成问卷，跳转到AI推荐页
      router.replaceUrl({
        url: 'pages/AIRecommendation',
        params: {}
      }).catch((err: Error) => {
        console.error(`跳转失败: ${err.message}`);
      });
    }
  }

  // 跳过到主页
  private skipToIndex() {
    router.replaceUrl({
      url: 'pages/Index',
      params: {}
    }).catch((err: Error) => {
      console.error(`跳转失败: ${err.message}`);
    });
  }
}

