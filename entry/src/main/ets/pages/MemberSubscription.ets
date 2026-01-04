import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';
import { SubscriptionService, SubscriptionPlan as ApiSubscriptionPlan, PlanId, BadgeColor } from '../common/services/SubscriptionService';
import { PrivilegeItem } from '../common/types/CommonTypes';
import { TopNavBar } from '../common/components/TopNavBar';
import { ToastUtil } from '../common/utils/ToastUtil';

@Entry
@Component
struct MemberSubscription {
  @State isAgreed: boolean = false; // 是否同意订阅协议
  @State selectedPlan: PlanId = 'annual'; // 选中的套餐：'monthly' 或 'annual'
  @State subscriptionPlans: ApiSubscriptionPlan[] = []; // 订阅计划列表
  @State isLoading: boolean = false; // 是否正在加载
  @State isSubscribing: boolean = false; // 是否正在订阅


  // 会员特权列表
  private privileges: PrivilegeItem[] = [
    {
      icon: 'infinity',
      title: '无限使用',
      description: '每日处理图片数量不限'
    },
    {
      icon: 'lightning',
      title: '极速处理',
      description: 'AI处理速度提升3倍'
    },
    {
      icon: 'download',
      title: '高清导出',
      description: '支持4K分辨率导出'
    },
    {
      icon: 'service',
      title: '专属客服',
      description: '1对1专属技术支持'
    },
    {
      icon: 'star',
      title: '高级功能',
      description: '优先体验新功能'
    }
  ];

  private subscriptionService: SubscriptionService = SubscriptionService.getInstance();

  aboutToAppear() {
    // 加载订阅计划
    this.loadSubscriptionPlans();
    // 加载当前订阅信息
    this.loadCurrentSubscription();
  }

  // 加载当前订阅信息
  async loadCurrentSubscription() {
    try {
      // 不显示错误提示，因为 404 表示用户未订阅，是正常情况
      const currentSubscription = await this.subscriptionService.getCurrentSubscription(false);
      console.info(`[MemberSubscription] 当前订阅: ${currentSubscription.planName}, 到期时间: ${currentSubscription.expiryDate}`);
      
      // 如果用户有活跃订阅，可以显示订阅状态
      if (currentSubscription.isActive) {
        // 可以更新UI显示当前订阅信息
        console.info(`[MemberSubscription] 用户有活跃订阅，计划ID: ${currentSubscription.planId}`);
      }
    } catch (error) {
      // 404 错误表示用户未订阅，这是正常情况，不需要显示错误提示
      const errorMessage = error instanceof Error ? error.message : String(error);
      if (errorMessage.includes('资源不存在') || errorMessage.includes('NOT_FOUND')) {
        console.info(`[MemberSubscription] 用户未订阅（正常情况）`);
      } else {
        console.error(`[MemberSubscription] 加载当前订阅失败: ${error}`);
      }
      // 如果用户没有订阅或接口返回错误，不影响页面正常显示
    }
  }

