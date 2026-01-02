import router from '@ohos.router';
import { PrivilegeItem, SubscriptionPlan } from '../common/types/CommonTypes';

@Entry
@Component
struct MemberSubscription {
  @State isAgreed: boolean = false; // 是否同意订阅协议
  @State selectedPlan: string = 'annual'; // 选中的套餐：'monthly' 或 'annual'

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

        // 标题
        Text('会员订阅')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1F36')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: -40 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })

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

            Row() {
              // 月付方案
              this.buildPricingPlan('monthly', '月付', 29, '月', ['无限使用', '极速处理', '高清导出'], false)
              
              // 年付方案（推荐）
              this.buildPricingPlan('annual', '年付', 299, '年', ['无限使用', '极速处理', '高清导出', '专属客服', '高级功能'], true)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
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
            Button('确认订阅')
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
              .backgroundColor(this.isAgreed ? '#8B5CF6' : '#D1D5DB')
              .borderRadius(8)
              .width(100)
              .height(44)
              .enabled(this.isAgreed)
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

  // 构建价格方案卡片
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
      this.selectedPlan = id;
    })
  }

  // 处理订阅
  handleSubscribe() {
    if (!this.isAgreed) {
      return;
    }

    console.info(`确认订阅: ${this.selectedPlan}`);
    // TODO: 实现订阅功能
    // 1. 调用支付接口
    // 2. 处理支付结果
    // 3. 更新用户会员状态
    // 4. 返回上一页或跳转到成功页面

    // 示例：显示成功提示后返回
    // promptAction.showToast({
    //   message: '订阅成功',
    //   duration: 2000
    // });
    // setTimeout(() => {
    //   router.back();
    // }, 2000);
  }
}

