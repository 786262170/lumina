/**
 * 图标绘制工具类
 * 使用Canvas绘制所有应用图标，避免依赖外部图片文件
 */
export class IconDrawer {
  /**
   * 绘制Lumina主Logo（2x2网格）
   */
  static drawLuminaLogo(ctx: CanvasRenderingContext2D, size: number) {
    ctx.clearRect(0, 0, size, size);
    
    const gridSize = size * 0.32; // 每个方块的大小
    const spacing = size * 0.04; // 方块之间的间距
    const startX = (size - (gridSize * 2 + spacing)) / 2;
    const startY = (size - (gridSize * 2 + spacing)) / 2;
    
    // 绘制2x2网格（白色方块）
    ctx.fillStyle = '#FFFFFF';
    ctx.fillRect(startX, startY, gridSize, gridSize);
    ctx.fillRect(startX + gridSize + spacing, startY, gridSize, gridSize);
    ctx.fillRect(startX, startY + gridSize + spacing, gridSize, gridSize);
    ctx.fillRect(startX + gridSize + spacing, startY + gridSize + spacing, gridSize, gridSize);
  }

  /**
   * 绘制智能抠图图标（剪刀+图片）
   */
  static drawCutoutIcon(ctx: CanvasRenderingContext2D, size: number, color: string = '#667eea') {
    ctx.clearRect(0, 0, size, size);
    
    // 图片轮廓
    ctx.strokeStyle = color;
    ctx.lineWidth = size * 0.08;
    const rectX = size * 0.15;
    const rectY = size * 0.25;
    const rectW = size * 0.5;
    const rectH = size * 0.5;
    const radius = size * 0.08;
    ctx.beginPath();
    ctx.moveTo(rectX + radius, rectY);
    ctx.lineTo(rectX + rectW - radius, rectY);
    ctx.quadraticCurveTo(rectX + rectW, rectY, rectX + rectW, rectY + radius);
    ctx.lineTo(rectX + rectW, rectY + rectH - radius);
    ctx.quadraticCurveTo(rectX + rectW, rectY + rectH, rectX + rectW - radius, rectY + rectH);
    ctx.lineTo(rectX + radius, rectY + rectH);
    ctx.quadraticCurveTo(rectX, rectY + rectH, rectX, rectY + rectH - radius);
    ctx.lineTo(rectX, rectY + radius);
    ctx.quadraticCurveTo(rectX, rectY, rectX + radius, rectY);
    ctx.closePath();
    ctx.stroke();
    
    // 剪刀
    ctx.strokeStyle = color;
    ctx.lineWidth = size * 0.08;
    ctx.lineCap = 'round';
    const centerX = size * 0.33;
    const centerY = size * 0.42;
    ctx.beginPath();
    ctx.moveTo(centerX - size * 0.1, centerY - size * 0.1);
    ctx.lineTo(centerX + size * 0.1, centerY + size * 0.1);
    ctx.moveTo(centerX + size * 0.1, centerY - size * 0.1);
    ctx.lineTo(centerX - size * 0.1, centerY + size * 0.1);
    ctx.stroke();
  }

  /**
   * 绘制背景替换图标（层叠图片）
   */
  static drawBackgroundIcon(ctx: CanvasRenderingContext2D, size: number, color: string = '#667eea') {
    ctx.clearRect(0, 0, size, size);
    
    // 底层图片
    ctx.fillStyle = color;
    ctx.globalAlpha = 0.3;
    IconDrawer.drawRoundedRect(ctx, size * 0.15, size * 0.33, size * 0.42, size * 0.42, size * 0.08);
    ctx.fill();
    
    // 顶层图片
    ctx.globalAlpha = 0.8;
    IconDrawer.drawRoundedRect(ctx, size * 0.33, size * 0.15, size * 0.42, size * 0.42, size * 0.08);
    ctx.fill();
    
    ctx.globalAlpha = 1.0;
    
    // 替换箭头
    ctx.strokeStyle = color;
    ctx.lineWidth = size * 0.08;
    ctx.lineCap = 'round';
    const arrowX = size * 0.5;
    const arrowY = size * 0.5;
    ctx.beginPath();
    ctx.moveTo(arrowX, arrowY);
    ctx.lineTo(arrowX + size * 0.15, arrowY - size * 0.15);
    ctx.moveTo(arrowX + size * 0.15, arrowY - size * 0.15);
    ctx.lineTo(arrowX + size * 0.1, arrowY - size * 0.15);
    ctx.moveTo(arrowX + size * 0.15, arrowY - size * 0.15);
    ctx.lineTo(arrowX + size * 0.15, arrowY - size * 0.1);
    ctx.stroke();
  }

