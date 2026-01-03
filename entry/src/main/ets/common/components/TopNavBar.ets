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
  private routerService: RouterService = RouterService.getInstance();

  /**
   * 返回上一页
   */
  private async handleBack() {
    console.info(`[TopNavBar] 返回按钮被点击，标题: ${this.title}`);
    try {
      await this.routerService.goBack();
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : String(err);
      console.error(`[TopNavBar] 返回失败: ${errorMsg}`);
      // 如果无法返回，则返回到首页
      try {
        await this.routerService.navigateTo('pages/Index', undefined, true);
      } catch (error) {
        const navErrorMsg = error instanceof Error ? error.message : String(error);
        console.error(`[TopNavBar] 跳转首页失败: ${navErrorMsg}`);
      }
    }
  }

  build() {
    Row() {
      // 返回按钮
      if (this.showBack) {
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
        .onClick(async () => {
          await this.handleBack();
        })
      }

      // 标题
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1F36')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .margin({ left: this.showBack ? -40 : 0 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 1 }, color: '#E5E7EB' })
  }
}

