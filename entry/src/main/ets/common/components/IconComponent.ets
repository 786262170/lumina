/**
 * 图标类型枚举
 */
export enum IconType {
  LUMINA_LOGO = 'lumina_logo',
  QUESTIONNAIRE = 'questionnaire',  // 问卷页面主图标
  RECOMMENDATION = 'recommendation',  // 推荐页面主图标
  CUTOUT = 'cutout',
  BACKGROUND = 'background',
  LIGHT = 'light',
  BATCH = 'batch',
  SCENARIO = 'scenario',
  STAR = 'star',
  // 选项图标
  BAG = 'bag',
  PHONE = 'phone',
  COSMETIC = 'cosmetic',
  FOOD = 'food',
  HOME = 'home',
  SPORTS = 'sports',
  BOOK = 'book',
  OTHER = 'other',
  PLATFORM = 'platform',
  // 平台图标（有区分度）
  TAOBAO = 'taobao',
  TMALL = 'tmall',
  JD = 'jd',
  DOUYIN = 'douyin',
  XIAOHONGSHU = 'xiaohongshu',
  AMAZON = 'amazon',
  // 设计风格图标
  SIMPLE = 'simple',
  PROFESSIONAL = 'professional',
  CREATIVE = 'creative',
  PLACEHOLDER = 'placeholder'
}

/**
 * 图标资源映射工具类
 * 将图标类型映射到PNG资源文件
 */
export class IconResource {
  /**
   * 根据图标类型获取对应的资源
   * 使用现有的PNG图标资源
   */
  static getResource(iconType: IconType): Resource {
    switch (iconType) {
      case IconType.LUMINA_LOGO:
        return $r('app.media.lumina_logo');
      case IconType.QUESTIONNAIRE:
        return $r('app.media.icon_questionnaire');
      case IconType.RECOMMENDATION:
        return $r('app.media.icon_recommendation');
      case IconType.CUTOUT:
        return $r('app.media.icon_cutout');
      case IconType.BACKGROUND:
        return $r('app.media.icon_background');
      case IconType.LIGHT:
        return $r('app.media.icon_light');
      case IconType.BATCH:
        return $r('app.media.icon_batch');
      case IconType.SCENARIO:
        return $r('app.media.icon_scenario');
      case IconType.STAR:
        return $r('app.media.icon_star');
      // 选项图标
      case IconType.BAG:
        return $r('app.media.icon_bag');
      case IconType.PHONE:
        return $r('app.media.icon_phone');
      case IconType.COSMETIC:
        return $r('app.media.icon_cosmetic');
      case IconType.FOOD:
        return $r('app.media.icon_food');
      case IconType.HOME:
        return $r('app.media.icon_home');
      case IconType.SPORTS:
        return $r('app.media.icon_sports');
      case IconType.BOOK:
        return $r('app.media.icon_book');
      case IconType.OTHER:
        return $r('app.media.icon_other');
      case IconType.PLATFORM:
        return $r('app.media.icon_platform');
      // 平台图标（使用现有的app图标文件）
      case IconType.TAOBAO:
        return $r('app.media.taobao');
      case IconType.TMALL:
        return $r('app.media.icon_tmall');  // 如果没有tmall.png，保留生成的图标
      case IconType.JD:
        return $r('app.media.icon_jd');  // 如果没有jd.png，保留生成的图标
      case IconType.DOUYIN:
        return $r('app.media.douyin');
      case IconType.XIAOHONGSHU:
        return $r('app.media.xiaohongshu');
      case IconType.AMAZON:
        return $r('app.media.amazon');
      // 设计风格图标
      case IconType.SIMPLE:
        return $r('app.media.icon_simple');
      case IconType.PROFESSIONAL:
        return $r('app.media.icon_professional');
      case IconType.CREATIVE:
        return $r('app.media.icon_creative');
      default:
        return $r('app.media.startIcon');
    }
  }
}

/**
 * 可复用的图标组件
 * 使用PNG图片资源显示图标
 */
@Component
export struct IconComponent {
  @Prop iconType: IconType = IconType.PLACEHOLDER;
  @Prop iconSize: number = 24;
  @Prop iconColor: string = '#667eea'; // 保留用于可能的颜色过滤

  build() {
    Image(IconResource.getResource(this.iconType))
      .width(this.iconSize)
      .height(this.iconSize)
      .objectFit(ImageFit.Contain)
  }
}