  /**
   * 绘制光效调整图标（太阳/光线）
   */
  static drawLightIcon(ctx: CanvasRenderingContext2D, size: number, color: string = '#667eea') {
    ctx.clearRect(0, 0, size, size);
    
    const centerX = size / 2;
    const centerY = size / 2;
    const radius = size * 0.17;
    
    // 中心圆圈（太阳）
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
    ctx.fill();
    
    // 光线（8条）
    ctx.strokeStyle = color;
    ctx.lineWidth = size * 0.08;
    ctx.lineCap = 'round';
    const rayLength = size * 0.15;
    
    // 上下左右
    ctx.beginPath();
    ctx.moveTo(centerX, size * 0.1);
    ctx.lineTo(centerX, size * 0.1 + rayLength);
    ctx.moveTo(centerX, size * 0.9);
    ctx.lineTo(centerX, size * 0.9 - rayLength);
    ctx.moveTo(size * 0.1, centerY);
    ctx.lineTo(size * 0.1 + rayLength, centerY);
    ctx.moveTo(size * 0.9, centerY);
    ctx.lineTo(size * 0.9 - rayLength, centerY);
    ctx.stroke();
    
    // 对角线
    const diagOffset = size * 0.15;
    ctx.beginPath();
    ctx.moveTo(centerX - diagOffset, centerY - diagOffset);
    ctx.lineTo(centerX - diagOffset + rayLength * 0.7, centerY - diagOffset + rayLength * 0.7);
    ctx.moveTo(centerX + diagOffset, centerY + diagOffset);
    ctx.lineTo(centerX + diagOffset - rayLength * 0.7, centerY + diagOffset - rayLength * 0.7);
    ctx.moveTo(centerX - diagOffset, centerY + diagOffset);
    ctx.lineTo(centerX - diagOffset + rayLength * 0.7, centerY + diagOffset - rayLength * 0.7);
    ctx.moveTo(centerX + diagOffset, centerY - diagOffset);
    ctx.lineTo(centerX + diagOffset - rayLength * 0.7, centerY - diagOffset + rayLength * 0.7);
    ctx.stroke();
  }

  /**
   * 绘制批量处理图标（多个图片层叠）
   */
  static drawBatchIcon(ctx: CanvasRenderingContext2D, size: number, color: string = '#667eea') {
    ctx.clearRect(0, 0, size, size);
    
    // 底层图片
    ctx.fillStyle = color;
    ctx.globalAlpha = 0.4;
    IconDrawer.drawRoundedRect(ctx, size * 0.15, size * 0.42, size * 0.33, size * 0.33, size * 0.04);
    ctx.fill();
    
    // 中层图片
    ctx.globalAlpha = 0.6;
    IconDrawer.drawRoundedRect(ctx, size * 0.25, size * 0.25, size * 0.33, size * 0.33, size * 0.04);
    ctx.fill();
    
    // 顶层图片
    ctx.globalAlpha = 1.0;
    IconDrawer.drawRoundedRect(ctx, size * 0.33, size * 0.08, size * 0.33, size * 0.33, size * 0.04);
    ctx.fill();
    
    ctx.globalAlpha = 1.0;
    
    // 批量标记（数字3）
    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(size * 0.58, size * 0.17, size * 0.12, 0, Math.PI * 2);
    ctx.fill();
    
    ctx.fillStyle = color;
    ctx.font = `bold ${size * 0.25}px sans-serif`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('3', size * 0.58, size * 0.17);
  }

