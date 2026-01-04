import router from '@ohos.router';
import { RouterService, RouteParams } from '../common/services/RouterService';
import { AIService } from '../common/services/AIService';
import { ProductOption, Question } from '../common/types/CommonTypes';
import { IconComponent, IconType } from '../common/components/IconComponent';
import { ToastUtil } from '../common/utils/ToastUtil';

@Entry
@Component
struct AIQuestionnaire {
  // 当前问题索引（0-2，共3个问题）
  @State currentQuestion: number = 0;
  // 当前选中的选项ID
  @State selectedOptionId: string = '';
  // 提交问卷时的加载状态
  @State isSubmitting: boolean = false;
  
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

  // 将选项图标字符串映射到IconType
  private getIconType(iconString: string, optionId?: string): IconType {
    // 如果是平台选项，根据optionId返回不同的平台图标
    if (iconString === 'platform' && optionId) {
      switch (optionId) {
        case 'taobao':
          return IconType.TAOBAO;
        case 'tmall':
          return IconType.TMALL;
        case 'jd':
          return IconType.JD;
        case 'douyin':
          return IconType.DOUYIN;
        case 'xiaohongshu':
          return IconType.XIAOHONGSHU;
        case 'amazon':
          return IconType.AMAZON;
        default:
          return IconType.PLATFORM;
      }
    }
    
    // 其他选项图标
    switch (iconString) {
      case 'bag':
        return IconType.BAG;
      case 'phone':
        return IconType.PHONE;
      case 'cosmetic':
        return IconType.COSMETIC;
      case 'food':
        return IconType.FOOD;
      case 'home':
        return IconType.HOME;
      case 'sports':
        return IconType.SPORTS;
      case 'book':
        return IconType.BOOK;
      case 'other':
        return IconType.OTHER;
      case 'platform':
        return IconType.PLATFORM;
      case 'simple':
        return IconType.SIMPLE;
      case 'professional':
        return IconType.PROFESSIONAL;
      case 'creative':
        return IconType.CREATIVE;
      default:
        return IconType.OTHER;
    }
  }
  
  // 答案记录
  @State answers: Record<string, string> = {};
  
  private aiService: AIService = AIService.getInstance();

  // 返回首页
  async handleBack() {
    console.info('[AIQuestionnaire] handleBack 被调用');
    try {
      await RouterService.getInstance().navigateTo('pages/Index', undefined, true);
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : String(err);
      console.error(`[AIQuestionnaire] 跳转首页失败: ${errorMsg}`);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 返回按钮
        Button() {
          Image($r('app.media.last'))
            .width(20)
            .height(20)
            .fillColor('#1A1F36')
        }
        .type(ButtonType.Normal)
        .width(40)
        .height(40)
        .backgroundColor('#F8F9FC')
        .borderRadius(8)
          .onClick(async () => {
            await this.handleBack();
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

            // 使用问卷页面主图标
            IconComponent({ iconType: IconType.QUESTIONNAIRE, iconSize: 60, iconColor: '#FFFFFF' })
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

                  // 图标内容（使用PNG图标）
                  IconComponent({
                    iconType: this.getIconType(option.icon, option.id),
                    iconSize: 24,
                    iconColor: this.selectedOptionId === option.id ? '#FFFFFF' : '#6B7280'
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
          if (this.isSubmitting) {
            Row() {
              LoadingProgress()
                .width(20)
                .height(20)
                .color('#FFFFFF')
                .margin({ right: 8 })
              Text('提交中...')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .justifyContent(FlexAlign.Center)
          } else {
            Text(this.currentQuestion < 2 ? '下一步' : '完成')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
          }
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
        .enabled(this.selectedOptionId !== '' && !this.isSubmitting)
        .opacity(this.selectedOptionId !== '' && !this.isSubmitting ? 1 : 0.5)
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


  // 下一题（带动画过渡）
  private async nextQuestion() {
    // 保存当前答案
    if (this.selectedOptionId) {
      const questionNumber = (this.currentQuestion + 1).toString();
      this.answers[questionNumber] = this.selectedOptionId;
    }
    
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
      // 完成问卷，提交答案并跳转到AI推荐页
      this.isSubmitting = true;
      try {
        console.info(`[AIQuestionnaire] 开始提交问卷，答案:`, this.answers);
        const response = await this.aiService.submitQuiz(this.answers);
        console.info(`[AIQuestionnaire] 问卷提交成功，会话ID: ${response.sessionId}`);
        
        // 将会话ID传递给推荐页面
        const params: RouteParams = {} as RouteParams;
        params['quizSessionId'] = response.sessionId;
        await RouterService.getInstance().navigateTo('pages/AIRecommendation', params, true);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        console.error(`[AIQuestionnaire] 提交问卷失败: ${errorMsg}`);
        ToastUtil.showError(`提交问卷失败: ${errorMsg}`);
        // 即使提交失败，也跳转到推荐页面（可以显示默认推荐）
        try {
          await RouterService.getInstance().navigateTo('pages/AIRecommendation', undefined, true);
        } catch (navError) {
          console.error(`[AIQuestionnaire] 跳转失败: ${navError instanceof Error ? navError.message : String(navError)}`);
        }
      } finally {
        this.isSubmitting = false;
      }
    }
  }

  // 跳过到主页
  private skipToIndex() {
    RouterService.getInstance().navigateTo('pages/Index', undefined, true)
      .catch((err: Error) => {
      console.error(`跳转失败: ${err.message}`);
    });
  }
}

