import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';
import { RecommendationItem } from '../common/types/CommonTypes';
import { TopNavBar } from '../common/components/TopNavBar';

// 推荐场景接口
interface RecommendedScenario {
  title: string;
  subtitle: string;
  icon: Resource;
}

// 推荐功能接口
interface RecommendedFeature {
  id: string;
  title: string;
  description: string;
  icon: Resource;
  selected: boolean;
}

// 备选方案接口
interface AlternativeSolution {
  id: string;
  title: string;
  matchPercent: number;
  icon: Resource;
}

@Entry
@Component
struct AIRecommendation {
  // 匹配度
  @State matchScore: number = 98;
  
  // 推荐场景
  @State recommendedScenario: RecommendedScenario = {
    title: '推荐场景',
    subtitle: '电商主图',
    icon: $r('app.media.startIcon')
  };

  // 推荐功能列表
  @State recommendedFeatures: RecommendedFeature[] = [
    {
      id: 'cutout',
      title: '智能抠图',
      description: 'AI精准识别主体,一键移除背景',
      icon: $r('app.media.startIcon'),
      selected: true
    },
    {
      id: 'background',
      title: '专业背景',
      description: '电商级背景模板,提升转化率',
      icon: $r('app.media.startIcon'),
      selected: true
    },
    {
      id: 'batch',
      title: '批量处理',
      description: '一次处理多张图片,节省时间',
      icon: $r('app.media.startIcon'),
      selected: true
    }
  ];

  // 返回上一页
  async handleBack() {
    console.info('[AIRecommendation] handleBack 被调用');
    try {
      await RouterService.getInstance().goBack();
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : String(err);
      console.error(`[AIRecommendation] 返回失败: ${errorMsg}`);
      // 如果无法返回，则返回到首页
      try {
        await RouterService.getInstance().navigateTo('pages/Index', undefined, true);
      } catch (error) {
        const navErrorMsg = error instanceof Error ? error.message : String(error);
        console.error(`[AIRecommendation] 跳转首页失败: ${navErrorMsg}`);
      }
    }
  }

  // 备选方案列表
  @State alternativeSolutions: AlternativeSolution[] = [
    {
      id: 'taobao',
      title: '淘宝主图',
      matchPercent: 92,
      icon: $r('app.media.startIcon')
    },
    {
      id: 'social',
      title: '社交媒体',
      matchPercent: 88,
      icon: $r('app.media.startIcon')
    },
    {
      id: 'amazon',
      title: '亚马逊产品图',
      matchPercent: 85,
      icon: $r('app.media.startIcon')
    }
  ];

