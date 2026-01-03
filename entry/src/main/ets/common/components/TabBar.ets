/**
 * ============================================
 * LUMINA AI - TAB BAR COMPONENT
 * 底部导航栏组件
 * ============================================
 */

import { RouterService } from '../services/RouterService';

/**
 * 底部导航栏组件
 */
@Component
export struct TabBar {
  @State currentTab: number = 0;
  private routerService: RouterService = RouterService.getInstance();
  private isSwitching: boolean = false; // 标记是否正在切换Tab

  aboutToAppear() {
    // 同步Tab状态
    this.currentTab = this.routerService.getActiveTab();
  }

  onPageShow() {
    // 页面显示时同步Tab状态（确保从其他页面返回时状态正确）
    // 如果正在切换Tab，不更新状态（避免覆盖立即更新的状态）
    if (!this.isSwitching) {
      this.currentTab = this.routerService.getActiveTab();
    }
    // 重置切换标志
    this.isSwitching = false;
  }

  build() {
    Row() {
      // 首页
      Column() {
        // 选中状态的渐变条（在图标上方）
        if (this.currentTab === 0) {
          Row()
            .width(40)
            .height(3)
            .borderRadius({ bottomLeft: 2, bottomRight: 2 })
            .linearGradient({
              angle: 135,
              colors: [
                ['#667eea', 0.0],
                ['#764ba2', 1.0]
              ]
            })
            .margin({ bottom: 4 })
        } else {
          // 占位，保持对齐
          Row()
            .width(40)
            .height(3)
            .margin({ bottom: 4 })
        }

        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor(this.currentTab === 0 ? '#667eea' : '#6B7280')

        Text($r('app.string.homepage'))
          .fontSize(12)
          .fontWeight(this.currentTab === 0 ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.currentTab === 0 ? '#667eea' : '#6B7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(async () => {
        // 标记正在切换Tab
        this.isSwitching = true;
        // 立即更新本地状态，确保UI即时响应
        this.currentTab = 0;
        // 同时立即更新RouterService的状态
        this.routerService.setActiveTab(0);
        // 然后执行路由切换
        try {
          await this.routerService.switchTab(0);
        } catch (err) {
          console.error(`切换Tab失败: ${err.message}`);
          // 如果切换失败，恢复状态
          this.currentTab = this.routerService.getActiveTab();
        } finally {
          // 切换完成后重置标志
          this.isSwitching = false;
        }
      })

      // 场景
      Column() {
        // 选中状态的渐变条（在图标上方）
        if (this.currentTab === 1) {
          Row()
            .width(40)
            .height(3)
            .borderRadius({ bottomLeft: 2, bottomRight: 2 })
            .linearGradient({
              angle: 135,
              colors: [
                ['#667eea', 0.0],
                ['#764ba2', 1.0]
              ]
            })
            .margin({ bottom: 4 })
        } else {
          // 占位，保持对齐
          Row()
            .width(40)
            .height(3)
            .margin({ bottom: 4 })
        }

        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor(this.currentTab === 1 ? '#667eea' : '#6B7280')

        Text($r('app.string.scenarios'))
          .fontSize(12)
          .fontWeight(this.currentTab === 1 ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.currentTab === 1 ? '#667eea' : '#6B7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(async () => {
        // 标记正在切换Tab
        this.isSwitching = true;
        // 立即更新本地状态，确保UI即时响应
        this.currentTab = 1;
        // 同时立即更新RouterService的状态
        this.routerService.setActiveTab(1);
        // 然后执行路由切换
        try {
          await this.routerService.switchTab(1);
        } catch (err) {
          console.error(`切换Tab失败: ${err.message}`);
          // 如果切换失败，恢复状态
          this.currentTab = this.routerService.getActiveTab();
        } finally {
          // 切换完成后重置标志
          this.isSwitching = false;
        }
      })

      // 作品
      Column() {
        // 选中状态的渐变条（在图标上方）
        if (this.currentTab === 2) {
          Row()
            .width(40)
            .height(3)
            .borderRadius({ bottomLeft: 2, bottomRight: 2 })
            .linearGradient({
              angle: 135,
              colors: [
                ['#667eea', 0.0],
                ['#764ba2', 1.0]
              ]
            })
            .margin({ bottom: 4 })
        } else {
          // 占位，保持对齐
          Row()
            .width(40)
            .height(3)
            .margin({ bottom: 4 })
        }

        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor(this.currentTab === 2 ? '#667eea' : '#6B7280')

        Text($r('app.string.works'))
          .fontSize(12)
          .fontWeight(this.currentTab === 2 ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.currentTab === 2 ? '#667eea' : '#6B7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(async () => {
        // 标记正在切换Tab
        this.isSwitching = true;
        // 立即更新本地状态，确保UI即时响应
        this.currentTab = 2;
        // 同时立即更新RouterService的状态
        this.routerService.setActiveTab(2);
        // 然后执行路由切换
        try {
          await this.routerService.switchTab(2);
        } catch (err) {
          console.error(`切换Tab失败: ${err.message}`);
          // 如果切换失败，恢复状态
          this.currentTab = this.routerService.getActiveTab();
        } finally {
          // 切换完成后重置标志
          this.isSwitching = false;
        }
      })

      // 我的
      Column() {
        // 选中状态的渐变条（在图标上方）
        if (this.currentTab === 3) {
          Row()
            .width(40)
            .height(3)
            .borderRadius({ bottomLeft: 2, bottomRight: 2 })
            .linearGradient({
              angle: 135,
              colors: [
                ['#667eea', 0.0],
                ['#764ba2', 1.0]
              ]
            })
            .margin({ bottom: 4 })
        } else {
          // 占位，保持对齐
          Row()
            .width(40)
            .height(3)
            .margin({ bottom: 4 })
        }

        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .fillColor(this.currentTab === 3 ? '#667eea' : '#6B7280')

        Text($r('app.string.my'))
          .fontSize(12)
          .fontWeight(this.currentTab === 3 ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.currentTab === 3 ? '#667eea' : '#6B7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(async () => {
        // 标记正在切换Tab
        this.isSwitching = true;
        // 立即更新本地状态，确保UI即时响应
        this.currentTab = 3;
        // 同时立即更新RouterService的状态
        this.routerService.setActiveTab(3);
        // 然后执行路由切换
        try {
          await this.routerService.switchTab(3);
        } catch (err) {
          console.error(`切换Tab失败: ${err.message}`);
          // 如果切换失败，恢复状态
          this.currentTab = this.routerService.getActiveTab();
        } finally {
          // 切换完成后重置标志
          this.isSwitching = false;
        }
      })
    }
    .width('100%')
    .height(56)
    .padding({ top: 8, bottom: 8 })
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#E5E7EB' })
    .shadow({
      radius: 2,
      color: '#000000',
      offsetX: 0,
      offsetY: -1
    })
  }
}

