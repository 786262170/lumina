/**
 * ============================================
 * LUMINA AI - TOP NAVIGATION BAR COMPONENT
 * 顶部导航栏组件
 * ============================================
 */

import { RouterService } from '../services/RouterService';

/**
 * 顶部导航栏组件
 * 用于需要显示顶部导航栏的页面（如Settings、MemberSubscription等）
 */
@Component
export struct TopNavBar {
  @Prop title: string = ''; // 标题
  @Prop showBack: boolean = true; // 是否显示返回按钮
  @Prop goBackToIndex: boolean = false; // true: 返回首页, false: 返回上一级（子页面使用）
  @Prop disableNavigation: boolean = false; // true: 禁用跳转功能（仅UI展示）
  private routerService: RouterService = RouterService.getInstance();

  /**
   * 返回处理
   */
  private async handleBack() {
    console.info(`[TopNavBar] 返回按钮被点击，标题: ${this.title}, goBackToIndex: ${this.goBackToIndex}, disableNavigation: ${this.disableNavigation}`);
    
    // 如果禁用了跳转，只打印日志
    if (this.disableNavigation) {
      console.info('[TopNavBar] 跳转功能已禁用，仅UI展示');
      return;
    }
    
    try {
      if (this.goBackToIndex) {
        // 返回首页
        await this.routerService.navigateTo('pages/Index', undefined, true);
      } else {
        // 返回上一级
      await this.routerService.goBack();
      }
    } catch (error) {
      const navErrorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[TopNavBar] 返回失败: ${navErrorMsg}`);
      // 如果返回上一级失败，尝试返回首页
      if (!this.goBackToIndex) {
      try {
        await this.routerService.navigateTo('pages/Index', undefined, true);
        } catch (fallbackError) {
          const fallbackMsg = fallbackError instanceof Error ? fallbackError.message : String(fallbackError);
          console.error(`[TopNavBar] 返回首页也失败: ${fallbackMsg}`);
        }
      }
    }
  }

  build() {
    Row() {
      // 返回按钮
      if (this.showBack) {
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
        .onClick(() => {
          this.handleBack();
        })
      } else {
        Blank()
          .width(40)
      }

      // 标题
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 占位，保持标题居中
      Blank()
        .width(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 1 }, color: '#E5E7EB' })
  }
}