  build() {
    Column() {
      // 顶部紫色渐变区域
      Stack() {
        // 渐变背景
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 135,
            colors: [
              ['#667eea', 0.0],
              ['#764ba2', 1.0]
            ]
          })

        // 装饰性元素（模糊圆圈）
        Stack() {
          Circle({ width: 80, height: 80 })
            .fill('#FFFFFF')
            .opacity(0.2)
        }
        .width(80)
        .height(80)
        .position({ x: '80%', y: '10%' })

        Stack() {
          Circle({ width: 64, height: 64 })
            .fill('#FFFFFF')
            .opacity(0.15)
        }
        .width(64)
        .height(64)
        .position({ x: '10%', y: '80%' })
        
        // 内容
        Column() {
          // 顶部栏（返回按钮 + 星标图标）
          Row() {
            // 返回按钮
            Button() {
              Text('<')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .type(ButtonType.Normal)
            .width(40)
            .height(40)
            .backgroundColor('#FFFFFF')
            .opacity(0.2)
            .borderRadius(8)
            .onClick(async () => {
              console.info('[AIRecommendation] 返回按钮被点击');
              await this.handleBack();
            })

            Blank()

            Image($r('app.media.startIcon'))
              .width(24)
              .height(24)
              .fillColor('#FFFFFF')
              .opacity(0.9)
          }
          .width('100%')
          .height(56)
          .padding({ left: 20, right: 20 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          
          // 匹配度圆圈（带星标图标）
          Stack() {
            Circle({ width: 128, height: 128 })
              .fill('rgba(255, 255, 255, 0.2)')
              .stroke('#FFFFFF')
              .strokeWidth(3)
              .opacity(0.3)
            
            Column() {
              Text(`${this.matchScore}%`)
                .fontSize(40)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .margin({ bottom: 4 })
              
              Text('匹配度')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .opacity(0.9)
            }
            .alignItems(HorizontalAlign.Center)

            // 星标图标（右上角）
            Stack() {
              Circle({ width: 24, height: 24 })
                .fill('#FFFFFF')
              Text('✨')
                .fontSize(16)
            }
            .width(24)
            .height(24)
            .position({ x: 104, y: -4 })
          }
          .width(128)
          .height(128)
          .margin({ top: 20, bottom: 24 })
          .transition(TransitionEffect.OPACITY.animation({ duration: 500, curve: Curve.EaseOut }))
          
          // 主标题
          Text('为您推荐最佳方案')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ bottom: 8 })
          
          // 副标题
          Text('基于您的需求,我们为您定制了专属的图片处理方案')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .opacity(0.9)
            .textAlign(TextAlign.Center)
            .padding({ left: 20, right: 20 })
            .margin({ bottom: 32 })
          
          // 推荐场景卡片
          Column() {
            Row() {
              // 场景图标（渐变背景）
              Stack() {
                Rect()
                  .width(48)
                  .height(48)
                  .radius(12)
                  .fill('#667eea')
                  .opacity(0.2)
                
                Image(this.recommendedScenario.icon)
                  .width(24)
                  .height(24)
                  .fillColor('#667eea')
              }
              .width(48)
              .height(48)
              .margin({ right: 12 })
              
              Column() {
                Text(this.recommendedScenario.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1F2937')
                  .margin({ bottom: 4 })
                
                Text(this.recommendedScenario.subtitle)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#667eea')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            
            // 效果预览区域
            Stack() {
              Rect()
                .width('100%')
                .height(200)
                .radius(12)
                .fill('#F3F4F6')
              
              // 效果预览标签
              Row() {
                Text('效果预览')
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor('#1F2937')
                  .borderRadius(12)
              }
              .position({ x: 12, y: 12 })
              
              // 产品图片占位
              Image($r('app.media.startIcon'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
            }
            .width('100%')
            .height(200)
            .margin({ top: 12, left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ left: 20, right: 20, bottom: 20 })
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
        
      
      // 底部白色区域
      Scroll() {
        Column() {
          // 为您推荐的功能
          Text('为您推荐的功能')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
            .width('100%')
            .margin({ top: 24, bottom: 16, left: 20, right: 20 })
            .textAlign(TextAlign.Start)
          
          // 功能列表
          Column() {
            ForEach(this.recommendedFeatures, (feature: RecommendedFeature) => {
              Row() {
                // 功能图标（渐变背景）
                Stack() {
                  Rect()
                    .width(40)
                    .height(40)
                    .radius(10)
                    .fill('#667eea')
                  
                  Image(feature.icon)
                    .width(20)
                    .height(20)
                    .fillColor('#FFFFFF')
                }
                .width(40)
                .height(40)
                .margin({ right: 12 })
                
                Column() {
                  Text(feature.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1F2937')
                    .margin({ bottom: 4 })
                  
                  Text(feature.description)
                    .fontSize(12)
                    .fontColor('#6B7280')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                
                // 选中标记（对勾）
                if (feature.selected) {
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
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .margin({ bottom: 8 })
              .backgroundColor('#F8F9FC')
              .borderRadius(12)
              .border({ width: 1, color: '#E5E7EB' })
              .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
            }, (feature: RecommendedFeature) => feature.id)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          
          // 备选方案
          Text('备选方案')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
            .width('100%')
            .margin({ top: 24, bottom: 16, left: 20, right: 20 })
            .textAlign(TextAlign.Start)
          
          // 横向滚动的备选方案
          Scroll() {
            Row() {
              ForEach(this.alternativeSolutions, (solution: AlternativeSolution) => {
                Column() {
                  Stack() {
                    Rect()
                      .width(60)
                      .height(60)
                      .radius(12)
                      .fill('#F8F9FC')
                    
                    Image(solution.icon)
                      .width(30)
                      .height(30)
                      .fillColor('#667eea')
                  }
                  .width(60)
                  .height(60)
                  .margin({ bottom: 8 })
                  
                  Text(solution.title)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1F2937')
                    .margin({ bottom: 4 })
                  
                  Row() {
                    Text(`${solution.matchPercent}%`)
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#667eea')
                    Text('匹配')
                    .fontSize(12)
                    .fontColor('#6B7280')
                  }
                  .justifyContent(FlexAlign.Center)
                }
                .width(120)
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .border({ width: 1, color: '#E5E7EB' })
                .shadow({
                  radius: 4,
                  color: '#000000',
                  offsetX: 0,
                  offsetY: 2
                })
                .margin({ right: 12 })
                .onClick(() => {
                  // 选择备选方案
                  console.info(`选择备选方案: ${solution.title}`);
                })
              }, (solution: AlternativeSolution) => solution.id)
            }
            .padding({ left: 20, right: 20 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Auto)
          .width('100%')
          .margin({ bottom: 24 })
          
          // 底部按钮
          Column() {
            // 立即上传体验按钮
            Button() {
              Row() {
                Image($r('app.media.startIcon'))
                  .width(20)
                  .height(20)
                  .fillColor('#FFFFFF')
                  .margin({ right: 8 })
                
                Text('立即上传体验')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
              }
              .justifyContent(FlexAlign.Center)
            }
            .type(ButtonType.Normal)
            .width('100%')
            .height(48)
            .borderRadius(12)
            .linearGradient({
              angle: 135,
              colors: [
                ['#667eea', 0.0],
                ['#764ba2', 1.0]
              ]
            })
            .margin({ bottom: 12 })
            .onClick(() => {
              // 跳转到上传页面
              console.info('跳转到上传页面');
            })
            
            // 稍后再说按钮
            Button() {
              Text('稍后再说')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#6B7280')
            }
            .type(ButtonType.Normal)
            .width('100%')
            .height(48)
            .borderRadius(12)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#E5E7EB' })
            .onClick(() => {
              // 返回首页
              RouterService.getInstance().navigateTo('pages/Index', undefined, true)
                .catch((err: Error) => {
                  console.error(`跳转失败: ${err.message}`);
                });
            })
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 20 })
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 24, topRight: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }
}

