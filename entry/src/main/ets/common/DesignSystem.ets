/**
 * Lumina AI 设计系统常量
 * 基于参考项目的设计系统规范
 */

/**
 * 颜色系统
 */
export class LuminaColors {
  // 主色
  static readonly PRIMARY_BLUE: string = '#667eea';
  static readonly SECONDARY_PURPLE: string = '#764ba2';
  static readonly ACCENT_PINK: string = '#f093fb';

  // 背景色
  static readonly BG_PRIMARY: string = '#F8F9FC';
  static readonly BG_SURFACE: string = '#FFFFFF';

  // 文字色
  static readonly TEXT_PRIMARY: string = '#1A1F36';
  static readonly TEXT_SECONDARY: string = '#6B7280';
  static readonly TEXT_HINT: string = '#C7C7CC';

  // 状态色
  static readonly SUCCESS: string = '#10B981';
  static readonly WARNING: string = '#F59E0B';
  static readonly ERROR: string = '#EF4444';

  // 边框色
  static readonly BORDER: string = '#E5E7EB';
}

/**
 * 间距系统
 */
export class LuminaSpacing {
  static readonly XS: number = 4;
  static readonly SM: number = 8;
  static readonly MD: number = 16;
  static readonly LG: number = 24;
  static readonly XL: number = 32;
  static readonly XXL: number = 48;
}

/**
 * 圆角系统
 */
export class LuminaRadius {
  static readonly SM: number = 4;
  static readonly MD: number = 8;
  static readonly LG: number = 12;
  static readonly XL: number = 16;
  static readonly XXL: number = 24;
  static readonly XXXL: number = 32;
}

/**
 * 字体系统
 */
export class LuminaTypography {
  // 字号
  static readonly DISPLAY_LG: number = 48;
  static readonly DISPLAY_MD: number = 36;
  static readonly HEADLINE: number = 28;
  static readonly TITLE: number = 20;
  static readonly BODY: number = 16;
  static readonly CAPTION: number = 14;
  static readonly LABEL: number = 12;

  // 字重
  static readonly WEIGHT_REGULAR: FontWeight = FontWeight.Regular;
  static readonly WEIGHT_MEDIUM: FontWeight = FontWeight.Medium;
  static readonly WEIGHT_SEMIBOLD: FontWeight = FontWeight.SemiBold;
  static readonly WEIGHT_BOLD: FontWeight = FontWeight.Bold;
}

/**
 * 阴影系统
 */
export class LuminaShadows {
  // 卡片默认阴影
  static readonly CARD_DEFAULT: ShadowOptions = {
    radius: 4,
    color: '#000000',
    offsetX: 0,
    offsetY: 2
  };

  // 卡片悬停阴影
  static readonly CARD_HOVER: ShadowOptions = {
    radius: 8,
    color: '#000000',
    offsetX: 0,
    offsetY: 4
  };

  // 渐变按钮阴影
  static readonly GRADIENT_BUTTON: ShadowOptions = {
    radius: 12,
    color: '#667eea',
    offsetX: 0,
    offsetY: 4
  };
}

/**
 * 渐变系统
 */
export class LuminaGradients {
  // Aurora渐变（主渐变）
  static readonly AURORA: Array<[string, number]> = [
    ['#667eea', 0.0],
    ['#764ba2', 1.0]
  ];

  // 图标背景渐变（透明）
  static readonly ICON_BG: Array<[string, number]> = [
    ['rgba(102, 126, 234, 0.1)', 0.0],
    ['rgba(118, 75, 162, 0.1)', 1.0]
  ];
}

/**
 * 尺寸系统
 */
export class LuminaSizes {
  // 图标尺寸
  static readonly ICON_SM: number = 16;
  static readonly ICON_MD: number = 24;
  static readonly ICON_LG: number = 32;
  static readonly ICON_XL: number = 48;

  // 按钮尺寸
  static readonly BUTTON_HEIGHT_SM: number = 32;
  static readonly BUTTON_HEIGHT_MD: number = 44;
  static readonly BUTTON_HEIGHT_LG: number = 56;

  // 导航栏
  static readonly NAV_BAR_HEIGHT: number = 56;
  static readonly TAB_BAR_HEIGHT: number = 56;

  // 卡片尺寸
  static readonly SCENE_CARD_WIDTH: number = 165.5;
  static readonly SCENE_CARD_HEIGHT: number = 144;
  static readonly WORK_THUMBNAIL_SIZE: number = 143;
}

