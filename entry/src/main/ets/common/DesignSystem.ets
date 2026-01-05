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
  static readonly BUTTON_HEIGHT_LG: number = 50;
  static readonly BUTTON_HEIGHT_XL: number = 56;

  // 输入框尺寸
  static readonly INPUT_HEIGHT: number = 48;
  static readonly INPUT_PADDING_H: number = 16;
  static readonly INPUT_PADDING_V: number = 12;

  // 导航栏
  static readonly NAV_BAR_HEIGHT: number = 56;
  static readonly TAB_BAR_HEIGHT: number = 56;

  // 卡片尺寸
  static readonly SCENE_CARD_WIDTH: number = 165.5;
  static readonly SCENE_CARD_HEIGHT: number = 144;
  static readonly WORK_THUMBNAIL_SIZE: number = 143;

  // 头像尺寸
  static readonly AVATAR_SM: number = 32;
  static readonly AVATAR_MD: number = 40;
  static readonly AVATAR_LG: number = 64;
  static readonly AVATAR_XL: number = 80;
}

/**
 * 布局系统 - 统一的对齐和间距规范
 */
export class LuminaLayout {
  // 页面内边距
  static readonly PAGE_PADDING_H: number = 16; // 水平内边距
  static readonly PAGE_PADDING_V: number = 24; // 垂直内边距
  static readonly PAGE_PADDING_H_LARGE: number = 24; // 大页面水平内边距

  // 内容区域间距
  static readonly SECTION_SPACING: number = 24; // 区块间距
  static readonly ITEM_SPACING: number = 16; // 项目间距
  static readonly ITEM_SPACING_SM: number = 12; // 小项目间距
  static readonly ITEM_SPACING_LG: number = 32; // 大项目间距

  // 网格间距
  static readonly GRID_GAP: number = 12; // 网格间距
  static readonly GRID_GAP_SM: number = 8; // 小网格间距
  static readonly GRID_GAP_LG: number = 16; // 大网格间距

  // 列表项间距
  static readonly LIST_ITEM_SPACING: number = 12;
  static readonly LIST_SECTION_SPACING: number = 24;

  // 对齐方式
  static readonly ALIGN_START: HorizontalAlign = HorizontalAlign.Start;
  static readonly ALIGN_CENTER: HorizontalAlign = HorizontalAlign.Center;
  static readonly ALIGN_END: HorizontalAlign = HorizontalAlign.End;

  // 文本对齐
  static readonly TEXT_ALIGN_LEFT: TextAlign = TextAlign.Start;
  static readonly TEXT_ALIGN_CENTER: TextAlign = TextAlign.Center;
  static readonly TEXT_ALIGN_RIGHT: TextAlign = TextAlign.End;
}

/**
 * 组件样式预设 - 常用的组件样式组合
 * 注意：由于 ArkTS 限制，这些样式仅作为参考，实际使用时需要直接应用属性
 */
export class LuminaStyles {
  // 卡片样式 - 仅作为参考值，使用时需要直接应用
  static readonly CARD_BORDER_RADIUS: number = LuminaRadius.LG;
  static readonly CARD_BACKGROUND_COLOR: string = LuminaColors.BG_SURFACE;
  static readonly CARD_PADDING: number = LuminaSpacing.MD;
  static readonly CARD_BORDER_WIDTH: number = 1;
  static readonly CARD_BORDER_COLOR: string = LuminaColors.BORDER;

  // 输入框样式 - 仅作为参考值，使用时需要直接应用
  static readonly INPUT_HEIGHT: number = LuminaSizes.INPUT_HEIGHT;
  static readonly INPUT_BORDER_RADIUS: number = LuminaRadius.MD;
  static readonly INPUT_BACKGROUND_COLOR: string = LuminaColors.BG_SURFACE;
  static readonly INPUT_BORDER_WIDTH: number = 1;
  static readonly INPUT_BORDER_COLOR: string = LuminaColors.BORDER;
  static readonly INPUT_PADDING_H: number = LuminaSizes.INPUT_PADDING_H;

  // 主按钮样式 - 仅作为参考值，使用时需要直接应用
  static readonly PRIMARY_BUTTON_HEIGHT: number = LuminaSizes.BUTTON_HEIGHT_LG;
  static readonly PRIMARY_BUTTON_BORDER_RADIUS: number = LuminaRadius.MD;
  static readonly PRIMARY_BUTTON_BACKGROUND_COLOR: string = LuminaColors.PRIMARY_BLUE;

  // 次要按钮样式 - 仅作为参考值，使用时需要直接应用
  static readonly SECONDARY_BUTTON_HEIGHT: number = LuminaSizes.BUTTON_HEIGHT_MD;
  static readonly SECONDARY_BUTTON_BORDER_RADIUS: number = LuminaRadius.MD;
  static readonly SECONDARY_BUTTON_BACKGROUND_COLOR: string = LuminaColors.BG_SURFACE;
  static readonly SECONDARY_BUTTON_BORDER_WIDTH: number = 1;
  static readonly SECONDARY_BUTTON_BORDER_COLOR: string = LuminaColors.BORDER;
}

