import router from '@ohos.router';
import { RouterService } from '../common/services/RouterService';
import { UserService, UserInfo } from '../common/services/UserService';
import { UserApiService } from '../common/services/UserApiService';
import { AuthService } from '../common/services/AuthService';
import { TabBar } from '../common/components/TabBar';
import { picker } from '@kit.CoreFileKit';
import { ImageService } from '../common/services/ImageService';
import { ToastUtil } from '../common/utils/ToastUtil';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct My {
  @State userInfo: UserInfo | null = null;
  @State processedCount: number = 0; // 已处理数量
  @State remainingQuota: number = 0; // 剩余额度
  @State membershipExpiry: string = ''; // 会员到期日期
  @State avatarUrl: string = ''; // 头像URL
  @State menuBadges: Record<string, boolean> = {
    '订单记录': true,
    '邀请有礼': false,
    '客服中心': false
  };
  @State showNicknameDialog: boolean = false; // 是否显示昵称修改对话框
  @State newNickname: string = ''; // 新昵称
  
  private userService: UserService = UserService.getInstance();
  private userApiService: UserApiService = UserApiService.getInstance();
  private authService: AuthService = AuthService.getInstance();
  private imageService: ImageService = ImageService.getInstance();

  aboutToAppear() {
    // 加载用户信息
    this.loadUserInfo();
    // 加载统计数据
    this.loadStatistics();
  }

  // 加载用户信息
  async loadUserInfo() {
    try {
      // 先从本地获取
      this.userInfo = await this.userService.getUserInfo();
      
      // 然后从API获取最新信息
      const profile = await this.userApiService.getUserProfile();
      // 更新本地用户信息
      if (this.userInfo) {
        this.userInfo.nickname = profile.nickname;
        await this.userService.saveUserInfo(this.userInfo);
      }
      // 更新头像URL
      if (profile.avatar) {
        this.avatarUrl = profile.avatar;
      }
    } catch (error) {
      console.error(`加载用户信息失败: ${error.message}`);
    }
  }

  // 加载统计数据
  async loadStatistics() {
    try {
      const stats = await this.userApiService.getUserStats();
      this.processedCount = stats.processedCount;
      this.remainingQuota = stats.remainingQuota;
      
      // 格式化会员到期日期
      if (stats.membershipDaysLeft !== undefined && stats.membershipDaysLeft > 0) {
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + stats.membershipDaysLeft);
        this.membershipExpiry = expiryDate.toISOString().split('T')[0];
      } else {
        this.membershipExpiry = '';
      }
    } catch (error) {
      console.error(`加载统计数据失败: ${error.message}`);
      // 使用默认值
      this.processedCount = 0;
      this.remainingQuota = 10;
      this.membershipExpiry = '';
    }
  }

  // 返回上一页
  async handleBack() {
    console.info('[My] handleBack 被调用');
    try {
      await RouterService.getInstance().goBack();
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : String(err);
        console.error(`[My] 返回失败: ${errorMsg}`);
      // RouterService.goBack() 内部已经处理了错误情况，这里只是记录日志
    }
  }

  // 选择头像
  async selectAvatar() {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        const imageUri = photoSelectResult.photoUris[0];
        // 上传头像
        await this.uploadAvatar(imageUri);
      }
    } catch (err) {
      console.error(`选择头像失败: ${JSON.stringify(err)}`);
      ToastUtil.showError('选择头像失败，请重试');
    }
  }

  // 上传头像
  async uploadAvatar(imageUri: string) {
    try {
      ToastUtil.showInfo('正在上传头像...');
      
      // 上传图片
      const uploadResponse = await this.imageService.uploadImages([imageUri]);
      
      if (uploadResponse.images && uploadResponse.images.length > 0) {
        const avatarUrl = uploadResponse.images[0].url;
        
        // 更新用户信息
        const profile = await this.userApiService.updateUserProfile({ avatar: avatarUrl });
        
        // 更新本地头像URL
        this.avatarUrl = avatarUrl;
        
        ToastUtil.showSuccess('头像上传成功');
      } else {
        throw new Error('上传失败，未返回图片URL');
      }
        } catch (error) {
      console.error(`上传头像失败: ${error.message}`);
      ToastUtil.showError('上传头像失败，请重试');
    }
  }

  // 修改昵称
  editNickname() {
    this.newNickname = this.userInfo?.nickname || '';
    this.showNicknameDialog = true;
  }

  // 保存昵称
  async saveNickname() {
    if (!this.newNickname || this.newNickname.trim() === '') {
      ToastUtil.showError('昵称不能为空');
      return;
    }

    if (this.newNickname.trim() === this.userInfo?.nickname) {
      this.showNicknameDialog = false;
      return;
    }

    try {
      ToastUtil.showInfo('正在更新昵称...');
      
      // 更新用户昵称
      const profile = await this.userApiService.updateUserProfile({ nickname: this.newNickname.trim() });
      
      // 更新本地用户信息
      if (this.userInfo) {
        this.userInfo.nickname = profile.nickname;
        await this.userService.saveUserInfo(this.userInfo);
      }
      
      this.showNicknameDialog = false;
      ToastUtil.showSuccess('昵称修改成功');
    } catch (error) {
      console.error(`修改昵称失败: ${error.message}`);
      ToastUtil.showError('修改昵称失败，请重试');
    }
  }

  // 构建菜单项
  @Builder
  buildMenuItem(title: string, iconResource: Resource, showBadge: boolean, onClick: () => void) {
    Row() {
      // 左侧图标
      Stack() {
        Image(iconResource)
          .width(20)
          .height(20)

        // 红点通知
        if (showBadge) {
          Stack() {
            Circle({ width: 8, height: 8 })
              .fill('#EF4444')
          }
          .width(8)
          .height(8)
          .position({ x: 12, y: -2 })
        }
      }
      .width(24)
      .height(24)
      .margin({ right: 12 })

      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
        .fontColor('#1A1F36')
        .layoutWeight(1)

      // 右侧箭头
      Image($r('app.media.right'))
        .width(20)
        .height(20)
        .fillColor('#6B7280')
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .alignItems(VerticalAlign.Center)
    .onClick(onClick)
  }

  build() {
    Column() {
      // 顶部标题栏
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
          await RouterService.getInstance().navigateTo('pages/Index', undefined, true);
        })

        // 标题
        Text('我的')
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
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E7EB' })

      Scroll() {
        Column() {
          // 用户信息卡片
          Row() {
            // 头像
            Stack() {
              Circle({ width: 60, height: 60 })
                .fill('#E5E7EB')

              if (this.avatarUrl) {
                Image(this.avatarUrl)
                  .width(48)
                  .height(48)
                  .borderRadius(24)
                  .objectFit(ImageFit.Cover)
                  .alt($r('app.media.touxiang'))
              } else {
                Image($r('app.media.touxiang'))
                  .width(48)
                  .height(48)
                  .borderRadius(24)
                  .objectFit(ImageFit.Cover)
              }
            }
            .width(60)
            .height(60)
            .margin({ right: 16 })
            .onClick(() => {
              this.selectAvatar();
            })

            // 用户信息
            Column() {
              // 用户名和编辑图标
              Row() {
              Text(this.userInfo?.nickname || this.userInfo?.phone || '游客')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1F36')
                  .layoutWeight(1)

                Image($r('app.media.my_works'))
                  .width(16)
                  .height(16)
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.editNickname();
                  })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
                .margin({ bottom: 8 })

              // 会员标签
              Row() {
                Text('会员')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              }
              .borderRadius(4)
              .backgroundColor('#667eea')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 20 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 统计卡片
          Row() {
            // 已处理
            Column() {
              Text(this.processedCount.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1F36')
                .margin({ bottom: 4 })
              
              Text('已处理')
                .fontSize(12)
                .fontColor('#6B7280')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Divider()
              .vertical(true)
              .height(40)
              .color('#E5E7EB')

            // 剩余额度
            Column() {
              Text(this.remainingQuota.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1F36')
                .margin({ bottom: 4 })
              
              Text('剩余额度')
                .fontSize(12)
                .fontColor('#6B7280')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Divider()
              .vertical(true)
              .height(40)
              .color('#E5E7EB')

            // 会员到期
            Column() {
              Text(this.membershipExpiry || '--')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1F36')
                .margin({ bottom: 4 })
              
              Text('会员到期')
                .fontSize(12)
                .fontColor('#6B7280')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ top: 20, bottom: 20 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 升级按钮
          Row() {
            // 左侧图标
            Stack() {
              Circle({ width: 32, height: 32 })
                .fill('#FFFFFF')
                .opacity(0.2)
              
              Image($r('app.media.zhuanye'))
                .width(24)
                .height(24)
                .objectFit(ImageFit.Contain)
            }
            .width(32)
            .height(32)
            .alignContent(Alignment.Center)
            .margin({ right: 12 })

            // 中间文字
            Column() {
              Text($r('app.string.upgrade_pro'))
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .margin({ bottom: 2 })

              Text($r('app.string.unlimited_use'))
                .fontSize(14)
                .fontColor('#FFFFFF')
                .opacity(0.9)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // 右侧箭头
            Image($r('app.media.right'))
              .width(20)
              .height(20)
              .fillColor('#FFFFFF')
          }
          .width('100%')
          .height(80)
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })
          .borderRadius(16)
          .linearGradient({
            angle: 135,
            colors: [
              ['#667eea', 0.0],
              ['#764ba2', 1.0]
            ]
          })
          .shadow({
            radius: 12,
            color: '#667eea',
            offsetX: 0,
            offsetY: 4
          })
          .margin({ bottom: 12 })
          .onClick(() => {
            // 跳转到升级页面
            RouterService.getInstance().navigateTo('pages/MemberSubscription')
              .catch((err: Error) => {
                console.error(`跳转失败: ${err.message}`);
              });
          })

          // 菜单列表
          Column() {
            // 我的作品
            this.buildMenuItem('我的作品', $r('app.media.my_works'), false, async () => {
              // 切换到Tab 2 (作品页)
              await RouterService.getInstance().switchTab(2)
                .catch((err: Error) => {
                  console.error(`切换Tab失败: ${err.message}`);
                });
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 订单记录
            this.buildMenuItem('订单记录', $r('app.media.order_record'), this.menuBadges['订单记录'], () => {
              console.info('跳转到订单记录页面');
              // 点击后清除红点
              this.menuBadges['订单记录'] = false;
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 邀请有礼
            this.buildMenuItem('邀请有礼', $r('app.media.invite_gift'), this.menuBadges['邀请有礼'], () => {
              console.info('跳转到邀请有礼页面');
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 客服中心
            this.buildMenuItem('客服中心', $r('app.media.customer_service'), this.menuBadges['客服中心'], () => {
              console.info('跳转到客服中心页面');
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 设置
            this.buildMenuItem('设置', $r('app.media.settings'), false, () => {
              RouterService.getInstance().navigateTo('pages/Settings')
                .catch((err: Error) => {
                  console.error(`跳转失败: ${err.message}`);
                });
            })

            Divider()
              .color('#E5E7EB')
              .margin({ left: 20, right: 20 })

            // 关于我们
            this.buildMenuItem('关于我们', $r('app.media.about_us'), false, () => {
              console.info('跳转到关于我们页面');
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 12 })
          .shadow({
            radius: 2,
            color: '#000000',
            offsetX: 0,
            offsetY: 1
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 20 })
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F9FAFB')

      // 底部导航栏
      TabBar()

      // 昵称修改对话框
      if (this.showNicknameDialog) {
        Stack() {
          // 背景遮罩
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.4)
            .onClick(() => {
              this.showNicknameDialog = false;
            })

          // 对话框内容
          Column() {
            // 标题
            Row() {
              Text('修改昵称')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1F36')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)

              Button() {
                Image($r('app.media.last'))
                  .width(16)
                  .height(16)
                  .fillColor('#6B7280')
              }
              .type(ButtonType.Normal)
              .width(32)
              .height(32)
              .backgroundColor('#F8F9FC')
              .borderRadius(8)
              .onClick(() => {
                this.showNicknameDialog = false;
              })
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .border({ width: { bottom: 1 }, color: '#E5E7EB' })

            // 输入框
            Column() {
              TextInput({ placeholder: '请输入昵称', text: this.newNickname })
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor('#1A1F36')
                .backgroundColor('#F8F9FC')
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => {
                  this.newNickname = value;
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 20 })

            // 按钮
            Row() {
              Button('取消')
                .type(ButtonType.Normal)
                .fontSize(16)
                .fontColor('#6B7280')
                .backgroundColor('#F3F4F6')
                .borderRadius(8)
                .layoutWeight(1)
                .height(44)
                .onClick(() => {
                  this.showNicknameDialog = false;
                })

              Blank()
                .width(12)

              Button('确定')
                .type(ButtonType.Normal)
                .fontSize(16)
                .fontColor('#FFFFFF')
                .backgroundColor('#667eea')
                .borderRadius(8)
                .layoutWeight(1)
                .height(44)
                .onClick(() => {
                  this.saveNickname();
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('80%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({
            radius: 8,
            color: '#000000',
            offsetX: 0,
            offsetY: 2
          })
        }
        .width('100%')
        .height('100%')
        .alignContent(Alignment.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FC')
  }
}

