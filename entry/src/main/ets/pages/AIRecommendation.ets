import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';
import { AIService, RecommendationConfirmationRequest } from '../common/services/AIService';
import { RecommendationItem } from '../common/types/CommonTypes';
import { TopNavBar } from '../common/components/TopNavBar';
import { IconComponent, IconType } from '../common/components/IconComponent';
import { ToastUtil } from '../common/utils/ToastUtil';

// 推荐场景接口
interface RecommendedScenario {
  title: string;
  subtitle: string;
  iconType: IconType;
  previewImage?: string;
}

// 推荐功能接口
interface RecommendedFeature {
  id: string;
  title: string;
  description: string;
  iconType: IconType;
  selected: boolean;
}

// 备选方案接口
interface AlternativeSolution {
  id: string;
  title: string;
  matchPercent: number;
  iconType: IconType;
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
    iconType: IconType.RECOMMENDATION,
    previewImage: undefined
  };

  // 推荐功能列表
  @State recommendedFeatures: RecommendedFeature[] = [
    {
      id: 'cutout',
      title: '智能抠图',
      description: 'AI精准识别主体,一键移除背景',
      iconType: IconType.CUTOUT,
      selected: true
    },
    {
      id: 'background',
      title: '背景替换',
      description: '多种背景模板,一键替换',
      iconType: IconType.BACKGROUND,
      selected: true
    },
    {
      id: 'light',
      title: '光效调整',
      description: '智能调整光线,提升图片质感',
      iconType: IconType.LIGHT,
      selected: true
    }
  ];

  // 会话ID（从问卷页面传递）
  @State quizSessionId: string = '';
  // 加载状态
  @State isLoading: boolean = true;
  // 提交状态
  @State isSubmitting: boolean = false;
  // 当前选中的场景类型
  @State selectedSceneType: string = '';
  
  private aiService: AIService = AIService.getInstance();

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params['quizSessionId']) {
      this.quizSessionId = params['quizSessionId'] as string;
    }
    
    // 加载AI推荐
    this.loadRecommendations();
  }

  // 加载AI推荐
  async loadRecommendations() {
    this.isLoading = true;
    try {
      console.info(`[AIRecommendation] 开始加载AI推荐，会话ID: ${this.quizSessionId || '无'}`);
      const recommendations = await this.aiService.getRecommendations(this.quizSessionId || undefined);
      
      // 验证数据完整性
      if (!recommendations || !recommendations.primaryRecommendation) {
        throw new Error('推荐数据格式错误：缺少主推荐信息');
      }
      
      const primary = recommendations.primaryRecommendation;
      console.info(`[AIRecommendation] 成功加载AI推荐，主要推荐: ${primary.sceneName || '未知'}`);
      
      // 更新推荐场景
      this.recommendedScenario = {
        title: primary.sceneName || '推荐场景',
        subtitle: primary.description || '暂无描述',
        iconType: this.getSceneIconType(
          primary.sceneType || '',
          primary.sceneName || ''
        ),
        previewImage: primary.previewImage
      };
      
      // 保存选中的场景类型
      this.selectedSceneType = primary.sceneType || '';
      
      // 更新推荐功能列表
      const recommendedFeaturesList: RecommendedFeature[] = [];
      if (recommendations.recommendedFeatures && recommendations.recommendedFeatures.length > 0) {
        for (let i = 0; i < recommendations.recommendedFeatures.length; i++) {
          const feature = recommendations.recommendedFeatures[i];
          if (!feature || !feature.id) {
            continue; // 跳过无效的功能项
          }
          
          // 根据功能ID选择对应的图标类型
          let featureIconType: IconType = IconType.SCENARIO;
          const featureIdLower = feature.id.toLowerCase();
          // 支持多种ID格式：smart_cutout/cutout, background_replace/background, lighting_adjust/light
          if (featureIdLower.includes('cutout') || featureIdLower === 'smart_cutout') {
            featureIconType = IconType.CUTOUT;
          } else if (featureIdLower.includes('background') || featureIdLower === 'background_replace') {
            featureIconType = IconType.BACKGROUND;
          } else if (featureIdLower.includes('batch')) {
            featureIconType = IconType.BATCH;
          } else if (featureIdLower.includes('light') || featureIdLower === 'lighting_adjust') {
            featureIconType = IconType.LIGHT;
          }
          
          const recommendedFeature: RecommendedFeature = {
            id: feature.id,
            title: feature.name || '未知功能',
            description: feature.description || '暂无描述',
            iconType: featureIconType,
            selected: true
          };
          recommendedFeaturesList.push(recommendedFeature);
        }
      }
      this.recommendedFeatures = recommendedFeaturesList.length > 0 ? recommendedFeaturesList : this.recommendedFeatures;
      
      // 更新备选方案列表
      const alternativeSolutionsList: AlternativeSolution[] = [];
      if (recommendations.alternatives && recommendations.alternatives.length > 0) {
        for (let i = 0; i < recommendations.alternatives.length; i++) {
          const alt = recommendations.alternatives[i];
          if (!alt || !alt.sceneType) {
            continue; // 跳过无效的备选方案
          }
          
          // 根据场景类型选择对应的图标类型
          let sceneIconType: IconType = this.getSceneIconType(alt.sceneType, alt.sceneName || '');
          
          const alternativeSolution: AlternativeSolution = {
            id: alt.sceneType,
            title: alt.sceneName || '未知场景',
            matchPercent: alt.matchPercentage || 0,
            iconType: sceneIconType
          };
          alternativeSolutionsList.push(alternativeSolution);
        }
      }
      this.alternativeSolutions = alternativeSolutionsList.length > 0 ? alternativeSolutionsList : this.alternativeSolutions;
      
      // 更新匹配度
      this.matchScore = primary.matchPercentage || 0;
      
      console.info(`[AIRecommendation] 数据更新完成 - 场景: ${this.recommendedScenario.title}, 功能数: ${this.recommendedFeatures.length}, 备选数: ${this.alternativeSolutions.length}, 匹配度: ${this.matchScore}%`);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[AIRecommendation] 加载AI推荐失败: ${errorMsg}`);
      ToastUtil.showError(`加载推荐失败: ${errorMsg}`);
      // 如果加载失败，使用默认推荐数据（不影响页面显示）
    } finally {
      this.isLoading = false;
    }
  }

  // 根据场景类型和名称获取对应的图标类型
  private getSceneIconType(sceneType: string, sceneName: string): IconType {
    const typeLower = sceneType.toLowerCase();
    const nameLower = sceneName.toLowerCase();
    
    // 淘宝相关
    if (typeLower.includes('taobao') || nameLower.includes('淘宝')) {
      return IconType.TAOBAO;
    }
    // 天猫相关
    if (typeLower.includes('tmall') || nameLower.includes('天猫')) {
      return IconType.TMALL;
    }
    // 京东相关
    if (typeLower.includes('jd') || typeLower.includes('jingdong') || nameLower.includes('京东')) {
      return IconType.JD;
    }
    // 抖音相关
    if (typeLower.includes('douyin') || nameLower.includes('抖音')) {
      return IconType.DOUYIN;
    }
    // 小红书相关
    if (typeLower.includes('xiaohongshu') || nameLower.includes('小红书')) {
      return IconType.XIAOHONGSHU;
    }
    // 亚马逊相关
    if (typeLower.includes('amazon') || nameLower.includes('亚马逊')) {
      return IconType.AMAZON;
    }
    // 社交媒体/通用
    if (typeLower.includes('social') || nameLower.includes('社交') || nameLower.includes('媒体')) {
      return IconType.RECOMMENDATION;
    }
    // 默认使用推荐图标
    return IconType.RECOMMENDATION;
  }

  // 返回首页
  async handleBack() {
    console.info('[AIRecommendation] handleBack 被调用');
    try {
      await RouterService.getInstance().navigateTo('pages/Index', undefined, true);
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : String(err);
      console.error(`[AIRecommendation] 跳转首页失败: ${errorMsg}`);
    }
  }

  // 确认推荐并跳转到主页
  async handleConfirmRecommendation() {
    if (this.isSubmitting) {
      return;
    }

    // 获取选中的功能ID列表（用于日志记录）
    const selectedFeatureIds: string[] = [];
    for (let i = 0; i < this.recommendedFeatures.length; i++) {
      if (this.recommendedFeatures[i].selected) {
        selectedFeatureIds.push(this.recommendedFeatures[i].id);
      }
    }

    if (selectedFeatureIds.length === 0) {
      ToastUtil.showWarning('请至少选择一个功能');
      return;
    }

    this.isSubmitting = true;
    try {
      console.info(`[AIRecommendation] 选中功能: ${selectedFeatureIds.join(', ')}, 跳转到主页`);
      ToastUtil.showSuccess('提交成功');
      
      // 直接跳转到主页
      await RouterService.getInstance().navigateTo('pages/Index', undefined, false);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[AIRecommendation] 跳转失败: ${errorMsg}`);
      ToastUtil.showError(`跳转失败: ${errorMsg}`);
    } finally {
      this.isSubmitting = false;
    }
  }

  // 备选方案列表
  @State alternativeSolutions: AlternativeSolution[] = [
    {
      id: 'taobao',
      title: '淘宝主图',
      matchPercent: 92,
      iconType: IconType.TAOBAO
    },
    {
      id: 'douyin',
      title: '抖音视频封面',
      matchPercent: 85,
      iconType: IconType.DOUYIN
    },
    {
      id: 'xiaohongshu',
      title: '小红书配图',
      matchPercent: 82,
      iconType: IconType.XIAOHONGSHU
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
              Image($r('app.media.last'))
                .width(20)
                .height(20)
                .fillColor('#FFFFFF')
            }
            .type(ButtonType.Normal)
            .width(40)
            .height(40)
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .borderRadius(8)
            .onClick(async () => {
              await this.handleBack();
            })

            Blank()

            // 星标图标
            IconComponent({ iconType: IconType.STAR, iconSize: 24, iconColor: '#FFFFFF' })
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
            
            if (this.isLoading) {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#FFFFFF')
            } else {
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
            }

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
                
                IconComponent({ iconType: this.recommendedScenario.iconType, iconSize: 24, iconColor: '#667eea' })
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
              
              // 如果有预览图片，显示图片；否则显示占位图标
              if (this.recommendedScenario.previewImage) {
                Image(this.recommendedScenario.previewImage)
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(12)
              } else {
                IconComponent({ iconType: IconType.RECOMMENDATION, iconSize: 200, iconColor: '#667eea' })
                  .opacity(0.3)
              }
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
          if (this.recommendedFeatures.length > 0) {
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
                  
                  IconComponent({ iconType: feature.iconType, iconSize: 20, iconColor: '#FFFFFF' })
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
              .backgroundColor(feature.selected ? '#F0F4FF' : '#F8F9FC')
              .borderRadius(12)
              .border({ 
                width: feature.selected ? 2 : 1, 
                color: feature.selected ? '#667eea' : '#E5E7EB' 
              })
              .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut }))
              .onClick(() => {
                // 切换功能选中状态
                const index = this.recommendedFeatures.findIndex(f => f.id === feature.id);
                if (index !== -1) {
                  // 创建新数组并更新选中状态（ArkTS不支持展开运算符，需要手动创建）
                  const newFeatures: RecommendedFeature[] = [];
                  for (let i = 0; i < this.recommendedFeatures.length; i++) {
                    if (i === index) {
                      // 更新选中状态
                      const updatedFeature: RecommendedFeature = {
                        id: this.recommendedFeatures[i].id,
                        title: this.recommendedFeatures[i].title,
                        description: this.recommendedFeatures[i].description,
                        iconType: this.recommendedFeatures[i].iconType,
                        selected: !this.recommendedFeatures[i].selected
                      };
                      newFeatures.push(updatedFeature);
                    } else {
                      // 保持原样
                      newFeatures.push(this.recommendedFeatures[i]);
                    }
                  }
                  this.recommendedFeatures = newFeatures;
                  console.info(`[AIRecommendation] 功能 ${feature.title} 选中状态: ${newFeatures[index].selected}`);
                }
              })
            }, (feature: RecommendedFeature, index: number) => `${feature.id}_${index}`)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
          } else {
            // 空状态提示
            Column() {
              Text('暂无推荐功能')
                .fontSize(14)
                .fontColor('#9CA3AF')
                .textAlign(TextAlign.Center)
                .padding({ top: 20, bottom: 20 })
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
          }
          
          // 备选方案
          Text('备选方案')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
            .width('100%')
            .margin({ top: 24, bottom: 16, left: 20, right: 20 })
            .textAlign(TextAlign.Start)
          
          // 横向滚动的备选方案
          if (this.alternativeSolutions.length > 0) {
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
                    
                    IconComponent({ iconType: solution.iconType, iconSize: 30, iconColor: '#667eea' })
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
          } else {
            // 空状态提示
            Column() {
              Text('暂无备选方案')
                .fontSize(14)
                .fontColor('#9CA3AF')
                .textAlign(TextAlign.Center)
                .padding({ top: 20, bottom: 20 })
            }
            .width('100%')
            .margin({ bottom: 24 })
          }
          
          // 底部按钮
          Column() {
            // 立即上传体验按钮
            Button() {
              if (this.isSubmitting) {
                Row() {
                  LoadingProgress()
                    .width(20)
                    .height(20)
                    .color('#FFFFFF')
                    .margin({ right: 8 })
                  Text('提交中...')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                }
                .justifyContent(FlexAlign.Center)
              } else {
                Row() {
                  IconComponent({ iconType: IconType.RECOMMENDATION, iconSize: 20, iconColor: '#FFFFFF' })
                    .margin({ right: 8 })
                  
                  Text('立即上传体验')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                }
                .justifyContent(FlexAlign.Center)
              }
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
            .enabled(!this.isSubmitting)
            .opacity(this.isSubmitting ? 0.6 : 1)
            .onClick(() => {
              this.handleConfirmRecommendation();
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

