import router from '@ohos.router';
import { TabItem, WorkItem } from '../common/types/CommonTypes';

@Entry
@Component
struct MyWorks {
  // 当前选中的标签
  @State selectedTab: string = '全部';
  
  // 标签列表
  private tabs: TabItem[] = [
    { id: '全部', title: '全部' },
    { id: '淘宝', title: '淘宝' },
    { id: '抖音', title: '抖音' },
    { id: '小红书', title: '小红书' },
    { id: '亚马', title: '亚马' }
  ];
  
  // 作品列表（当前为空）
  @State worksList: WorkItem[] = [];

  build() {
    Column() {
      // 顶部标题
      Text('我的作品')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 20, bottom: 16 })
        .backgroundColor('#FFFFFF')
      
      // 导航标签栏
      Scroll() {
        Row() {
          ForEach(this.tabs, (tab: TabItem) => {
            Text(tab.title)
              .fontSize(14)
              .fontWeight(this.selectedTab === tab.id ? FontWeight.Medium : FontWeight.Normal)
              .fontColor(this.selectedTab === tab.id ? '#FFFFFF' : '#1F2937')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(16)
              .backgroundColor(this.selectedTab === tab.id ? '#3B82F6' : 'transparent')
              .onClick(() => {
                this.selectedTab = tab.id;
              })
          }, (tab: TabItem) => tab.id)
        }
        .padding({ left: 20, right: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(48)
      .backgroundColor('#FFFFFF')
      
      // 内容区域
      if (this.worksList.length === 0) {
        // 空状态
        Column() {
          // 文件夹图标
          Image($r('app.media.startIcon'))
            .width(100)
            .height(100)
            .fillColor('#9CA3AF')
            .opacity(0.6)
            .margin({ bottom: 32 })
          
          // "还没有作品"文字
          Text('还没有作品')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2937')
            .margin({ bottom: 12 })
          
          // 提示文字
          Text('开始处理你的第一张图片吧')
            .fontSize(14)
            .fontColor('#6B7280')
            .margin({ bottom: 32 })
          
          // "立即处理"按钮
          Text('立即处理')
            .fontSize(16)
            .fontColor('#1F2937')
            .decoration({ type: TextDecorationType.Underline })
            .onClick(() => {
              // 跳转到首页
              router.replaceUrl({ url: 'pages/Index' });
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 20, right: 20 })
      } else {
        // 有作品时的列表（后续实现）
        Column() {
          Text('作品列表')
            .fontSize(16)
            .fontColor('#1F2937')
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