  // 加载订阅计划
  async loadSubscriptionPlans() {
    try {
      this.isLoading = true;
      const response = await this.subscriptionService.getPlans();
      this.subscriptionPlans = response.plans;
      console.info(`[MemberSubscription] 成功加载 ${response.plans.length} 个订阅计划`);
      
      // 如果有推荐计划，默认选中推荐计划
      const highlightedPlan = response.plans.find((plan: ApiSubscriptionPlan) => plan.highlighted);
      if (highlightedPlan) {
        this.selectedPlan = highlightedPlan.id;
      }
    } catch (error) {
      console.error(`[MemberSubscription] 加载订阅计划失败: ${error}`);
      ToastUtil.showError('加载订阅计划失败，请稍后重试');
      // 如果加载失败，使用默认计划作为后备
      this.subscriptionPlans = [
        {
          id: 'monthly' as PlanId,
          name: '月付会员',
          price: 29,
          period: '/月',
          periodSubtext: undefined,
          badge: undefined,
          features: ['每日50次使用', '标准处理速度', '标准质量导出'],
          highlighted: false
        },
        {
          id: 'annual' as PlanId,
          name: '年度会员',
          price: 299,
          period: '/年',
          periodSubtext: '(平均¥25/月)',
          badge: {
            text: '省30%',
            color: 'primary' as BadgeColor
          },
          features: ['每日无限使用', '极速处理', '高清导出'],
          highlighted: true
        }
      ];
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      TopNavBar({ title: '会员订阅', showBack: true, goBackToIndex: false })

      // 内容区域
      Scroll() {
        Column() {
          // 头部区域
          Column() {
            // 皇冠图标（使用圆形背景）
            Stack() {
              Circle({ width: 80, height: 80 })
                .fill('#8B5CF6')
                .stroke('#FFFFFF')
                .strokeWidth(2)

              // 皇冠图标（使用Image组件，后续可替换为实际图标）
              Image($r('app.media.startIcon'))
                .width(40)
                .height(40)
                .fillColor('#FFFFFF')
            }
            .width(80)
            .height(80)
            .margin({ bottom: 24 })

            // 主标题
            Text('解锁无限可能')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2937')
              .margin({ bottom: 8 })

            // 副标题
            Text('升级会员,享受专业级图像处理服务')
              .fontSize(14)
              .fontColor('#6B7280')
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 40, bottom: 32 })
          .alignItems(HorizontalAlign.Center)

          // 会员特权卡片
          Column() {
            Text('会员特权')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2937')
              .width('100%')
              .margin({ bottom: 16 })

            // 特权列表
            ForEach(this.privileges, (privilege: PrivilegeItem, index: number) => {
              this.buildPrivilegeItem(privilege, index)
            }, (privilege: PrivilegeItem) => privilege.title)
          }
          .width('100%')
          .padding(20)
          .margin({ left: 20, right: 20, bottom: 24 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          // 价格方案卡片
          Column() {
            Text('选择套餐')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1F36')
              .width('100%')
              .margin({ bottom: 16 })

            if (this.isLoading) {
              // 加载中状态
              Row() {
                Text('加载中...')
                  .fontSize(14)
                  .fontColor('#6B7280')
              }
              .width('100%')
              .height(200)
              .justifyContent(FlexAlign.Center)
            } else if (this.subscriptionPlans.length > 0) {
              // 显示订阅计划
              Row() {
                ForEach(this.subscriptionPlans, (plan: ApiSubscriptionPlan) => {
                  this.buildPricingPlanFromApi(plan)
                }, (plan: ApiSubscriptionPlan) => plan.id)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            } else {
              // 无数据状态
              Row() {
                Text('暂无订阅计划')
                  .fontSize(14)
                  .fontColor('#6B7280')
              }
              .width('100%')
              .height(200)
              .justifyContent(FlexAlign.Center)
            }
          }
          .width('100%')
          .padding(20)
          .margin({ left: 20, right: 20, bottom: 24 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          // 保障说明
          Column() {
            Row() {
              Stack() {
                Circle({ width: 24, height: 24 })
                  .fill('#10B981')
                Text('✓')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Medium)
              }
              .width(24)
              .height(24)
              .margin({ right: 12 })

              Column() {
                Text('7天无理由退款')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1F36')
                  .margin({ bottom: 2 })

                Text('订阅后7天内可申请全额退款')
                  .fontSize(12)
                  .fontColor('#6B7280')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 16 })

            Row() {
              Stack() {
                Circle({ width: 24, height: 24 })
                  .fill('#10B981')
                Text('✓')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Medium)
              }
              .width(24)
              .height(24)
              .margin({ right: 12 })

              Column() {
                Text('随时可取消')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1F36')
                  .margin({ bottom: 2 })

                Text('自动续费可随时在设置中取消')
                  .fontSize(12)
                  .fontColor('#6B7280')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .margin({ left: 20, right: 20, bottom: 24 })
          .backgroundColor('#F8F9FC')
          .borderRadius(12)

          // 订阅确认区域
          Row() {
            // 左侧：协议复选框
            Column() {
              Row() {
                // 复选框
                Checkbox({ name: 'agree', group: 'subscription' })
                  .select(this.isAgreed)
                  .selectedColor('#8B5CF6')
                  .unselectedColor('#D1D5DB')
                  .mark({ strokeColor: '#FFFFFF', size: 4 })
                  .onChange((value: boolean) => {
                    this.isAgreed = value;
                  })

                Text('同意订阅协议')
                  .fontSize(14)
                  .fontColor('#1F2937')
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.isAgreed = !this.isAgreed;
                  })
              }
              .alignItems(VerticalAlign.Center)

              Text('自动续费可随时取消')
                .fontSize(12)
                .fontColor('#9CA3AF')
                .margin({ top: 4, left: 28 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // 右侧：确认订阅按钮
            Button(this.isSubscribing ? '处理中...' : '确认订阅')
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
              .backgroundColor(this.isAgreed && !this.isSubscribing ? '#8B5CF6' : '#D1D5DB')
              .borderRadius(8)
              .width(100)
              .height(44)
              .enabled(this.isAgreed && !this.isSubscribing)
              .onClick(() => {
                this.handleSubscribe();
              })
          }
          .width('100%')
          .padding(20)
          .margin({ left: 20, right: 20, bottom: 40 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }

  // 构建特权项
  @Builder
  buildPrivilegeItem(privilege: PrivilegeItem, index: number) {
    Row() {
      // 图标
      Stack() {
        Circle({ width: 40, height: 40 })
          .fill('#F5F3FF')
          .stroke('#E9D5FF')
          .strokeWidth(1)

        // 图标（使用Image组件，后续可替换为实际图标）
        Image($r('app.media.startIcon'))
          .width(20)
          .height(20)
          .fillColor('#8B5CF6')
      }
      .width(40)
      .height(40)
      .margin({ right: 16 })

      // 文字内容
      Column() {
        Text(privilege.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2937')
          .margin({ bottom: 4 })

        Text(privilege.description)
          .fontSize(13)
          .fontColor('#6B7280')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: index < this.privileges.length - 1 ? 1 : 0 }, color: '#F3F4F6' })
  }

  // 从API数据构建价格方案卡片
  @Builder
  buildPricingPlanFromApi(plan: ApiSubscriptionPlan) {
    Column() {
      // 推荐标签
      if (plan.highlighted) {
        Row() {
          if (plan.badge) {
            Text(plan.badge.text)
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(plan.badge.color === 'primary' ? '#667eea' : '#8B5CF6')
              .borderRadius(4)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ bottom: 8 })
      }

      // 方案名称
      Text(plan.name)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .margin({ bottom: 12 })
        .width('100%')

      // 价格
      Row() {
        Text(`¥${plan.price}`)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#667eea')

        Column() {
          Text(plan.period)
            .fontSize(14)
            .fontColor('#6B7280')
          if (plan.periodSubtext) {
            Text(plan.periodSubtext)
              .fontSize(11)
              .fontColor('#9CA3AF')
              .margin({ top: 2 })
          }
        }
        .margin({ left: 4, top: 8 })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 功能列表
      Column() {
        ForEach(plan.features, (feature: string) => {
          Row() {
            Text('✓')
              .fontSize(12)
              .fontColor('#10B981')
              .margin({ right: 8 })

            Text(feature)
              .fontSize(12)
              .fontColor('#1A1F36')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 8 })
          .alignItems(VerticalAlign.Center)
        }, (feature: string) => feature)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('48%')
    .padding(16)
    .borderRadius(12)
    .backgroundColor(plan.highlighted ? '#F8F9FC' : '#FFFFFF')
    .border({
      width: this.selectedPlan === plan.id ? 2 : 1,
      color: this.selectedPlan === plan.id ? '#667eea' : (plan.highlighted ? '#667eea' : '#E5E7EB')
    })
    .onClick(() => {
      this.selectedPlan = plan.id;
    })
  }

  // 构建价格方案卡片（保留原有方法作为后备）
  @Builder
  buildPricingPlan(id: string, name: string, price: number, period: string, features: string[], highlighted: boolean) {
    Column() {
      // 推荐标签
      if (highlighted) {
        Row() {
          Text('推荐')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#667eea')
            .borderRadius(4)
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ bottom: 8 })
      }

      // 方案名称
      Text(name)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .margin({ bottom: 12 })
        .width('100%')

      // 价格
      Row() {
        Text(`¥${price}`)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#667eea')

        Text(`/${period}`)
          .fontSize(14)
          .fontColor('#6B7280')
          .margin({ left: 4, top: 8 })
      }
        .width('100%')
        .margin({ bottom: 16 })

      // 功能列表
      Column() {
        ForEach(features, (feature: string) => {
          Row() {
            Text('✓')
              .fontSize(12)
              .fontColor('#10B981')
              .margin({ right: 8 })

            Text(feature)
              .fontSize(12)
              .fontColor('#1A1F36')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 8 })
          .alignItems(VerticalAlign.Center)
        }, (feature: string) => feature)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('48%')
    .padding(16)
    .borderRadius(12)
    .backgroundColor(highlighted ? '#F8F9FC' : '#FFFFFF')
    .border({
      width: this.selectedPlan === id ? 2 : 1,
      color: this.selectedPlan === id ? '#667eea' : (highlighted ? '#667eea' : '#E5E7EB')
    })
    .onClick(() => {
      this.selectedPlan = id as PlanId;
    })
  }

  // 处理订阅
  async handleSubscribe() {
    if (!this.isAgreed || this.isSubscribing) {
      return;
    }

    try {
      this.isSubscribing = true;
      console.info(`[MemberSubscription] 确认订阅: ${this.selectedPlan}`);
      
      // 调用创建订阅订单接口
      const orderResponse = await this.subscriptionService.createOrder({
        planId: this.selectedPlan,
        paymentMethod: 'wechat' // 默认使用微信支付
      });
      
      console.info(`[MemberSubscription] 订单创建成功: ${orderResponse.orderId}`);
      
      // 显示支付信息
      if (orderResponse.paymentInfo && orderResponse.paymentInfo.qrCode) {
        // 如果有二维码，可以显示二维码让用户扫码支付
        // 这里先显示成功提示
        ToastUtil.showSuccess('订单创建成功，请完成支付');
        
        // TODO: 可以跳转到支付页面显示二维码
        // 或者使用弹窗显示二维码
        
        // 支付完成后，返回上一页
        setTimeout(() => {
          RouterService.getInstance().goBack();
        }, 2000);
      } else {
        ToastUtil.showSuccess('订阅成功');
        // 返回上一页
        setTimeout(() => {
          RouterService.getInstance().goBack();
        }, 1500);
      }
    } catch (error) {
      console.error(`[MemberSubscription] 订阅失败: ${error}`);
      const errorMsg = error instanceof Error ? error.message : String(error);
      ToastUtil.showError(`订阅失败: ${errorMsg}`);
    } finally {
      this.isSubscribing = false;
    }
  }
}