  /**
   * 绘制场景图标（网格/模板）
   */
  static drawScenarioIcon(ctx: CanvasRenderingContext2D, size: number, color: string = '#667eea') {
    ctx.clearRect(0, 0, size, size);
    
    const padding = size * 0.15;
    const width = size - padding * 2;
    const height = size - padding * 2;
    
    // 外框
    ctx.strokeStyle = color;
    ctx.lineWidth = size * 0.08;
    ctx.beginPath();
    IconDrawer.drawRoundedRect(ctx, padding, padding, width, height, size * 0.08);
    ctx.stroke();
    
    // 网格线
    ctx.strokeStyle = color;
    ctx.lineWidth = size * 0.04;
    ctx.beginPath();
    ctx.moveTo(size / 2, padding);
    ctx.lineTo(size / 2, size - padding);
    ctx.moveTo(padding, size / 2);
    ctx.lineTo(size - padding, size / 2);
    ctx.stroke();
    
    // 四个角的小方块
    const smallSize = size * 0.15;
    ctx.fillStyle = color;
    ctx.globalAlpha = 0.6;
    IconDrawer.drawRoundedRect(ctx, padding + size * 0.05, padding + size * 0.05, smallSize, smallSize, size * 0.04);
    ctx.fill();
    IconDrawer.drawRoundedRect(ctx, size - padding - size * 0.05 - smallSize, padding + size * 0.05, smallSize, smallSize, size * 0.04);
    ctx.fill();
    IconDrawer.drawRoundedRect(ctx, padding + size * 0.05, size - padding - size * 0.05 - smallSize, smallSize, smallSize, size * 0.04);
    ctx.fill();
    IconDrawer.drawRoundedRect(ctx, size - padding - size * 0.05 - smallSize, size - padding - size * 0.05 - smallSize, smallSize, smallSize, size * 0.04);
    ctx.fill();
    ctx.globalAlpha = 1.0;
  }

  /**
   * 绘制星标图标（四角星）
   */
  static drawStarIcon(ctx: CanvasRenderingContext2D, size: number, color: string = '#667eea') {
    ctx.clearRect(0, 0, size, size);
    
    const centerX = size / 2;
    const centerY = size / 2;
    const outerRadius = size * 0.35;
    const innerRadius = size * 0.15;
    const spikes = 4;
    
    // 绘制四角星
    ctx.fillStyle = color;
    ctx.beginPath();
    for (let i = 0; i < spikes * 2; i++) {
      const radius = i % 2 === 0 ? outerRadius : innerRadius;
      const angle = (Math.PI / spikes) * i - Math.PI / 2;
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);
      if (i === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
    }
    ctx.closePath();
    ctx.fill();
    
    // 小星星装饰
    ctx.fillStyle = '#FFFFFF';
    ctx.globalAlpha = 0.8;
    const smallRadius = size * 0.04;
    ctx.beginPath();
    ctx.arc(size * 0.25, size * 0.25, smallRadius, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(size * 0.75, size * 0.25, smallRadius, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(size * 0.25, size * 0.75, smallRadius, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(size * 0.75, size * 0.75, smallRadius, 0, Math.PI * 2);
    ctx.fill();
    ctx.globalAlpha = 1.0;
  }

  /**
   * 绘制通用占位图标（简单方块）
   */
  static drawPlaceholderIcon(ctx: CanvasRenderingContext2D, size: number, color: string = '#667eea') {
    ctx.clearRect(0, 0, size, size);
    
    ctx.fillStyle = color;
    ctx.globalAlpha = 0.3;
    IconDrawer.drawRoundedRect(ctx, size * 0.2, size * 0.2, size * 0.6, size * 0.6, size * 0.1);
    ctx.fill();
    ctx.globalAlpha = 1.0;
  }

  /**
   * 绘制圆角矩形（辅助方法）
   */
  static drawRoundedRect(ctx: CanvasRenderingContext2D, x: number, y: number, width: number, height: number, radius: number) {
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
    ctx.lineTo(x + width, y + height - radius);
    ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
    ctx.lineTo(x + radius, y + height);
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
  }
}

